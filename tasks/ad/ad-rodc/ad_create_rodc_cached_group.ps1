# Variables
$UserAndComputerOUs = @("OU=OU1,DC=example,DC=com", "OU=OU2,DC=example,DC=com")

# Create the RODC_Cached_Accounts and RODC_Cached_Computers groups
New-ADGroup -Name "RODC_Cached_Accounts" -GroupCategory Security -GroupScope Global -Description "RODC Cached User Accounts"
New-ADGroup -Name "RODC_Cached_Computers" -GroupCategory Security -GroupScope Global -Description "RODC Cached Computer Accounts"

# Get the groups
$CachedAccountsGroup = Get-ADGroup -Identity "RODC_Cached_Accounts"
$CachedComputersGroup = Get-ADGroup -Identity "RODC_Cached_Computers"

foreach ($OU in $UserAndComputerOUs) {
    # Add users from the specified OUs to the RODC_Cached_Accounts group
    Get-ADUser -Filter * -SearchBase $OU -SearchScope Subtree | ForEach-Object { Add-ADGroupMember -Identity $CachedAccountsGroup -Members $_ }

    # Add computers from the specified OUs to the RODC_Cached_Computers group
    Get-ADComputer -Filter * -SearchBase $OU -SearchScope Subtree | ForEach-Object { Add-ADGroupMember -Identity $CachedComputersGroup -Members $_ }
}

