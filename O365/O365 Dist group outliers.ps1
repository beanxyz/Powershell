#Add missed member
Add-DistributionGroupMember –Identity $teamdisplayname –Member amber@vetcare.net.nz
Add-DistributionGroupMember –Identity $vetsdisplayname –Member kristina.Harris@hubvet.com.au
Add-DistributionGroupMember -Identity $nursedisplayname -Member Sarah.Fuller@hubvet.com.au



#Rename existing group that is conflicting
Get-DistributionGroup -Identity vets@eppingvet.com.au
Set-DistributionGroup  -Identity vets@eppingvet.com.au -Name "Epping - Vets Group" -DisplayName "Epping - Vets Group"
Set-DistributionGroup  -Identity vets@guildfordvet.com.au -Name "Guildford - Vets Group"

Set-DistributionGroup  -Identity ftnurses@figtreevet.com.au -Name "Figtree - Nurses Group"

$members = Get-DistributionGroupMember -Identity vets@vetfriends.com.au

New-DistributionGroup -Name $vetsdisplayname -DisplayName $vetsdisplayname  -Alias "$aliasVE" -ManagedBy kaye.hannan@vetpartners.com.au -PrimarySmtpAddress vets@bexleyvet.com.au -MemberDepartRestriction closed

##
$oudn = "OU=2.017 Ourimbah,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"
$newusers = get-aduser -SearchBase $oudn -filter *
foreach ($newuser in $newusers) {Add-DistributionGroupMember –Identity $teamdisplayname –Member $newuser.userprincipalname}
