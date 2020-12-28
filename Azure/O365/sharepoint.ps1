$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking