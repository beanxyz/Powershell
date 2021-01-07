#Install the office 365 module

$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri “https://ps.outlook.com/powershell/” -Credential $AzureAdCred -Authentication Basic -AllowRedirection
Import-PSSession $session

#Begin script

$datas = import-csv C:\Users\xgrose\Documents\Vets4pets.csv

foreach ($data in $datas) {
$un = $data.username + "@vets4pets.com.au"
$email = $data.email
Set-Mailbox -Identity $un -ForwardingSmtpAddress $email -DeliverToMailboxAndForward $true
}




