#First Step - Connect to Exchange and Azure
$creds = get-credential
Connect-AzureAD -Credential $creds
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $creds  -Authentication Basic -AllowRedirection
Import-PSSession $Session

#Test data
$nosent = @{
firstname = "Abigail"
lastname = "Vaughan"
fullname = "Abigail Vaughan"
}
$firstname = "Abigail"
$lastname = "Vaughan"
$nosent.add($firstname,$lastname)
$fullname = $firstname + " " + $lastname

#Second Step - Import the list of users with no sent items
$nosents = Import-Csv C:\scripts\Final-NoSent.csv

#Go through each line in the spreadsheet and get the groups that they are a member of. Then create the account. Then add the new account back into the groups.
foreach ($nosent in $nosents) {
$firstname = $nosent.firstname
$lastname = $nosent.surname
$fullname = $nosent.fullname
$fullname2 = $firstname + "."+$lastname
$fullname1 = "1" + $nosent.fullname
$groups = Get-AzureADUser -SearchString $fullname | Get-AzureADUserMembership | select * | Where-Object {$_.mailenabled -eq "True"}
$ID = Get-AzureADUser -SearchString $fullname | select userprincipalname
Remove-ADUser -Identity $fullname2

New-MailUser -name $fullname1 -FirstName $firstname -LastName $lastname -ExternalEmailAddress $nosent.email -MicrosoftOnlineServicesID $ID -Password (ConvertTo-SecureString -String 'P@55V3ts!!@@' -AsPlainText -Force)
Start-Sleep 5

write-host "Now processing distribution groups"
foreach ($group in $groups) {Add-DistributionGroupMember -Identity $group.objectid -Member $fullname1}
Write-Host "now processing O365 Groups"
foreach ($group in $groups) {Add-UnifiedGroupLinks -Identity $group.DisplayName -LinkType members -links $fullname1}

}




get-ADUser -Identity Abigail.vaughan

$ID = "1" + $ID.UserPrincipalName

foreach ($group in $groups) {Add-DistributionGroupMember -Identity $object.objectid -Member "Geoff Test123"}
New-MailUser -name "Geoff Test123" -ExternalEmailAddress rosege000@gmail.com -MicrosoftOnlineServicesID gr123@vetpartners.com.au -Password (ConvertTo-SecureString -String 'P@ssw0rd1' -AsPlainText -Force)
Get-AzureADUser -SearchString $fullname | Get-AzureADUserMembership
Get-AzureADUser -SearchString $fullname | Get-UnifiedGroup


Get-MailUser -Identity "Geoff Test123" | select *
-FirstName Geoff -LastName Test123

Add-DistributionGroupMember -Identity "referral team" -Member "Geoff Test123"

Add-MsolGroupMember -GroupObjectId "6d304fe6-868b-4acd-a0ff-1245be15635e" -GroupMemberObjectId "b0ee788f-e79e-4373-9d8b-c3cb253edb14"

#This will add a user to O365 group
Add-UnifiedGroupLinks -Identity "NSVH - Vets" -LinkType members -links "gr123@vetpartners.com.au"
#This will add to a std distribution group
Add-DistributionGroupMember -Identity "NSVH - Vets" -Member "Geoff Test123"
