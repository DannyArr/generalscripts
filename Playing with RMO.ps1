#https://blogs.msdn.microsoft.com/johan/2008/10/01/powershell-editing-permissions-on-a-file-or-folder/
##SETUP
$workingDir = 'C:\Dev\Replication\Dans2017\repldata'
$passwrd = 'replP4ss!!123'
$secPwd = ConvertTo-SecureString $passwrd -AsPlainText -Force
$smbShare = "repldata"
$distDbName = "distribution"
$logReaderUser = "repl_logreader"
$snapshotUser = "repl_snapshot"
$distributionUser = "repl_distribution"

if(!(Test-Path -Path $workingDir)) {
    New-Item -Path $workingDir -ItemType Directory
}

if (!(Get-SmbShare -Name $smbShare -ErrorAction SilentlyContinue)) {
    New-SmbShare -Path $workingDir -Name $smbShare -NoAccess "Everyone"
}


[hashtable]$replUsers = @{$logReaderUser = 'Read';$snapshotUser = 'Full';$distributionUser = 'Read'}
foreach ( $user in $replUsers.GetEnumerator() ) {
    if(!(Get-LocalUser -Name $user.Key)) {
        New-LocalUser -Name $user.Key -AccountNeverExpires -PasswordNeverExpires -Password $secPwd -Description "PWD: $passwrd"
    }

    switch ($user.Value) {
        Read {
            $permission = "Read"
        }
        Full {
            $permission = "FullControl"
        }
    }

    $acl = Get-Acl $workingDir
    $accessRule = [System.Security.AccessControl.FileSystemAccessRule]::new("$env:COMPUTERNAME\$($user.key)",$permission,"Allow")   
    $acl.ResetAccessRule($accessRule)
    Set-Acl -Path $workingDir -AclObject $acl

    Grant-SmbShareAccess -Name $smbShare -AccountName $user.key -AccessRight $user.Value -Force | Out-Null
}

########
Import-Module sqlserver
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Rmo')

$publisherInstance = "DANSLAB\DANS2017"
$distributorInstance = $publisherInstance
$publicationDbName = "WideWorldImporters-Full"

$subscriberInstance = "DANSLAB\DANS2017S"
$subscriberDBName = "WWI_subscriber"

$pubSqlSvr = [Microsoft.SqlServer.Management.Smo.Server]::new($publisherInstance)
$subSqlSvr = [Microsoft.SqlServer.Management.Smo.Server]::new($subscriberInstance)
$distSvr = [Microsoft.SqlServer.Replication.ReplicationServer]::new($distributorInstance)
$pubSvr = [Microsoft.SqlServer.Replication.ReplicationServer]::new($publisherInstance)
$distDb = [Microsoft.SqlServer.Replication.DistributionDatabase]::new($distDbName,$distributorInstance)
$publisher = [Microsoft.SqlServer.Replication.DistributionPublisher]::new($publisherInstance,$publisherInstance)
$publicationDb = [Microsoft.SqlServer.Replication.ReplicationDatabase]::new($publicationDbName,$publisherInstance)

$publisher.DistributionDatabase = $distDb.name
$publisher.WorkingDirectory = $workingDir

if (($distSvr.IsDistributor) -and !($distSvr.DistributorInstalled)) {
    $distDb.Create()
}
elseif (!($distSvr.DistributorInstalled)) {
    $distSvr.InstallDistributor("sdfgis!5DFGa",$distDb) #Make pwd securestring
}
else {
    Write-Output "Distributor and distributor database '$distDbName' already exist."
}

if (!$publisher.IsExistingObject) {
    $publisher.Create()
}

