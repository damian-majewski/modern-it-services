# Variables
$RODCAdmin = "RODCAdmin"
$GroupsToAdd = @("RODC_Cached_Accounts", "RODC_Cached_Computers")

# Get the RODCAdmin user object
$RODCAdminObj = Get-ADUser -Identity $RODCAdmin

# Add RODCAdmin to the specified groups
foreach ($Group in $GroupsToAdd) {
    $GroupObj = Get-ADGroup -Identity $Group
    Add-ADGroupMember -Identity $GroupObj -Members $RODCAdminObj
    Write-Host "Added $RODCAdmin to $Group"
}
