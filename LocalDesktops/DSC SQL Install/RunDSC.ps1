. .\DCSConfiguration.ps1
. .\DSCConfigurationData.ps1

Write-Output "## Generating MOF files ##"
LocalHost -ConfigurationData $configData

Write-Output "## Configure LCM ##"
Set-DscLocalConfigurationManager .\LocalHost -Verbose

Write-Output "## Run DSC configuration ##"
Start-DscConfiguration .\LocalHost -Wait -Verbose -Force

#Get-DscLocalConfigurationManager
#(Get-DscLocalConfigurationManager).LCMState
#Remove-DscConfigurationDocument -CimSession $env:COMPUTERNAME -Stage Pending -Force
