Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

$domainName = "solveler.com"
$computerName = $env:Computername
# Prompt the user for the DSRM password
$dsrmPassword = Read-Host -Prompt "Enter the DSRM password" -AsSecureString

# Prompt the user for the Domain Admin credentials
$domainCred = Get-Credential -Message "Enter the Domain Admin credentials"

# Join the server to the domain
Add-Computer -DomainName $domainName -Credential $domainCred -Force -Restart

# Wait for the server to restart and allow some time for the domain join operation to complete
Start-Sleep -Seconds 120

Import-Module ADDSDeployment
Install-ADDSDomainController `
-AllowPasswordReplicationAccountName @("solveler\Allowed RODC Password Replication Group") `
-NoGlobalCatalog:$false `
-Credential (Get-Credential) `
-CriticalReplicationOnly:$false `
-DatabasePath "C:\Windows\NTDS" `
-DelegatedAdministratorAccountName "solveler\RODCAdmin" `
-DenyPasswordReplicationAccountName @("BUILTIN\Administrators", "BUILTIN\Server Operators", "BUILTIN\Backup Operators", "BUILTIN\Account Operators", "solveler\Denied RODC Password Replication Group") `
-DomainName "solveler.com" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-ReadOnlyReplica:$true `
-ReplicationSourceDC "rwdc1.solveler.com" `
-SiteName "Default-First-Site-Name" `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true


