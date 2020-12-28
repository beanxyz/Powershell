$all=Get-ADComputer -SearchBase "cn=computers,dc=on,dc=vetpartners,dc=com,dc=au" -Filter * -Properties operatingsystem | select *


foreach($item in $all){
if($item.operatingsystem -like "*server*"){


#move to server ou
 Move-ADObject -Identity $item.DistinguishedName -TargetPath "OU=Windows Servers,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"
}

else{

#move to client ou
 Move-ADObject -Identity $item.DistinguishedName -TargetPath "OU=Computers,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"
}



}