#
# PowerShell script for AD FS Deployment
# Launch the script on DC
#

Import-Module ADFS

# Get the credential used for performaing installation/configuration of ADFS
$installationCredential = Get-Credential -Message "Enter the credential for the account used to perform the configuration."

# Get the credential used for the federation service account
$serviceAccountCredential = Get-Credential -Message "Enter the credential for the Federation Service Account."

Install-AdfsFarm `
-CertificateThumbprint:"D061A14B196931D6264D341805A9B400784C6BAE" `
-Credential:$installationCredential `
-FederationServiceDisplayName:"solveler-RODC" `
-FederationServiceName:"rwdc1.solveler.com" `
-ServiceAccountCredential:$serviceAccountCredential