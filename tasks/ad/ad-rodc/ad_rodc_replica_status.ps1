# Start logging
$logFile = "Check_RODC_replica_status.txt"
Start-Transcript -Path $logFile -Append
# Define current workstation
$currentWorkstation = $env:Computername

$ErrorActionPreference = "continue"

# PowerShell script to verify replication between domain controllers and RODC
Import-Module ActiveDirectory

# Install required tools if not present
$featureCheck = Get-WindowsFeature RSAT-ADDS-Tools
if ($featureCheck.Installed -eq $false) {
    Install-WindowsFeature RSAT-ADDS-Tools
}

# Variables
$rodcName = "rodc1"
$rodc = (Get-ADDomainController -Filter {Name -eq $rodcName}).HostName
$domainControllers = (Get-ADDomainController -Filter *).HostName

# Run repadmin to check replication
Write-Host "Checking replication with repadmin..."
foreach ($dc in $domainControllers) {
    Write-Host "Checking replication between $rodc and $dc"
    repadmin /showrepl $rodc $dc
    Write-Host "Domain Controller: $($dc)" -ForegroundColor Green
    repadmin /replsummary $dc
    repadmin /showutdvec $dc
    repadmin /showchanges $dc
    repadmin /latency $dc
    repadmin /showbackup $dc

    Write-Host "DCDiag Test" -ForegroundColor Yellow
    dcdiag /s:$dc /test:replications /e /q
}

# Run dcdiag to check replication health
Write-Host "Checking replication health with dcdiag..."
dcdiag /test:replications /s:$rodc

# Check for errors
$lastExitCode = $LASTEXITCODE
if ($lastExitCode -eq 0) {
    Write-Host "Replication health check completed successfully."
} else {
    Write-Host "Replication health check failed with exit code: $lastExitCode" -ForegroundColor Red
}

$mailBody = $members | Format-Table | Out-String

# Stop logging
Stop-Transcript

# Send email with the result
    # Send email with the result
    $emailFrom = ""
    $emailTo = ""
    $subject = "$currentWorkstation - check local admin"
    $smtpServer = ""
    $smtpPort = 587
    $smtpUser = ""
    $smtpPassword = ""
    $smtpSecure = "SSL"

# Send email with the result
$smtpClient = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
$smtpClient.EnableSsl = ($smtpSecure -eq "SSL" -or $smtpSecure -eq "TLS")
$smtpClient.Credentials = New-Object System.Net.NetworkCredential($smtpUser, $smtpPassword)

$mail = New-Object System.Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $mailBody)
$mail.IsBodyHtml = $false

try {
    $smtpClient.Send($mail)
    # Remove the $logFile after the email is sent
    Remove-Item $logFile -Force
} catch {
    Write-Host "Error: $($_.Exception.ToString())"
}