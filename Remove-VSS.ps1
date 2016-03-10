#The following script will only keep the last VSS copy in each day before today


$delsnap=@()
Get-WmiObject -ComputerName sydittest -Class win32_shadowcopy | 
select deviceobject,ID,@{n='datetime';e={[management.managementDateTimeConverter]::ToDateTime($_.installdate)}},@{n='dayofyear';e={[management.managementDateTimeConverter]::ToDateTime($_.installdate).dayofyear}} | 
group dayofyear | Where-Object{$_.dayofyear -lt (get-date).DayOfYear} |
foreach {

if ($_.count -gt 1){

$max=$_.count-1

for($i=0;$i -lt $max;$i++ ){

$temp=[pscustomobject]@{id=$_.group[$i].id}
$delsnap+=$temp
}
}


}

$delsnap | foreach{

$id=$_.id.ToString()

Get-WmiObject -ComputerName sydittest -Class win32_shadowcopy | foreach {
if($_.id -eq $id){

$_.delete() 
}



}

}
