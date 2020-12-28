

function Get-ADGroupMembers {

	param(
		[string]$GroupName
	)
	
	$objects = @()

	$members = Get-ADGroupMember -Identity $GroupName

	foreach ($member in $members) {

		if ($member.objectClass -eq "group") {
			$objects += Get-AdGroupMembers -GroupName $member.Name
		}
			
		$objects += @{
			"objectclass" = $member.objectClass;
			"name" = $member.Name;
			"group" = $GroupName
		}
		
	} # foreach
	
	return $objects
	
} # Get-AdGroupMembers


Import-Module ActiveDirectory
$GRP = "Support Office & Field Ops"
$AllMembers = Get-ADGroupMembers -GroupName $GRP
$result=$AllMembers | Foreach-Object {New-Object psobject -Property $_ }


$groupnames=$result  |select -Unique Group

$userdn=get-aduser -Filter {name -eq 'VetPartners Appraisals'} | select -ExpandProperty distinguishedname

foreach($one in $groupnames){
    write-host $one.Group -ForegroundColor Green
    $groupdn=Get-ADGroup $one.Group | select -ExpandProperty distinguishedname

    $oldauth=get-adgroup $one.Group -Properties authorig| select -ExpandProperty authorig
    $oldauth
    #Set-ADObject $groupdn -Replace @{authOrig=$userdn}

}


$groupdn=Get-ADGroup 'Operations Directors - ALL' | select -ExpandProperty distinguishedname

    #$oldauth=get-adgroup $one.Group -Properties authorig| select -ExpandProperty authorig
    #$oldauth
    Set-ADObject $groupdn -Replace @{authOrig=$userdn}


Set-ADObject   'CN=VetPartners Marketing 2,OU=2.011 HQ,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au' -