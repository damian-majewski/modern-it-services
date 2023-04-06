# Identify PDC emulator
netdom query fsmo

# List the DRS endpoints
Get-AdfsEndpoint | where { $_.Protocol -eq "Devices" }

ldifde -f output.ldif -s RODC_FQDN_or_IP -d "DC=yourdomain,DC=com" -r "(sAMAccountName=TestUser)" -l "dn,sAMAccountName"
