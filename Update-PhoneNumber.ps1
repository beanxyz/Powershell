$a=import-csv -header name, title, mobile, ipphone C:\Users\yli\Downloads\name1.csv 
foreach ($b in $a )
{

$c=$b.Name
$d=$b.Mobile

if ($d){
get-aduser -filter {name -like $c} -Properties name,mobile | Set-ADUser -Replace @{mobile=$d}
get-aduser -Filter {name -like $c} -Properties name,mobile,ipphone | select Name, Mobile, @{name="Extension";expression={$_.ipphone}}
}

}