$a=get-aduser yli -Properties * 

$col=@()
$a| gm | Where-Object {$_.definition -like "*String*" -and $_.membertype -eq "Property"} | 

foreach {

if ($a.($_.name) -like "*sy*"){

#$_.name + " "+$a.($_.name) 
$col+=$_.name
}

}

$a | select $col