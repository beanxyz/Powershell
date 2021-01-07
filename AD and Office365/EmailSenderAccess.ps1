$sofo=Get-ADGroup "Support Office & Field Ops" | select -ExpandProperty distinguishedname
$bne=get-adgroup "IT-BNE" | select -ExpandProperty distinguishedname
$akl=get-adgroup "IT-akl" | select -ExpandProperty distinguishedname
$per=get-adgroup "IT-per" | select -ExpandProperty distinguishedname
$syd=get-adgroup "IT-syd" | select -ExpandProperty distinguishedname


Set-ADObject $bne -Replace @{dlmemsubmitperms="$sofo"}
Set-ADObject $akl -Replace @{dlmemsubmitperms="$sofo"}
Set-ADObject $per -Replace @{dlmemsubmitperms="$sofo"}
Set-ADObject $syd -Replace @{dlmemsubmitperms="$sofo"}



$payroll=get-adgroup "VetPartners Payroll" | select -ExpandProperty distinguishedname


$user=get-aduser -filter { displayname -eq 'VetPartners User In'} | select -ExpandProperty distinguishedname

Set-ADObject $user -Replace @{dlmemsubmitperms="$payroll"}