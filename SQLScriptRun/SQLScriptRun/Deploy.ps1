#This is an example deploy.ps1 file
#Uses config json file

$thisPath = Get-Item $PSScriptRoot
$testPath = Join-Path $thisPath.Parent.FullName "Tests"
$logTo = Join-Path $testPath "DeployLogs"
$scriptBatchFolder = "rollout1"

$moduleName = "SQLScriptRun"
Get-Module -Name $moduleName | Remove-Module
Import-Module "$thisPath\$moduleName.psm1"

# $config = Get-SqlConfig -Path (Join-Path $testPath "config")
# $scripts = Get-SqlScript -Path (Join-Path $testPath "scripts\$scriptBatchFolder")

# $scripts | Invoke-SqlScript -config $config -LogDir $logTo
