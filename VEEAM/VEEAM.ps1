Add-PSSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue
$sessons=Get-VBRServerSession

if ($sessons.server -like '*drvbr01'){
    write-host 'Already Connected to DRVBR01' -ForegroundColor Yellow

}
else{
    Connect-VBRServer -Server drvbr01 -User omnicom\yuan.li -Password Goat201510
}
$jobs=Get-VBRJob 
foreach($job in $jobs){
    write-host $job.name $job.JobTargetType $job.ScheduleOptions -ForegroundColor Cyan
    Get-VBRJobObject $job.name | select -ExpandProperty Name 


}