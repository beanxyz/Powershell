#Use if only changing for a single clinic
$clinic = "Aberfoyle Hub"
#Begin main script
$clinics = get-content C:\scripts\qld3.txt
foreach ($clinic in $clinics) {
$PM = $clinic + " - Practice Manager"
$HD = $clinic + " - Hospital Director"
$Vet = $clinic + " - Vets"
$ROM = "Regional Operations Manager - SA - 3"
$OD = "odt@vet.partners"
$sendall = "send-all@vet.partners"
$groups = Get-DistributionGroup | Where-Object {$_.name -like $clinic + " - *"}
foreach ($group in $groups) {Set-DistributionGroup -Identity $group.name -AcceptMessagesOnlyFromSendersOrMembers $PM,$HD,$ROM,$OD,$group.name,$sendall}
}

$group = $clinic + " - Hospital Director"
Set-DistributionGroup -Identity $group -AcceptMessagesOnlyFromSendersOrMembers $PM,$ROM,$OD,$group,$sendall

$group = $clinic + " - Practice Manager"
Set-DistributionGroup -Identity $group -AcceptMessagesOnlyFromSendersOrMembers $HD,$ROM,$OD,$group,$sendall

$group = $clinic + " - Vets"
Set-DistributionGroup -Identity $group -AcceptMessagesOnlyFromSendersOrMembers $HD,$ROM,$OD,$group,$sendall


#Test
primarysmtpaddress
Get-DistributionGroup "Hospital Directors - ALL" | Select-Object -ExpandProperty acceptmessagesonlyfromDLMembers

$clinic = "Teams - *"
$PM = "Support Office"
$groups = Get-DistributionGroup | Where-Object {$_.displayname -like $clinic -and $_.grouptype -notlike "*security*"}

foreach ($group in $groups) {Set-DistributionGroup -Identity $group.name -AcceptMessagesOnlyFromSendersOrMembers $PM}


Get-DistributionGroup $group | select "AcceptMessagesOnlyFromSendersOrMembers" | ft
