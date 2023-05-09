# Import the CSV files
$UserCsvFilePath = "NewUsers.csv"
$GroupCsvFilePath = "Groups.csv"
$O365GroupCsvFilePath = "O365Groups.csv"
$UserList = Import-Csv -Path $UserCsvFilePath
$GroupList = Import-Csv -Path $GroupCsvFilePath
$O365GroupList = Import-Csv -Path $O365GroupCsvFilePath

# Connect to Azure AD
$Credential = Get-Credential
Connect-AzureAD -Credential $Credential
# Check if the CSV has the correct number of columns
if ($UserList[0].PSObject.Properties.Count -eq 7) {

    # Process each group in the CSV file
    foreach ($Group in $GroupList.GroupName) {
        # Check if the group exists; if not, create it
        if (-not (Get-ADGroup -Identity $Group -ErrorAction SilentlyContinue)) {
            New-ADGroup -Name $Group -GroupScope Global -GroupCategory Security
        }
    }

    # Process each user in the CSV file
    foreach ($User in $UserList) {
        # Create a new user
        $SecurePassword = ConvertTo-SecureString -AsPlainText $User.Password -Force
        New-ADUser -Name $User.DisplayName -GivenName $User.FirstName -Surname $User.LastName -UserPrincipalName $User.UserPrincipalName -SamAccountName $User.Username -AccountPassword $SecurePassword -Enabled $true -Path $User.Path

        # Get the user and group objects
        $NewUser = Get-ADUser -Identity $User.Username
        $CachedAccountsGroup = Get-ADGroup -Identity "RODC_Cached_Accounts"

        # Add the new user to the RODC_Cached_Accounts group
        Add-ADGroupMember -Identity $CachedAccountsGroup -Members $NewUser
    }

        # Assign a mailbox to the user in Office 365
        Set-AzureADUser -ObjectId $User.UserPrincipalName -UsageLocation "US"
        Enable-AzureADUser -ObjectId $User.UserPrincipalName

        # Assign the user an Office 365 license
        $LicenseSku = Get-AzureADSubscribedSku | Where-Object { $_.SkuPartNumber -eq "ENTERPRISEPACK" }
        $LicenseAssignment = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
        $LicenseAssignment.SkuId = $LicenseSku.SkuId
        Set-AzureADUserLicense -ObjectId $User.UserPrincipalName -AddLicenses @($LicenseAssignment)

        # Add the user to the specified Office 365 groups
        foreach ($O365Group in $O365GroupList) {
            switch ($O365Group.GroupType) {
                "DistributionGroup" {
                    Add-AzureADGroupMember -ObjectId (Get-AzureADGroup -SearchString $O365Group.GroupName).ObjectId -RefObjectId (Get-AzureADUser -ObjectId $User.UserPrincipalName).ObjectId
                }
                "Team" {
                    # Retrieve the group ID and add the user to the team
                    $GroupId = (Get-AzureADGroup -SearchString $O365Group.GroupName).ObjectId
                    Add-AzureADGroupMember -ObjectId $GroupId -RefObjectId (Get-AzureADUser -ObjectId $User.UserPrincipalName).ObjectId
                }
            }
        }

} else {
    Write-Host "The CSV file has an incorrect number of columns. Please check the file and try again."
}
