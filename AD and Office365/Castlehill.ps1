$all=Get-DistributionGroup | Where-Object {$_.name -like "*castle hill*"}

function Get-DistributionGroupMemberRecursive ($GroupIdentity) {
	$member_list = Get-DistributionGroupMember -Identity $GroupIdentity
	foreach ($member in $member_list) {
		if ($member.RecipientType -like '*Group*') {
			Get-DistributionGroupMemberRecursive -GroupIdentity $member.Identity
		} else {
			$member
		}
	}
}
$result=foreach($one in $all){
    Get-DistributionGroupMemberRecursive -GroupIdentity $one.name

}


$result | select -Unique name, Recipienttype , windowsliveid