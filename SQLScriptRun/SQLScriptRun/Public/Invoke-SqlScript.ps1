function Invoke-SqlScript {
    <#
        .SYNOPSIS
        Executes a .sql script
        .DESCRIPTION
        Will run a SQL script using SQLCMD.EXE. Any SQL errors will terminate the batch.
        .EXAMPLE
        $scripts | Invoke-SqlScript -Config $config -LogDir $logTo
        .EXAMPLE
        Invoke-SqlScript -ScriptPath $script -Config $config -LogDir $logTo
        .PARAMETER ScriptPath
        The full path to the script file. Can be piped.
        .PARAMETER Config
        A config object as per the one created by Get-SqlConfig. This will contain the connection string and any sqlcmd variables.
        .PARAMETER LogDir
        Optional location of the directory to put SQLCMD outputs. Will default to the folder where the script being executed is.
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$ScriptPath,

        [parameter(Mandatory=$true)]
        [PSCustomObject]$Config,

        [string]$LogDir
    )

    begin{
        Write-Output "Connection: $config.ConnectionString"
        
        [array]$commonArgs = @(
            "-S",
            $Config.ConnectionString
        )

        $sqlcmdVarNames = ($config | Get-Member -Name "sqlcmd_*").Name
        
        if (!$LogDir) {
            $rootPath = Split-Path $ScriptPath
            $LogDir = Join-Path $rootPath "DeployLogs"
        }
        
        if( !(Test-Path $LogDir) ){
            New-Item -ItemType Directory -Path $LogDir
        }
    }

    process{

        $logFilePath = Join-Path $LogDir "$(Split-Path $ScriptPath -Leaf).log"
        $scriptFile = Split-Path $ScriptPath -Leaf

        $arg = $commonArgs
        $arg += @(
            "-b",
            "-i",
            "`"$($ScriptPath)`"",
            "-o",
            "`"$logFilePath`""

        )
        $arg += $sqlcmdVarNames | ForEach-Object {
            "-v"
            "$($_.replace('sqlcmd_',''))=$($config.$_)"
        }

        try {
            Write-Output $("Executing T-SQL script: $scriptFile")
            & 'SQLCMD.EXE' @arg

            if ($LASTEXITCODE -ne 0) {
                throw "Error with SQL script at $ScriptPath. Terminating process. Check log for further info."
            }
            Write-Output $("...Success")
        }
        catch{
            Write-Error $_
            break
        }
    }

    end{
        Write-Output "Done!"
    }
}
