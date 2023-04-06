# Variables:
$logFile = "LocalAdminRevokeLog.txt"
$ErrorActionPreference = "continue"
# Define current workstation
$currentWorkstation = $env:Computername
# Get the network interface index of the active connection
$NetworkInterfaceIndex = (Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'Public' }).InterfaceIndex
# Define the name of the local administrator account
$adminAccount = $env:Computername +"\Admin"
# Get information about the current user
$currentUser = whoami
# Define the name of the OpenVPN Administrators group
$openvpnGroup = "OpenVPN Administrators"

# Start logging
Start-Transcript -Path $logFile -Append
# Initial tasks
# Set the network category to Private
Set-NetConnectionProfile -InterfaceIndex $NetworkInterfaceIndex -NetworkCategory Private
# Disable built-in Administrator account
Disable-LocalUser -Name "Administrator"
# Enable Remote PowerShell access
Disable-PSRemoting -Force
Enable-PSRemoting -Force

# OpenVPN tasks
# Check if the OpenVPN Administrators group exists, and create it if it doesn't
if (-not (Get-LocalGroup -Name $openvpnGroup)) {
    New-LocalGroup $openvpnGroup
}
# Add the current user to the OpenVPN Administrators group (if not already a member)
if (-not (Get-LocalGroupMember -Group $openvpnGroup  | Where-Object {$_.Name -eq $currentUser})) {
    Add-LocalGroupMember -Group $openvpnGroup -Member $currentUser
}

# Revoke user admin rights
# Remove all other members from the local admin group except for $adminAccount
$adminGroups = @("Administrators", "Administratorzy")
foreach ($group in $adminGroups) {
    if ($localGroup = Get-LocalGroup -Name $group ) {
        $groupMembers = Get-LocalGroupMember -Group $localGroup |
                        Where-Object {$_.ObjectClass -eq "user"} |
                        ForEach-Object {$_.Name}

        foreach ($member in $groupMembers) {
            if ($member -ne $adminAccount) {
                Remove-LocalGroupMember -Group $localGroup -Member $member 
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
            'Administrators list after executed script:' = $line.Trim()
        }
        $members += $member
    }

}

Write-Output $members

# Stop logging
Stop-Transcript

# Convert the output to a formatted table 
$mailbody = $members | Format-Table | Out-String

Start-Sleep -Seconds 5

# Send email with the result
    # Send email with the result
    $emailFrom = ""
    $emailTo = ""
    $subject = "$currentWorkstation - revoke local admin - log"
    $smtpServer = ""
    $smtpPort = 587
    $smtpUser = ""
    $smtpPassword = ""
    $smtpSecure = "SSL"

    $body = "
    <html>
    <head>
    <style>
    body { font-family: Calibri, Candara, Segoe, 'Segoe UI', Optima, Arial, sans-serif }
    pre {font-family: Calibri, Candara, Segoe, 'Segoe UI', Optima, Arial, sans-serif }
    table {
        border-collapse: collapse;
        width: 50%;
    }
    th, td {
        border: 1px solid black;
        padding: 8px;
        text-align: left;
    }
    th {
        background-color: #f2f2f2;
    }</style>
    </head>
    <body>
    <h3>Script was launched on: $currentWorkstation</h3>
    User: <b>$currentUser</b><br>
    Output: 
    <pre>$mailbody</pre>
    
    </body>
    </html>"
    
    $smtp = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtp.EnableSsl = ($smtpSecure -eq "SSL" -or $smtpSecure -eq "TLS")
    $smtp.Credentials = New-Object System.Net.NetworkCredential($smtpUser, $smtpPassword)
    
    $mail = New-Object System.Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body)
    $mail.IsBodyHtml = $true
    
    $smtp.Send($mail)

Send-MailMessage -SmtpServer $smtpServer -From $emailFrom -To $emailTo -Subject $subject -Body $body -Attachment $logFile 

# Remove the $logFile after the email is sent
Remove-Item $logFile -Force