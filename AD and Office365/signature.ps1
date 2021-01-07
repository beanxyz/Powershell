Get-ADOrganizationalUnit "2.011 HQ"
Get-ADOrganizationalUnit "OU=2.011 HQ,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au" | get-aduser

"OU=2.013 IT Users,OU=2.013 IT,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"

$users = Get-ADUser -SearchBase "OU=2.011 HQ,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au" -filter *
foreach ($user in $users) {
Set-ADUser -Identity "$user" -OfficePhone "(02) 9817 2887" -Office "VetPartners Support Office" -StreetAddress "Unit 1B, 277 Lane Cove Rd" -City "Macquarie Park" -State "NSW" -PostalCode "2113" -Company "VetPartners" -HomePage "www.vet.partners"
}

$users = Get-ADUser -SearchBase "OU=2.013 IT Users,OU=2.013 IT,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au" -filter *
foreach ($user in $users) {
Set-ADUser -Identity "$user" -Office "VetPartners Support Office" -StreetAddress "Unit 1, 277 Lane Cove Rd" -City "Macquarie Park" -State "NSW" -PostalCode "2113" -Company "VetPartners" -HomePage "www.vet.partners"
}

$users = Get-ADUser -SearchBase "OU=2.013 IT Users,OU=2.013 IT,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au" -filter *
foreach ($user in $users) {
Set-ADUser -Identity "$user" -StreetAddress "Unit 1, 277 Lane Cove Rd"
}

$users = Get-ADUser -SearchBase "OU=2.011 HQ,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au" -filter *
foreach ($user in $users) {
Set-ADUser -Identity "$user" -HomePage "vetpartners.com.au"
}

