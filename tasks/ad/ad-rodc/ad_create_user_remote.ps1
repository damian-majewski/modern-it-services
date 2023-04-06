# Define the target domain controller's hostname or IP address
$domainController = "solveler.com"

# Define RODC Administrator account properties
$rodcAdminName = "RODCAdmin"
$rodcAdminPassword = ConvertTo-SecureString "Rubber Clambake Compel" -AsPlainText -Force
$rodcAdminDisplayName = "RODC Delegated Administrator"
$rodcAdminDescription = "Account to manage RODC"

# Connect to the domain controller
Enter-PSSession -ComputerName $domainController -Credential (Get-Credential)

# Create the user account
New-ADUser -Name $userName -AccountPassword $securePassword -Enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false -SamAccountName $userName

# Add the new user to the RODC Administrators group
Add-ADGroupMember -Identity $rodcAdminsGroup -Members $userName

# Grant the new user permissions on the RODC account
$rodc = Get-ADDomainController -Filter {Name -eq "your-rodc-name"}
$rodcAdmin = Get-ADUser -Identity $userName

$identity = New-Object System.Security.Principal.SecurityIdentifier($rodcAdmin.SID)
$rights = [System.DirectoryServices.ActiveDirectoryRights]::ReadProperty -bor [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty
$allowType = [System.Security.AccessControl.AccessControlType]::Allow

$accessRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, $rights, $allowType)
$rodc.PSObject.Properties['ntSecurityDescriptor'].Value.AddAccessRule($accessRule)
Set-ADDomainController -Instance $rodc

# Disconnect from the domain controller
Exit-PSSession