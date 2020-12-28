# Get login credentials 
$UserCredential = Get-Credential 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid -Credential $UserCredential -Authentication Basic -AllowRedirection 
Import-PSSession $Session -AllowClobber -DisableNameChecking 
$Host.UI.RawUI.WindowTitle = $UserCredential.UserName + " (Office 365 Security & Compliance Center)" 

#remove messages fully
New-ComplianceSearchAction -SearchName "dropbox spam" -Purge -PurgeType softdelete

#remove messages to recoverable items folder
New-ComplianceSearchAction -SearchName "Sent a file to you via DropBox kindly Preview" -Purge -PurgeType harddelete
#get status
Get-ComplianceSearchAction


New-ComplianceSearchAction -Purge -PurgeType 

Search-Mailbox -Identity <name> -SearchQuery subject:"Sent a file to you via DropBox kindly Preview" -LogOnly -LogLevel Full

Get-Mailbox -ResultSize unlimited | Search-Mailbox -SearchQuery subject:"Sent a file to you via DropBox kindly Preview"


###
$AzureAdCred = Get-Credential
Connect-AzureAD -Credential $AzureAdCred
Connect-MsolService -Credential $AzureAdCred
#Connects to Exchange Online and loads the PS Cmdlets
$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $AzureAdCred -Authentication "Basic" -AllowRedirection
Import-PSSession $ExchangeSession -AllowClobber