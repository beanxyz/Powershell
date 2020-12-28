# Get login credentials and connect to O365
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber -DisableNameChecking
$Host.UI.RawUI.WindowTitle = $UserCredential.UserName + " (Office 365 Security & Compliance Center)"
$searchname = "kateTang"

New-ComplianceSearch -Name $searchname -ExchangeLocation all -ContentMatchQuery subject:"Recall: Email Signature"
Start-ComplianceSearch -Identity $searchname

Get-ComplianceSearch -Identity $searchname

New-ComplianceSearchAction -SearchName $searchname -Purge -PurgeType softdelete