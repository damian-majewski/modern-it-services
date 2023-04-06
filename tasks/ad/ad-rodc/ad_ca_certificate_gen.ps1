# Add this function to install the certificate
function Install-Certificate {
  param (
      [Parameter(Mandatory = $true)] [string] $PfxFilePath,
      [Parameter(Mandatory = $true)] [string] $Password
  )

  $Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
  $Cert.Import($PfxFilePath, $Password, "Exportable,PersistKeySet")
  $Store = New-Object System.Security.Cryptography.X509Certificates.X509Store "My", "LocalMachine"
  $Store.Open("ReadWrite")
  $Store.Add($Cert)
  $Store.Close()
}

# Prompt for certificate template
$TemplateChoices = [System.Management.Automation.Host.ChoiceDescription[]] @(
    New-Object System.Management.Automation.Host.ChoiceDescription "&Web Server", "WebServer"
    New-Object System.Management.Automation.Host.ChoiceDescription "&Domain Controller", "DomainController"
    New-Object System.Management.Automation.Host.ChoiceDescription "&Windows Server", "WindowsServer"
    # Add more templates here if needed
)

$TemplateChoiceIndex = $host.UI.PromptForChoice("Select Certificate Template", "Choose a certificate template:", $TemplateChoices, 0)
$CertTemplate = $TemplateChoices[$TemplateChoiceIndex].HelpMessage

# Prompt for certificate type
$CertTypeChoices = [System.Management.Automation.Host.ChoiceDescription[]] @(
    New-Object System.Management.Automation.Host.ChoiceDescription "&Single Domain", "SingleDomain"
    New-Object System.Management.Automation.Host.ChoiceDescription "&Wildcard", "Wildcard"
)

$CertTypeChoiceIndex = $host.UI.PromptForChoice("Select Certificate Type", "Choose a certificate type:", $CertTypeChoices, 0)
$CertType = $CertTypeChoices[$CertTypeChoiceIndex].HelpMessage

# Prompt for SAN entries
$DomainName = Read-Host -Prompt "Enter the domain name (e.g., example.com)"
$HostName = Read-Host -Prompt "Enter the host name (e.g., server1)"

if ($CertType -eq "Wildcard") {
    $SubjectName = "CN=*.$DomainName"
    $SAN = "DNS=*.$DomainName"
} else {
    $SubjectName = "CN=$HostName.$DomainName"
    $SAN = "DNS=$HostName.$DomainName"
}



# Request a new certificate from the CA
$InfFile = @"
[Version]
Signature = "$Windows NT$"
[NewRequest]
Subject = "$SubjectName"
KeyLength = 2048
KeySpec = 1
KeyUsage = 0xA0
Exportable = true
MachineKeySet = true
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
RequestType = PKCS10
[Extensions]
2.5.29.17 = "{text}"
_continue_ = "dns=$SAN"
[RequestAttributes]
CertificateTemplate = $CertTemplate
"@

$InfFile | Set-Content -Path "Request.inf"
certreq.exe -new "Request.inf" "Request.req"

# Submit the certificate request to the CA
$CAName = Read-Host -Prompt "Enter the CA server name (e.g., ca.example.com)"
certreq.exe -submit -config "$CAName\My CA" "Request.req" "Cert.cer"

# Export the issued certificate with its private key to a PFX file
$PfxPassword = Read-Host -Prompt "Enter a password to protect the PFX file" -AsSecureString
$PfxPasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PfxPassword))
certreq.exe -accept -user -f "Cert.cer"
$CertThumbprint = (Get-PfxCertificate -FilePath "Cert.cer").Thumbprint
$Cert = Get-ChildItem -Path "Cert:\CurrentUser\My\$CertThumbprint"
$Cert | Export-PfxCertificate -FilePath "Cert.pfx" -Password $PfxPassword -Force

# Install the certificate
Install-Certificate -PfxFilePath "Cert.pfx" -Password $PfxPasswordText

# Clean up files
Remove-Item "Request.inf"
Remove-Item "Request.req"
Remove-Item "Cert.cer"
Remove-Item "Cert.pfx"

Write-Host "Certificate exported to $Cert"


