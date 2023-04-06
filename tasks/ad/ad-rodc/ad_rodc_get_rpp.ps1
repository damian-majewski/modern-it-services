# Run on domain controller
# Variables
$RODCName = "rodc1"
# Display PRP settings after making changes
Write-Host "PRP settings after changes:"
Get-ADAccountResultantPasswordReplicationPolicy -Server $RODC | Format-Table -Property Allowed, Denied -AutoSize