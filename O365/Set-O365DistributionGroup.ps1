$userid='geoff.rose@vet.partners'
$pass = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000bbf3c70af1b1c945bd4b2b6799b8b4850000000002000000000003660000c0000000100000008d3dfc679101bbad190e0563c9e585520000000004800000a0000000100000003ea4be1e877ed07993b38b61d21fa28718000000f40980dffbf64694246ce85440d6624f510e6a0cb31522ed14000000e1f36f89caf3f711d4b06a26b6a7c7439a8f206b" | ConvertTo-SecureString
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userid, $pass
$creds = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $creds  -Authentication Basic -AllowRedirection
Import-PSSession $Session

#Variables
$clinicname = "Epping"
$groupname = "Epping"
$alias = $clinicname -replace '\s',''
$aliasHD = "$alias-HD"
$aliasNU = "$alias-NU"
$aliasPM = "$alias-PM"
$aliasTM = "$alias-TM"
$aliasVE = "$alias-VE"


#Variables for the groups
$hddisplayname = $clinicname + " - Hospital Director"
$nursedisplayname = $clinicname + " - Nurses"
$pmdisplayname = $clinicname + " - Practice Manager"
$teamdisplayname = $clinicname + " - Team"
$vetsdisplayname = $clinicname + " - Vets"
$emaildom = "@eppingvet.com.au"
$managedby = "kaye.hannan@vetpartners.com.au"

#Create Distribution Groups
New-DistributionGroup -Name $hddisplayname -DisplayName $hddisplayname  -Alias "$aliasHD" -ManagedBy $managedby -PrimarySmtpAddress $aliasHD$emaildom -MemberDepartRestriction closed
New-DistributionGroup -Name $nursedisplayname -DisplayName $nursedisplayname  -Alias "$aliasNU" -ManagedBy $managedby -PrimarySmtpAddress $aliasNU$emaildom -MemberDepartRestriction closed
New-DistributionGroup -Name $pmdisplayname -DisplayName $pmdisplayname  -Alias "$aliasPM" -ManagedBy $managedby -PrimarySmtpAddress $aliasPM$emaildom -MemberDepartRestriction closed
New-DistributionGroup -Name $teamdisplayname -DisplayName $teamdisplayname  -Alias "$aliasTM" -ManagedBy $managedby -PrimarySmtpAddress $aliasTM$emaildom -MemberDepartRestriction closed
New-DistributionGroup -Name $vetsdisplayname -DisplayName $vetsdisplayname  -Alias "$aliasVE" -ManagedBy $managedby -PrimarySmtpAddress $aliasVE$emaildom -MemberDepartRestriction closed

#Get members of the current groups
$HDMembers = Get-ADGroupMember -Identity "Hospital Director - $groupname" | get-aduser -Properties emailaddress | select emailaddress
$NUMembers = Get-ADGroupMember -Identity "Nurses - $groupname" | get-aduser -Properties emailaddress | select emailaddress
$PMMembers = Get-ADGroupMember -Identity "Practice Manager - $groupname" | get-aduser -Properties emailaddress | select emailaddress
$TEMembers = Get-ADGroupMember -Identity "Team - $groupname" | get-aduser -Properties emailaddress | select emailaddress
$VEMembers = Get-ADGroupMember -Identity "Vets - $groupname" | get-aduser -Properties emailaddress | select emailaddress

foreach ($HDMember in $HDmembers) {
Add-DistributionGroupMember –Identity $hddisplayname –Member $HDMember.emailaddress
}
foreach ($NUMember in $NUmembers) {
Add-DistributionGroupMember -Identity $nursedisplayname -Member $NUMember.emailaddress
}
foreach ($PMMember in $PMmembers) {
Add-DistributionGroupMember –Identity $pmdisplayname –Member $PMMember.emailaddress
}
foreach ($TEMember in $TEmembers) {
Add-DistributionGroupMember –Identity $teamdisplayname –Member $TEMember.emailaddress
}
foreach ($VEMember in $VEmembers) {
Add-DistributionGroupMember –Identity $vetsdisplayname –Member $VEMember.emailaddress
}