# Start logging
$logFile = "CheckLocalAdmin.txt"
Start-Transcript -Path $logFile -Append
# Define current workstation
$currentWorkstation = $env:Computername

$ErrorActionPreference = "continue"

$adminGroups = @("Administrators", "Administratorzy")
$members = @()
foreach ($group in $adminGroups) {
    try {
        $groupDetails = Get-LocalGroup -Name $group
        $groupMembers = Get-LocalGroupMember -Group $groupDetails
        
        foreach ($member in $groupMembers) {
            $memberDetails = Get-LocalUser -Name $member.Name 
            $memberInfo = New-Object -TypeName PSObject -Property @{
                'Name' = $memberDetails.Name
                'FullName' = $memberDetails.FullName
                'Description' = $memberDetails.Description
                'Enabled' = $memberDetails.Enabled
                'LastLogon' = $memberDetails.LastLogon
                'SID' = $memberDetails.SID
            }
            $members += $memberInfo
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
}
Write-Output $members | Format-Table | Out-String
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
    Write-Host "Error: $($_.Exception.Message)"
}
