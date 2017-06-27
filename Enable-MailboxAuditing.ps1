
$username = "yuan.li@aus.ddb.com"
$password = "Goat201510"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd



$ExoSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $creds -Authentication Basic -AllowRedirection
Import-PSSession $ExoSession



$users=get-mailbox -Filter {AuditEnabled -eq $false} | select name, alias, auditenabled, auditlogagelimit, distinguishedname
foreach($user in $users){

   Set-Mailbox $user.distinguishedname -AuditEnabled $true -AuditLogAgeLimit 365 -AuditOwner Create,HardDelete,MailboxLogin,MoveToDeletedItems,SoftDelete,Update

#Double-Check It!

}