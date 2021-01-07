###############################################################################
#		Author: Vikas Sukhija
#		Date: 04/08/2015
#               Description: Extract group memebers in CSV format to be 
#		imported in SQL Table
#               Modified:
###############################################################################
########################Add Quest Shell########################################

If ((Get-PSSnapin | where {$_.Name -match "Quest.ActiveRoles"}) -eq $null)
{
                Add-PSSnapin Quest.ActiveRoles.ADManagement
}

$collection = @()

$OU = 'OU=TestOU,OU=Groups,DC=labtest,DC=com' #define OU

$Group = Get-QADGroup -SearchRoot $OU

$Group | foreach{

$Groupname = $_.name

Write-host "Expanding group ......$Groupname" -foregroundcolor green

$members = Get-QADGroupMember $_  -sizelimit 0 |  select Name

$members | foreach{

$member = $_.Name

Write-host $member -foregroundcolor blue

$coll = "" | Select ADGroupName,MemberName
$coll.ADGroupName = $Groupname

$coll.MemberName = $member

$collection +=$coll
}

}


$collection | Export-Csv .\members.csv -notypeinformation

###################################################################################
