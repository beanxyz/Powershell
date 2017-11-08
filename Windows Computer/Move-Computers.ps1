$a=Get-ADComputer -SearchBase "ou=test,ou=windows,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au" -Filter * -Properties * | select name, ipv4address, operatingsystem

foreach($b in $a){
$b.IPv4Address

if($b.IPv4Address -like "10.2*" -or $b.IPv4Address -like "172.16*"){

switch($b.OperatingSystem)
{


"Mac OS X"{ Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=sydney,ou=macintosh,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"}
"Windows 7 Professional"{Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=windows 7,ou=sydney,ou=windows,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"}
"Windows 8*"{}
"Windows 10*"{}
}
}elseif($b.IPv4Address -like "10.3*"){

switch($b.OperatingSystem){

"Mac OS X"{Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=melbourne,ou=macintosh,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"}
"Windows 7 Professional"{Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=windows 7,ou=melbourne,ou=windows,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"}
"Windows 8*"{}
"Windows 10*"{}
}

}
else{

   Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=test,ou=windows,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"
}




}