. .\New-SelfSignedCertificateEx.ps1

New-SelfSignedCertificateEx -Subject "CN=${ENV:ComputerName}" `
    -EKU 'Document Encryption' `
    -KeyUsage 'KeyEncipherment, DataEncipherment' `
    -SAN ${ENV:ComputerName} `
    -FriendlyName 'DSC Credential Encryption certificate' `
    -StoreLocation 'LocalMachine' `
    -KeyLength 2048 `
    -AlgorithmName 'RSA' `
    -SignatureAlgorithm 'SHA256'

$Cert = Get-ChildItem -Path cert:\LocalMachine\My `
    | Where-Object {
        ($_.FriendlyName -eq 'DSC Credential Encryption certificate') `
        -and ($_.Subject -eq "CN=${ENV:ComputerName}")
    } | Select-Object -First 1

$cert | Export-Certificate -FilePath "$env:temp\DscPublicKey.cer" -Force

$CertToExportInBytesForCERFile = $Cert.export("Cert")
[system.IO.file]::WriteAllBytes("$env:temp\DscPublicKey.cer", $CertToExportInBytesForCERFile)

