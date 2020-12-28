$practicename = "Eastside Veterinary Botany Rd"
$practicename = "Dernancourt"
$practicename = "GoldenGrove"
$practicename = "MawsonLakes"
$practicename = "Northgate"
$practicename = "Ridgehaven"
$practicename = "SalisburyPark"

$practicename1 = "Eastside Veterinary Botany Rd"
$practicename1 = "Dernancourt"
$practicename1 = "Golden Grove"
$practicename1 = "Mawson Lakes"
$practicename1 = "Northgate"
$practicename1 = "Ridgehaven"
$practicename1 = "Salisbury Park"

$practices = get-content .\vetsnsw1.txt
foreach ($practicename1 in $practices) {
$practicename = $practicename1.Replace(' ','')
write-host "Processing $practicename1"

#Get OU DSN
$PN = ("*" + $practicename1 -split (" ",2))[0]
$PN = $PN + "*"
$OU = (Get-ADOrganizationalUnit -Filter {name -like $PN}).distinguishedname  | select -First 1

#Set email domain
$email = (get-aduser -SearchBase $OU -Filter * | select -First 1).userprincipalname
$domain = $email.Split("{@}")[1]
#$domain = "@" + $domain

#set the email address
$smtp1 = "Nurses" + "@" + $domain
$smtp2 = "Practicemanager" + "@" + $domain
$smtp3 = "Vets-all" + "@" + $domain
$smtp4 = "Hospitaldirector" + "@" + $domain
$smtp5 = "Staff" + "@" + $domain

#Create Groups
New-ADGroup -Path $ou -OtherAttributes @{'mail'=$smtp1} -Name "Nurses - $practicename1" -GroupScope Universal -GroupCategory Security
New-ADGroup -Path $ou -OtherAttributes @{'mail'=$smtp2} -Name "Practice Manager - $practicename1" -GroupScope Universal -GroupCategory Security
New-ADGroup -Path $ou -OtherAttributes @{'mail'=$smtp3} -Name "Vets - $practicename1" -GroupScope Universal -GroupCategory Security
New-ADGroup -Path $ou -OtherAttributes @{'mail'=$smtp4} -Name "Hospital Director - $practicename1" -GroupScope Universal -GroupCategory Security
New-ADGroup -Path $ou -OtherAttributes @{'mail'=$smtp5} -Name "Staff - $practicename1" -GroupScope Universal -GroupCategory Security

#Get the staff group in AD
$staffgroup = Get-ADGroup -Filter {name -like 'Staff*'} -SearchBase $OU

}

# Add staff to group
get-aduser -Filter * -SearchBase $OU | % {Add-ADGroupMember -Identity $staffgroup -Members $_}

}


$practicename1 = "Coastal & Mandurah South"

| select -Skip 1

#set the email address
$smtp1 = "Nurse-" + $practicename + "@" + $domain
$smtp2 = "Practicemanager-" + $practicename + "@" + $domain
$smtp3 = "Vet-" + $practicename + "@" + $domain
$smtp4 = "Hospitaldirector-" + $practicename + "@" + $domain
$smtp5 = "Staff-" + $practicename + "@" + $domain