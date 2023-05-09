# Variables
$RODCName = "rodc1"
$AllowedGroups = @("RODC_Cached_Accounts", "RODC_Cached_Computers")

# Get the RODC object
$RODC = Get-ADDomainController -Identity $RODCName

# Display current PRP settings before making changes
Write-Host "Current PRP settings:"
Get-ADAccountResultantPasswordReplicationPolicy -Server $RODC | Format-Table -Property Allowed, Denied -AutoSize

# Configure the Allowed List for PRP
foreach ($AllowedGroup in $AllowedGroups) {
    $AllowedGroupObj = Get-ADGroup -Identity $AllowedGroup
    Add-ADDomainControllerPasswordReplicationPolicy -Identity $RODC -AllowedList $AllowedGroupObj
}

# Display PRP settings after making changes
Write-Host "PRP settings after changes:"
Get-ADAccountResultantPasswordReplicationPolicy -Server $RODC | Format-Table -Property Allowed, Denied -AutoSize
