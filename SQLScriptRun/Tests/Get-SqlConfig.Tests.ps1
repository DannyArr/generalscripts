describe 'Get-SqlConfig' {

    Context "Unit tests" {
        $expected_host = 'XDD70512'
        $env:COMPUTERNAME = $expected_host
        $expected_env = 'dev'
        $expected_conString = 'XDD70512\dans2014'

        $localConfig = Get-SqlConfig -Path "./config"
        
        It "Host is $expected_host " {
            $localConfig.Host | Should be $expected_host
        }

        It "Environment is $expected_env " {
            $localConfig.Environment | Should be $expected_env
        }

        It "Connection string is $expected_conString " {
            $localConfig.ConnectionString | Should be $expected_conString
        }
    }
}


