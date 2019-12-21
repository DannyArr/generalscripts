#Set up PoSh proxy and modules on local machine.

$proxy = 'http://dc1psg1.hiscox.com:8080'

[array]$lines = @(
    "[system.net.webrequest]::defaultwebproxy = new-object system.net.webproxy('$proxy')",
    '[system.net.webrequest]::defaultwebproxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials',
    '[system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true'
)

[array]$modules = @(
    'Pester',
    'SqlServer',
    'SqlServerDsc',
    'PSReadLine'
)

if ( !(Test-Path $PROFILE.AllUsersAllHosts -PathType Leaf) ) {
    New-Item -Path $PROFILE.AllUsersAllHosts -Type File 
}
else {
    $profileContent = Get-Content $PROFILE.AllUsersAllHosts
    #Remove previous entries of proxy settings
    $profileContent | Where-Object { $_ -notmatch '\[system.net.webrequest\]\:\:defaultwebproxy' } |
       Set-Content $PROFILE.AllUsersAllHosts
}

foreach ($line in $lines) {
    Add-Content -Path $PROFILE.AllUsersAllHosts -Value $line
}

#reload the profile
. $Profile.AllUsersAllHosts

Write-Output "Installing modules..."
$installedModules = get-module -ListAvailable
foreach ($module in $modules) {
    if($installedModules | Where-Object {$_.Name -eq $module}) {
        Write-Output "Module $module already installed."
    }
    else {
        Write-Output "installing PS module: $module"
        Install-Module $module -Force
    }
}

