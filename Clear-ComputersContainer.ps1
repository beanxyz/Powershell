$a=Get-ADComputer -SearchBase "cn=computers,dc=omnicom,dc=com,dc=au" -Filter * -Properties ipv4address,operatingsystem, whencreated 

foreach($b in $a){



if($b.IPv4Address -like "10.2*" -or $b.IPv4Address -like "172.16*"){

switch($b.OperatingSystem)
{


 "Mac OS X"{ Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=sydney,ou=macintosh,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"}
 "Windows 7 Professional"{Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=windows 7,ou=sydney,ou=windows,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"}
 "Windows 8.1 Pro*"{Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=windows 8,ou=sydney,ou=windows,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"}
 "Windows 10*"{}
}
}elseif($b.IPv4Address -like "10.3*"){

switch($b.OperatingSystem){
 
 "Mac OS X"{Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=melbourne,ou=macintosh,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"}
 "Windows 7 Professional"{Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=windows 7,ou=melbourne,ou=windows,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"}
 "Windows 8.1 Pro"{$b.Name;Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=windows 8,ou=melbourne,ou=windows,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"}
 "Windows 10*"{}
}

}
else{

   Move-ADObject -Identity $b.DistinguishedName -TargetPath "ou=test,ou=windows,ou=ddb group workstations,ou=ddb group machines,dc=omnicom,dc=com,dc=au"
}




}