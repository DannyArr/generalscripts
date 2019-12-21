Describe 'Module tests' {
    [array]$functions = @(
         'Get-SqlConfig'
        ,'Get-SqlScript'
        ,'Invoke-SqlScript'
    )


    foreach ($function in $functions) {
        Context "Test function $function" {

            $rootPath = (Get-Item -Path $PSScriptRoot).Parent.FullName

            $file = "$rootPath/SQLScriptRun/Public/$function.ps1"

            It "$function.ps1 file exists" {
                $file | Should Exist
            }

            It "Contains help block" {
                $file | Should FileContentMatchExactly "    <#"
                $file | Should FileContentMatchExactly "    #>"
            }

            It "Contains .SYNOPSIS" {
                $file | Should FileContentMatchExactly "        .SYNOPSIS"
            }

            It "Contains .DESCRIPTION" {
                $file | Should FileContentMatchExactly "        .DESCRIPTION"
            }

            It "Contains .EXAMPLE" {
                $file | Should FileContentMatchExactly "        .EXAMPLE"
            }
        }

        Context "Test Files" {

            $testFile = "$rootPath/Tests/$function.Tests.ps1"

            It "Has test file " {
                $testFile | Should Exist
            }

        }
    }

}