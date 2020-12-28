if($session.ComputerName -like "outlook.office365*"){
    Write-Host "Outlook.Office365.com session is connected" -ForegroundColor Cyan
}
else{
    #MFA Authentication#
    #Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch "_none_"}|select -First 1)
    #$EXOSession = New-ExoPSSession
    #Import-PSSession $EXOSession

    #


    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session
    Connect-MsolService

}


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


$users=Get-ADUser -SearchBase "OU=2.029 Eastside Veterinary Botany Rd,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au" -filter {proxyaddresses -like "*"} | select -ExpandProperty name

$users=Get-PrimarySMTP -users $users | Where-Object {$_.primarysmtp -like "*sydneyvetspecialists.com.au*"} | select -first 6

$result=@()

foreach($user in $users){

    $name=$user.primarysmtp.split('@')[0]
    $name
    $newaddress=$name+"@sves.com.au"

    $temp=[pscustomobject]@{"oldaddress"=$user.primarysmtp; "newaddress"=$newaddress; "name"=$user.name}
    $result+=$temp
}

$result

Write-Output ""

foreach($one in $result){


    $newproxyaddress=@("SMTP:"+$one.newaddress;'smtp:'+$one.oldaddress)
  
    $oldaddress=$one.oldaddress.Trim()
    $name=$one.name

    $sam=get-aduser -filter { name -eq $name} | select -ExpandProperty SamAccountName
    
    Write-Host "Updating AD Proxyaddresses and Mail"

    set-aduser $sam -Replace @{proxyaddresses=$newproxyaddress}

    set-aduser $sam -EmailAddress $one.newaddress

    $upn=$one.newaddress

    Set-ADUser -Identity $dn -Replace @{userprincipalname=$upn}

   

 


    $oldmsolupn=Get-MsolUser -SearchString $oldaddress
    $oldmsolupn=$oldmsolupn| select -First 1 | select -ExpandProperty UserPrincipalName

    $newmsolupn=$one.newaddress

    write-host "Updating MSOLUPN: $oldmsolupn -> $newmsolupn" -ForegroundColor Cyan
    Set-MsolUserPrincipalName -UserPrincipalName $oldmsolupn -NewUserPrincipalName $newmsolupn 

      


}


Start-ADSyncSyncCycle -PolicyType Delta



#get-aduser $sam -Properties mail, proxyaddresses | select name, mail, proxyaddresses

