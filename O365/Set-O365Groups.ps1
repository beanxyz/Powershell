$365Logon = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $365Logon -Authentication Basic -AllowRedirection
Import-PSSession $Session
$clinicname = "Chatswood"
$clinicname = "Woodridge"


#Variables for the groups
$hddisplayname = $clinicname + " - Hospital Director"
$nursedisplayname = $clinicname + " - Nurses"
$pmdisplayname = $clinicname + " - Practice Manager"
$teamdisplayname = $clinicname + " - Team"
$vetsdisplayname = $clinicname + " - Vets"
$alias = $clinicname -replace '\s',''

#Create Office 365 Groups
New-UnifiedGroup –DisplayName $hddisplayname -Alias "$alias-HD" -AccessType Private
New-UnifiedGroup –DisplayName $nursedisplayname -Alias "$alias-NU" -AccessType Private
New-UnifiedGroup –DisplayName $pmdisplayname -Alias "$alias-PM" -AccessType Private
New-UnifiedGroup –DisplayName $teamdisplayname -Alias "$alias-TE" -AccessType Private
New-UnifiedGroup –DisplayName $vetsdisplayname -Alias "$alias-VE" -AccessType Private

#Get members of the current groups
$HDMembers = Get-ADGroupMember -Identity "Hospital Director - $clinicname" | get-aduser -Properties emailaddress | select emailaddress
$NUMembers = Get-ADGroupMember -Identity "Nurses - $clinicname" | get-aduser -Properties emailaddress | select emailaddress
$PMMembers = Get-ADGroupMember -Identity "Practice Manager - $clinicname" | get-aduser -Properties emailaddress | select emailaddress
$TEMembers = Get-ADGroupMember -Identity "Team - $clinicname" | get-aduser -Properties emailaddress | select emailaddress
$VEMembers = Get-ADGroupMember -Identity "Vets - $clinicname" | get-aduser -Properties emailaddress | select emailaddress





#Add members of on prem group to O365 group
foreach ($HDMember in $HDmembers) {
Add-UnifiedGroupLinks –Identity $hddisplayname –LinkType Members –Links $HDMember.emailaddress
}

foreach ($NUMember in $NUmembers) {
Add-UnifiedGroupLinks –Identity $nursedisplayname –LinkType Members –Links $NUMember.emailaddress
}
foreach ($PMMember in $PMmembers) {
Add-UnifiedGroupLinks –Identity $pmdisplayname –LinkType Members –Links $PMMember.emailaddress
}
foreach ($TEMember in $TEmembers) {
Add-UnifiedGroupLinks –Identity $teamdisplayname –LinkType Members –Links $TEMember.emailaddress
}
foreach ($VEMember in $VEmembers) {
Add-UnifiedGroupLinks –Identity $vetsdisplayname –LinkType Members –Links $VEMember.emailaddress
}

Add-UnifiedGroupLinks –Identity $teamdisplayname –LinkType Members –Links "taffany.tsui@woodridgevet.com.au"
