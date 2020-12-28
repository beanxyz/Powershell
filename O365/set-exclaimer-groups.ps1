#Gareth found that the groups need this attribute set for Exclaimer to work properly
$groups = Get-ADGroup -filter *

#Local AD groups
foreach ($group in $groups) {
Set-ADGroup $group -Add @{ReportToOriginator="TRUE"}
}


#Groups in Azure
$groups = Get-DistributionGroup
foreach ($group in $groups) {
Set-DistributionGroup $group -ReportToOriginator $true
}