if($publicationDb.LoadProperties()) 
{
    #create publication, logreader agent and snapshot agent

    if(!$pubSqlSvr.Logins.Item("DANSLAB\$logReaderUser")) {
        $logReaderLogin = [Microsoft.SqlServer.Management.Smo.Login]::new($publisherInstance,"DANSLAB\$logReaderUser")
        $logReaderLogin.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]("WindowsUser")
        $logReaderLogin.Create()
    }
    
    $pubSqlDb = $pubSqlSvr.Databases.Item($publicationDbName)
    if(!$pubSqlDb.Users.Item("DANSLAB\$logReaderUser")) {
        $dbUser = [Microsoft.SqlServer.Management.Smo.User]::new($pubSqlDb,"DANSLAB\$logReaderUser")
        $dbUser.Login = "DANSLAB\$logReaderUser"
        $dbUser.Create()
    }

    $dbOwnerRole = $pubSqlDb.Roles.Item("db_owner")
    if(!($dbOwnerRole.EnumMembers() | Where-Object {$_ -eq "DANSLAB\$logReaderUser"})) {
        $dbOwnerRole.AddMember("DANSLAB\$logReaderUser")
    }

    $publicationDb.EnabledTransPublishing = $true

    if(!($publicationDb.LogReaderAgentExists)) {
        $publicationDb.LogReaderAgentProcessSecurity.Login = "DANSLAB\$logReaderUser"
        $publicationDb.LogReaderAgentProcessSecurity.Password = $passwrd
        $publicationDb.LogReaderAgentPublisherSecurity.WindowsAuthentication = $true
        $publicationDb.CreateLogReaderAgent()
    }

    $publication = [Microsoft.SqlServer.Replication.TransPublication]::new("PUBN-$($publicationDb.Name)",$publicationDb.Name,$publisherInstance)
    if(!$publication.IsExistingObject)
    {
        $publication.CreateSnapshotAgentByDefault = $false
        $publication.Create()

        $publication.SnapshotGenerationAgentProcessSecurity.Login = "DANSLAB\$snapshotUser"
        $publication.SnapshotGenerationAgentProcessSecurity.Password = $passwrd
        $publication.CreateSnapshotAgent()
    }
    else
    {
        if(!($publication.SnapshotAgentExists))
        {
            $publication.SnapshotGenerationAgentProcessSecurity.Login = "DANSLAB\$snapshotUser"
            $publication.SnapshotGenerationAgentProcessSecurity.Password = $passwrd
            $publication.CreateSnapshotAgent()
        }
    }
}

#We need an article
#https://docs.microsoft.com/en-us/sql/relational-databases/replication/publish/define-an-article?view=sql-server-2017

$articleName = 'Orders'
$articleTable = '[WideWorldImporters-Full].[Sales].[Orders]'
$schemaOwner = 'sales'

$article = [Microsoft.SqlServer.Replication.TransArticle]::new()

$article.ConnectionContext = $publisher.ConnectionContext
$article.Name = $articleName
$article.DatabaseName = $publicationDbName
$article.SourceObjectName = $articleName
$article.SourceObjectOwner = $schemaOwner
$article.PublicationName = $publication.Name
$article.Type = [Microsoft.SqlServer.Replication.ArticleOptions]::LogBased

if (!$article.IsExistingObject)
{
    $article.Create()
}

#Create subscriber (Push for transactional)
#https://docs.microsoft.com/en-us/sql/relational-databases/replication/create-a-push-subscription?view=sql-server-2017
if ($publication.LoadProperties())
{

    #Add AllowPush if not set
    if (($Publication.Attributes -band [Microsoft.SqlServer.Replication.PublicationAttributes]::AllowPush) -eq 0)
    {
        $Publication.Attributes += [Microsoft.SqlServer.Replication.PublicationAttributes]::AllowPush
        $publication.CommitPropertyChanges()
    }

    $subscription = [Microsoft.SqlServer.Replication.TransSubscription]::new()
    $subscription.ConnectionContext = $publisher.ConnectionContext
    $subscription.SubscriberName = $subscriberInstance
    $subscription.SubscriptionDBName = $subscriberDBName
    $subscription.PublicationName = $publication.Name
    $subscription.DatabaseName = $publicationDbName

    #credentials for distribution agent
    $subscription.SynchronizationAgentProcessSecurity.Login = "DANSLAB\$distributionUser"
    $subscription.SynchronizationAgentProcessSecurity.Password = $passwrd
    #$subscription.SynchronizationAgentProcessSecurity.SecurePassword = $secPwd

    #Should encrypt connection when sending commands to distributor: 
    #https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/enable-encrypted-connections-to-the-database-engine?view=sql-server-2017

    $subscription.CreateSyncAgentByDefault = $true
    $subscription.AgentSchedule.FrequencyType = [Microsoft.SqlServer.Replication.ScheduleFrequencyType]::OnDemand
    $subscription.Create()

}


##################

#$subscriberConn = [Microsoft.SqlServer.Management.Common.ServerConnection]::new($subscriberInstance)
#$subscriberConn.connect()#

#$subscriberDB = New-Object Microsoft.SqlServer.Management.Smo.Database($subscriberInstance, $subscriberDBName)
#$subscriberDB

