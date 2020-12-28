#get email addresses of users from OU - you could also add an export to csv at the end of this
$users = Get-ADUser -Filter * -SearchBase "OU=4.001 James Street Veterinary Hospital,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au" | select userprincipalname



#Section to assign licenses to users from text file containing their email addresses retrieved from the step above
$users = get-content C:\Users\xgrose\Documents\jsv.csv
Foreach ($user in $users) {

write-host "now processing $users"
    Set-MsolUser -UserPrincipalName $user -UsageLocation AU
    Set-MsolUserLicense -UserPrincipalName $user -AddLicenses "vetpartners:EXCHANGESTANDARD"
    }