# Script to set password to be changed in O365

$users = Import-Csv "C:\Users\xgrose\Downloads\user_details.csv"
foreach ($user in $users) {
write-host "now processing $user"
$fullname = $user.firstname + " " + $user.lastname
$changepl = Get-ADUser -Filter {Name -eq $fullname}
$upn = $changepl.UserPrincipalName
Set-MsolUserPassword -UserPrincipalName $UPN -NewPassword "V3tP@rtners" -ForceChangePassword $true
#Set-ADUser $changepl -ChangePasswordAtLogon $false
#Set-ADUser $changepl -Add @{mailNickname=$fullname}
}

$upn = "megan.bentley@vets4pets.com.au"
Set-MsolUserPassword -UserPrincipalName $UPN -NewPassword "V3tP@rtners" -ForceChangePassword $true


$t1 = "Cristina.LealRigueira"