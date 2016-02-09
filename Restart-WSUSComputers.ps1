#$names=@("sydit01","aussql01","camperdown","drdc01","drdc02","drrad2012","drsrm2012","kensington","melal02","melapp01","melbk01","meldc01","meldv01","meldv02","meleps01","melex01","melfs01","melfs02","melic01","melit02","melps01","yarra","melbk01","melvcs","manly","mascot","ryde","stanmore","sydarc01","sydbcc01","sydbcc02","sydcert01","sydbcc03","syddc01","syddc02","syddfm01","sydmrm01","sydphc01","sydsp01","sydsrm2012","sydsso01","sydsql01","sydtms01","sydvcs2012","sydvcs5","sydwsus","sydprn01")
. C:\scripts\Get-PendingReboot.ps1
$names=get-adcomputer -Filter{operatingsystem -like "*20*"} | select -ExpandProperty name
$results=get-pendingreboot -computername $names | select computer, rebootpending, pendfilerenval | sort rebootpending
$results

foreach ($c in $results){
if ($c.RebootPending -eq "True")#
{
   
 "Restarting server: "+$c.computer
#Restart-Computer $c.Computer -Force

}

}