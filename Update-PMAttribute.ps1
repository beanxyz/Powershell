$all=Import-Excel "C:\Temp\Copy of Printportal.xlsx"


$i=0
$count=$all | measure |select -ExpandProperty count

foreach($item in $all){


$mail=$item.mail
if($mail -eq $null){continue}

$streetaddress=$item.streetaddress
$city=$item.city
$state=$item.state
$postalcode=$item.postalcode.ToString()
$name=$item.name
$country=$item.country
if($country -eq 'Australia'){
$co='Australia'
$c='AU'


}


if($country -eq 'New Zealand'){
$co='New Zealand'
$c='NZ'


}


$telephonenumber=$item.telephonenumber
$companyname=$item.companyname
$givename=$item.givenname
$surname=$item.surname
$extensionattribute1=$item.extensionAttribute1

$extensionattribute2=$item.extensionAttribute2

$extensionattribute3=$item.extensionAttribute3

$extensionattribute4=$item.extensionAttribute4

if($extensionattribute1 -eq $null){

$extensionattribute1=""
}else{

$mail

get-aduser -filter { userprincipalname -eq $mail} -ErrorAction SilentlyContinue -ErrorVariable aa -Properties * | 

Set-ADUser -Replace @{extensionattribute1=$extensionattribute1}

}

if($extensionattribute2 -eq $null){
$extensionattribute2=""
}else{


get-aduser -filter { userprincipalname -eq $mail} -ErrorAction SilentlyContinue -ErrorVariable aa -Properties * | 

Set-ADUser -Replace @{extensionattribute2=$extensionattribute2}
}

if($extensionattribute3 -eq $null){
$extensionattribute3=""
}else{
get-aduser -filter { userprincipalname -eq $mail} -ErrorAction SilentlyContinue -ErrorVariable aa -Properties * | 

Set-ADUser -Replace @{extensionattribute3=$extensionattribute3}
}

if($extensionattribute4 -eq $null){
$extensionattribute4=""
}else{

get-aduser -filter { userprincipalname -eq $mail} -ErrorAction SilentlyContinue -ErrorVariable aa -Properties * | 

Set-ADUser -Replace @{extensionattribute4=$extensionattribute4}
}


$wwwhomepage=$item.wwwhomepage







    
#
get-aduser -filter { userprincipalname -eq $mail} -ErrorAction SilentlyContinue -ErrorVariable aa -Properties * | 
Set-ADUser -streetaddress $streetaddress -city $city -state $state -postalcode $postalcode -officephone $telephonenumber -homepage $wwwhomepage -Company $companyname




get-aduser -filter { userprincipalname -eq $mail} -ErrorAction SilentlyContinue -ErrorVariable aa -Properties * | 

Set-ADUser -Replace @{co=$co;c=$c}

$u=get-aduser -Filter { userprincipalname -eq $mail}

if($u -ne $null){

Add-ADGroupMember -Identity 'practice managers' -Members $u.distinguishedname

}



    $i++
    Write-Progress -activity "Scanning User $name . . ." -status "Scanned: $i of $count" -percentComplete (($i / $count)  * 100)




get-aduser -filter { userprincipalname -eq $mail} -ErrorAction SilentlyContinue -ErrorVariable aa -Properties * | select name, surname, givenname, mail, streetaddress, city,state, postalcode, country, telephonenumber, company, wwwhomepage, extensionattribute1, extensionattribute2,extensionattribute3,extensionattribute4





}




Start-ADSyncSyncCycle -PolicyType Delta
