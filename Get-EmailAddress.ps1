#########################Get Prmiary rapp email Only#############

$users = Get-ADUser -Filter {proxyAddresses -like '*'} -Properties proxyAddresses
$pp=$null
$pp=@{'name'=$null;'primarysmtp'=$null}
$obj=New-Object -TypeName psobject -Property $pp
 
$result=@()
foreach($user in $users){
$primarySMTPAddress = ""
foreach ($address in $user.proxyAddresses)
{
    if (($address.Length -gt 5) -and ($address.SubString(0,5) -ceq 'SMTP:') )
    {
        $primarySMTPAddress = $address.SubString(5)
        break
    }
}
$objtemp=$obj | select *
$objtemp.name=$user.Name
$objtemp.primarysmtp=$primarySMTPAddress
$result+=$objtemp
}
$result | Where-Object{$_.primarysmtp -like "*rapp.com.au*"} | sort Name



###################Get all rapp email#####################


$result=@()
$users=get-aduser -Filter {proxyaddresses -like "*rapp.com.au*"} -Properties proxyaddresses 
foreach( $user in $users){

foreach ($address in $user.proxyAddresses)
{
   if($address -like "*@rapp.com.au*"){
   
   $rappaddress=$address.Substring(5)
   break;
   }
   

}

$temp=[pscustomobject]@{name=$user.Name;RappAddress=$rappaddress}

$result+=$temp

}