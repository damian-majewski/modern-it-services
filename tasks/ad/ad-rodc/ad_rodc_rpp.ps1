# Variables
$RODCName = "rodc1"
$AllowedGroup = "Allowed_PRP_Group"
$DeniedGroup = "Denied_PRP_Group"

# Get the RODC object
$RODC = Get-ADDomainController -Identity $RODCName

# Display current PRP settings before making changes
Write-Host "Current PRP settings:"
Get-ADAccountResultantPasswordReplicationPolicy -Server $RODC | Format-Table -Property Allowed, Denied -AutoSize

# Get the Allowed and Denied groups
$AllowedGroupObj = Get-ADGroup -Identity $AllowedGroup
$DeniedGroupObj = Get-ADGroup -Identity $DeniedGroup

# Configure the Allowed List for PRP
Set-ADAccountResultantPasswordReplicationPolicy -Identity $AllowedGroupObj -Server $RODC -Allowed

# Configure the Denied List for PRP
Set-ADAccountResultantPasswordReplicationPolicy -Identity $DeniedGroupObj -Server $RODC -Denied

# Display PRP settings after making changes
Write-Host "PRP settings after changes:"
Get-ADAccountResultantPasswordReplicationPolicy -Server $RODC | Format-Table -Property Allowed, Denied -AutoSize
