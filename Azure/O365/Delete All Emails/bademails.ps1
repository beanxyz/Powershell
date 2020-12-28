#FYI You can only delete the email up to 10x per inbox. So if a spam has been sent and there are 10+ in the sent items these will need to be deleted manually.

# Get login credentials and connect to O365
$UserCredential = Get-Credential 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid -Credential $UserCredential -Authentication Basic -AllowRedirection 
Import-PSSession $Session -AllowClobber -DisableNameChecking 
$Host.UI.RawUI.WindowTitle = $UserCredential.UserName + " (Office 365 Security & Compliance Center)"

#Find the bad emails!
$compsearch = read-host -prompt "enter search name"
New-ComplianceSearch -Name "hannah1"  -ExchangeLocation all -ContentMatchQuery subject:"You've a new documents via Drop-box Secure File pending!"
Start-ComplianceSearch -Identity $compsearch 

# wait a minute and view the results
Get-ComplianceSearch -Identity $compsearch
Get-ComplianceSearch -Identity $compsearch | Format-List
(Get-ComplianceSearch -Identity $compsearch).successresults.count

#Delete the bad emails!
New-ComplianceSearchAction -SearchName "23Feb2018" -Purge -PurgeType softdelete

#get results
Get-ComplianceSearchaction -Identity "23Feb2018_Purge"
Get-ComplianceSearchaction -Identity "$searchname`_Purge" | fl