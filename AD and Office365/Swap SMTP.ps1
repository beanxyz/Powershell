$result=@()
$users=get-aduser -Filter {proxyaddresses -like "*rapp.com.au*"} -Properties proxyaddresses -SearchBase "ou=rapp,ou=ddb_group,ou=melbourne,dc=omnicom,dc=com,dc=au"
foreach( $user in $users){

foreach ($address in $user.proxyAddresses)
{
   if($address -like "*@rapp.com.au*"){
   
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








function Get-PrimarySMTP(){

    [CmdletBinding()]
    
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $users
    )

$pp=$null
$pp=@{'name'=$null;'primarysmtp'=$null}
$obj=New-Object -TypeName psobject -Property $pp
 
$result=@()
foreach($user in $users){
$info=get-aduser -Filter {name -eq $user} -Properties proxyaddresses
$primarySMTPAddress = ""
foreach ($address in $info.proxyAddresses)
{
    if (($address.Length -gt 5) -and ($address.SubString(0,5) -ceq 'SMTP:') )
    {
        $primarySMTPAddress = $address.SubString(5)
        
        break
    }

}
$objtemp=$obj | select *
$objtemp.name=$info.Name
$objtemp.primarysmtp=$primarySMTPAddress
$result+=$objtemp
}
$result 
}

$users=$oo | sort "full Name"|select -ExpandProperty "Full Name"
#$users=get-aduser yli |select -ExpandProperty name

#write-host "Current Info" -ForegroundColor Red

#$users=import-csv C:\temp\newuserList.csv | select -ExpandProperty "Full Name"

#Get-PrimarySMTP -users $users

foreach($user in $users){

$info=get-aduser -Filter {name -eq $user} -Properties proxyaddresses


$filter="smtp:"+$info.GivenName+"."+$info.Surname+"@track-au.com"

$new=@()


foreach($address in $info.proxyaddresses){

$temp=$address


if($address -clike "SMTP*"){

$temp=$address.ToLower()


}

if($address -like $filter){

$temp=$address.Substring(0,4).toupper()+$address.Substring(4).tolower()
}



$new+=$temp

}


write-host "---------------------------" -ForegroundColor Cyan  


$new

set-aduser $info.SamAccountName -Replace @{proxyaddresses=$new} -whatif

}


repadmin /syncall syddc01 dc=omnicom,dc=com,dc=au /d /e /a 

#write-host "New Primary SMTP Address" -ForegroundColor Cyan


#$users=gc C:\temp\name.txt

Get-PrimarySMTP -users $users

$users | get-mailbox | select name, primarysmtpaddress 


#$users=import-csv C:\temp\newuserList.csv | select -ExpandProperty "Full Name"


