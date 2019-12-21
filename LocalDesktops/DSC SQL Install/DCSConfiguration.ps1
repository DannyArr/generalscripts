Configuration LocalHost
{
    param(
        [pscredential]$SetupCredential
    )
    Import-DscResource -ModuleName SqlServerDsc
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $AllNodes.NodeName
    {
        LocalConfigurationManager 
        { 
             CertificateId = $Node.Thumbprint
             RefreshMode = "Push"
             ConfigurationMode = "ApplyOnly"
        }

        User 'SqlSvcAccount'
        {
            UserName = $Node.SqlSvcAccount.UserName 
            Description = 'Sql Server service account'
            Disabled = $false
            Ensure = 'Present'
            Password = $Node.SqlSvcAccount
        }

        User 'AgtSvcAccount'
        {
            UserName = $Node.AgtSvcAccount.UserName 
            Description = 'Sql Agent service account'
            Disabled = $false
            Ensure = 'Present'
            Password = $Node.AgtSvcAccount
        }

        User 'IsSvcAccount'
        {
            UserName = $Node.IsSvcAccount.UserName 
            Description = 'Sql IS service account'
            Disabled = $false
            Ensure = 'Present'
            Password = $Node.IsSvcAccount
        }

        SqlSetup 'SqlServerSetup'
        {
            SourcePath = $Node.SourcePath
            InstanceName = $Node.InstanceName
            Features = $Node.SQLFeatures
            SQLSysAdminAccounts = $Node.SQLSysAdminAccounts
            SQLSvcAccount = $Node.SqlSvcAccount
            AgtSvcAccount = $Node.AgtSvcAccount
            ISSvcAccount = $Node.IsSvcAccount
            InstallSharedDir = 'C:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir = 'C:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir = 'C:\SQLServer'
            InstallSQLDataDir = "C:\SQlServer\$($Node.InstanceName)\Data"
            SQLUserDBDir = "C:\SQlServer\$($Node.InstanceName)\Data"
            SQLUserDBLogDir = "C:\SQlServer\$($Node.InstanceName)\Log"
            SQLTempDBDir = "C:\SQlServer\$($Node.InstanceName)\TempDB"
            SQLTempDBLogDir = "C:\SQlServer\$($Node.InstanceName)\TempDB"
            SQLBackupDir = "C:\SQlServer\$($Node.InstanceName)\Backup"
            BrowserSvcStartupType = 'Disabled'
            DependsOn = @('[User]IsSvcAccount','[User]AgtSvcAccount','[User]SqlSvcAccount')
        }

        ##Relies on Get-NetFirewallRule. May not work on win7. Submit issue on GitHub
        # SqlWindowsFirewall 'SqlFirewall'
        # {
        #     DependsOn = '[SqlSetup]SqlServerSetup'
        #     SourcePath = $Node.SourcePath
        #     InstanceName = $Node.InstanceName
        #     Features = 'SQLENGINE,REPLICATION,IS'
        # }
    }
}