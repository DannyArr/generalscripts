#Load the module
$rootPath = (Get-Item -Path $PSScriptRoot).Parent.FullName
$moduleName = 'SQLScriptRun'

$modulePath = Join-Path $rootPath "$moduleName\$moduleName.psm1"
if(Get-Module -Name $moduleName){
    Remove-Module $moduleName
}
Import-Module $modulePath

#Run the tests
Invoke-Pester