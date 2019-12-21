function Get-SqlConfig {
    <#
        .SYNOPSIS
        Get config from ScriptRun config file
        .DESCRIPTION
        Returns config for the running host from the config JSON file.
        .EXAMPLE
        Get-SqlConfig  -Path "C:\ScriptRun\config"
        .PARAMETER Path
        The full path to the folder that contains the config file
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$Path
    )

    $configFile = Join-Path $Path 'config.json'
    $configJson = Get-Content -Path $configFile | Out-String
    $configFull = ConvertFrom-Json -InputObject $configJson
    
    $config = $configFull.Hosts | Where-Object {$_.Host -eq $Env:COMPUTERNAME}
    $config
}
