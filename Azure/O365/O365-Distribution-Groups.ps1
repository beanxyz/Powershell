$userid='geoff.rose@vet.partners'
$pass = "01000000d08c9ddf0115d1118c7a00c04fc297eb010000001e8598af3345d647bb113d785a4fc0260000000002000000000003660000c00000001000000055c5f55351d5976f1b0aab8e8f3438b00000000004800000a0000000100000000c58064742ecdec9d7554ab827ddbfdd180000005bc5144e71dfd46d191e8b441cc977b205181fb28a1df447140000007484baf6e4de75f260f171b6415e83ec969d2fd4" | ConvertTo-SecureString
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userid, $pass
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $creds -Authentication Basic -AllowRedirection
Import-PSSession $Session

#Variables
$clinicname = "NSVH"
$groupname = "NSVH"
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
$hospitals = $clinicname + " - Hospitals"
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