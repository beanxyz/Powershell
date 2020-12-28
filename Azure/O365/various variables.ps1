#Variables for the groups
$ALL = "ALL - " + $hd
$AU = "AU - " + $hd
$nsw = "NSW - " + $hd
$nsw1 = "NSW - 1 - " + $hd
$nsw2 = "NSW - 2 - " + $hd
$nsw3 = "NSW - 3 - " + $hd
$nsw4 = "NSW - 4 - " + $hd
$nt = "NT - " + $hd
$nz = "NZ - " + $hd
$qld = "QLD - " + $hd
$sa = "SA - " + $hd
$sa1 = "SA - 1 - " + $hd
$sa2 = "SA - 2 - " + $hd
$sg = "SG - " + $hd
$tas = "TAS - " + $hd
$vic = "VIC - " + $hd
$wa = "WA - " + $hd

$hospitals = $clinicname + " - Hospitals"
$ALL = "ALL - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed
get-adgroupmem

Add-DistributionGroupMember -Identity "NSW - 1 - Hospitals" -Member "info@bexleyvet.com.au","info@yourvillagevet.com.au"
