
$Clinicnames = Get-Content C:\scripts\all-sites.txt
foreach ($clinicname in $clinicnames) {
$mailnick = $Clinicname + "-sp"
$Clinicname = $Clinicname + " - Sharepoint"
New-AzureADGroup -SecurityEnabled $true -DisplayName $Clinicname -MailEnabled $false -MailNickName $mailnick

}
$adgroup = get-azureadgroup -SearchString $Clinicname
$admember = Get-DistributionGroup -Identity "Chatswood - Team" | select *
 Add-AzureADGroupMember 
 enable-distr




$clinicname = "Total Vets"
$mailnick = "Totalvets-sp"
$Clinicname = $Clinicname + " - Sharepoint"
New-AzureADGroup -SecurityEnabled $true -DisplayName $Clinicname -MailEnabled $false -MailNickName $mailnick
Get-DistributionGroupMember -Identity "RegionalOperatio-NZ@vet.partners"