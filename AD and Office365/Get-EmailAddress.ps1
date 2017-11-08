#########################Get Prmiary rapp email Only#############

$users = Get-ADUser -Filter {proxyAddresses -like '*rapp*'} -Properties proxyAddresses -SearchBase "ou=sydney,dc=omnicom,dc=com,dc=au"
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
$result | Where-Object{$_.primarysmtp -like "*track*"} | sort Name



###################Get all rapp email#####################


$result=@()
$users=get-aduser -Filter {proxyaddresses -like "*rapp.com.au*"} -Properties proxyaddresses -SearchBase "ou=rapp,ou=ddb_group,ou=melbourne,dc=omnicom,dc=com,dc=au"
foreach( $user in $users){

foreach ($address in $user.proxyAddresses)
{
   if($address -like "*@track-au.com*"){
   
   $rappaddress=$address.Substring(5)
   break;

   

   }
   

}

$temp=[pscustomobject]@{"Full Name"=$user.Name;"Current Email"=$rappaddress}

$result+=$temp

}

#$result

$a=import-csv C:\temp\newuserList.csv | select "Full Name", "Current Email"


$oo=$result+$a
$oo

