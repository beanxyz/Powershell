#$a=import-csv -header name, title, mobile, ipphone C:\Users\yli\Downloads\name1.csv 

$a=import-csv C:\temp\list.csv

foreach ($b in $a )
{


$c=$b.UserName
$d=$b.Mobile



if ($d){

set-aduser $c -MobilePhone $d -ErrorVariable ee
#get-aduser $c -Properties name,mobile | foreach {Set-ADUser $_ -Replace @{mobile=$d} -WhatIf}
get-aduser $c -Properties name,mobile,ipphone | select Name, Mobile, @{name="Extension";expression={$_.ipphone}}
}

}


