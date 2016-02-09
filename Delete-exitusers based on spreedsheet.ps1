$a=import-csv C:\temp\exituser.csv -Header "Names","LastName","FirstName","Date","Reason","Place","Type","Company"

foreach( $b in $a ){

$name=$b.FirstName.Substring(0,1)+$b.LastName

try{
get-aduser $name | Remove-ADUser
}
catch{
$warning="User "+$name+" doesn't exist"
$warning |Write-Warning 
}

}