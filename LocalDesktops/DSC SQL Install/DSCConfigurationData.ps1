$certPath = "$env:temp\DscPublicKey.cer"
$thumbprint = (Get-PfxCertificate -FilePath $certPath).Thumbprint
$sourcePath = "C:\Temp\sqlsetup"
$instanceName = "Dans2017"
$sqlSysAdminAccounts = "$env:UserDomain\$env:UserName"

$sqlSvcAccount = Get-Credential -UserName 'SVC-SQL-LOCAL2017' -Message "SQL Server Service Account"
$agtSvcAccount = Get-Credential -UserName 'SVC-AGT-LOCAL2017' -Message "SQL Agent Account"
$isSvcAccount = Get-Credential -UserName 'SVC-IS-LOCAL2017' -Message "Integration Services Service Account"

$configData = @{
    AllNodes = @(
        @{
            NodeName = '*'
            PSDscAllowPlainTextPassword = $false
            CertificateFile = $certPath
            Thumbprint = $thumbprint
        },
        @{
            NodeName = 'localhost'
            SqlSvcAccount = $sqlSvcAccount
            AgtSvcAccount = $agtSvcAccount
            IsSvcAccount = $isSvcAccount 
            SourcePath = $sourcePath
            InstanceName = $instanceName
            SQLSysAdminAccounts = $sqlSysAdminAccounts
            SQLFeatures = 'SQLENGINE,REPLICATION,IS'
        }
    )
}

#For further info:
#https://blogs.infosupport.com/safely-using-pscredentials-in-a-powershell-dsc-configuration/
