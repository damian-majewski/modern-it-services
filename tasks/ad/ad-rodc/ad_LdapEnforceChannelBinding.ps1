$addspath = "HKLM:\System\CurrentControlSet\Services\NTDS\Parameters"
$parameterName = "LdapEnforceChannelBinding"

try {
    $adDsValue = Get-ItemPropertyValue -Path $addspath -Name $parameterName
    if ($adDsValue -eq 1) {
        Write-Host "AD DS LdapEnforceChannelBinding is set to 1."
    } else {
        Write-Host "AD DS LdapEnforceChannelBinding is not set to 1. Current value: $adDsValue"
    }
} catch {
    Write-Host "Error: Could not retrieve AD DS LdapEnforceChannelBinding value. $_"
}

