get-aduser -Filter * -Properties emailaddress | select emailaddress

$user1 = get-aduser hayley.beggs
$email1 = $user1.emailaddress
"hayley.beggs@eppingvet.com.au"

get-aduser hayley.beggs | Set-ADUser -EmailAddress hayley.beggs@eppingvet.com.au


$users = get-aduser -Filter * | Where-Object {$_.userprincipalname -like "*lincolnvet.com.au"}
foreach ($user in $users)
{
write-host "Now Processing $user"
$lowerupn = ((Get-ADUser $user.samaccountname -Properties emailaddress | select emailaddress).emailaddress).tolower()
$user | Set-ADUser -EmailAddress $lowerupn
}


((Get-ADUser simon.baker -Properties emailaddress | select emailaddress).emailaddress).tolower()
($email).tolower
