function Get-SqlScript {
    <#
        .SYNOPSIS
        Get SQL script paths within a folder
        .DESCRIPTION
        List full paths of all SQL scripts files within a given folder in ascending order
        .EXAMPLE
        Get-SqlScript -Path "C:\ScriptRun\SQLScripts"
        .PARAMETER Path
        The full path to the folder holding the scripts
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$Path
    )

    $scripts = (Get-ChildItem -Path $Path -File -Recurse -Filter "*.sql").FullName | 
    Sort-Object

    $scripts
}
