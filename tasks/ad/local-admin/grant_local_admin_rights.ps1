# Variables:
$logFile = "LocalAdminRevokeLog.txt"
# Define current workstation
$currentWorkstation = $env:Computername
$ErrorActionPreference = "continue"
# Get the network interface index of the active connection
$NetworkInterfaceIndex = (Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'Public' }).InterfaceIndex
# Get information about the current user
$currentUser = whoami

# Start logging
Start-Transcript -Path $logFile -Append

# Grant user admin rights
$adminGroups = @("Administrators", "Administratorzy")
foreach ($group in $adminGroups) {
    if ($localGroup = Get-LocalGroup -Name $group ) {
        $groupMembers = Get-LocalGroupMember -Group $localGroup |
                        Where-Object {$_.ObjectClass -eq "user"} |
                        ForEach-Object {$_.Name}

        foreach ($member in $groupMembers) {
            if ($member -ne $adminAccount) {
                Add-LocalGroupMember -Group $localGroup -Member $member 
            }
        }
    }
}

# Get local group members
$adminGroups = @("Administrators", "Administratorzy")
foreach ($group in $adminGroups) {
    $output = (net localgroup $group) | Select-Object -Skip 6
    $members = @()
    foreach ($line in $output) {
        if ($line -match "Polecenie zostało wykonane pomyślnie." -or $line -match "The command completed successfully.") { break }
        $member = New-Object -TypeName PSObject -Property @{
            'Members:' = $line.Trim()
        }
        $members += $member
    }

}

Write-Output $members | Format-Table | Out-String
# Convert the output to a formatted table 
$mailbody = $members | Format-Table | Out-String

# Stop logging
Stop-Transcript

# Send email with the result
    # Send email with the result
    $emailFrom = ""
    $emailTo = ""
    $subject = "$currentWorkstation - grant local admin - log"
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
    Write-Host "Error: $($_.Exception.Message)"
}