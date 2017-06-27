#导入AD模块
Import-Module ActiveDirectory

#连接Office365

$Sessions=Get-PSSession

if ($Sessions.ComputerName -like "outlook.office365.com"){

    write-host "Detecting Office365 session, skip.." -ForegroundColor Cyan

}
else{
    
    write-host "Starting Office365 session" -ForegroundColor Cyan
    $UserCredential = Get-Credential 
    Connect-MsolService -Credential $UserCredential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session
}



#获取AD对象


#获取主地址
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
    return $result 
}

#获取用户信息

#$ADUsers = Get-ADUser -SearchBase "ou=mango,ou=ddb_group,ou=melbourne,dc=omnicom,dc=com,dc=au" -Properties proxyaddresses, emailaddress, displayname -Filter *

$ADUsers=get-aduser amellington -Properties proxyaddresses, emailaddress, displayname


#修改SamAccountName和UPN
foreach ($ADUser in $ADUsers) {
    $ADUser.Name
	$GivenName = $ADUser.GivenName
	$SurName = $ADUser.Surname
	
	if (($GivenName -ne $null) -or ($SurName -ne $null))
	{
		$newSAM = $GivenName.ToLower() + '.'+$SurName.ToLower()
        $oldUPN=$ADUser.UserPrincipalName
        $domainName= $oldUPN.Split('@')[1]
		$newUPN = $newSAM + '@'+$domainName
        
        write-host "Updating ADUPN: $oldupn -> $newUPN" -ForegroundColor Cyan
        

        #更改AD UPN和SamAccount
		Set-ADUser $ADUser -SamAccountName $newSAM -UserPrincipalName $newUPN 
       
        
        #更改email
        $oldEmail=$ADUser.emailaddress

        $newEmail=$newSAM+‘@'+$oldemail.split('@')[1]

        write-host "Updating Email:$oldEmail -> $newEmail" -ForegroundColor Cyan

        set-aduser $newSAM -EmailAddress $newEmail

        #更改,替换 Primary SMTP

        $primary=Get-PrimarySMTP -users $ADUser.name | select -ExpandProperty primarysmtp

        Write-Host "Updating ProxyAddress.." -ForegroundColor Cyan

        #Write-Host "Current Primary address is $primary" -ForegroundColor Cyan
        
        $Aduser.proxyaddresses.remove("SMTP:"+$primary)
        
        $Aduser.proxyaddresses.add("smtp:"+$primary)

        $Aduser.proxyaddresses.add("SMTP:"+$newEmail)

        set-aduser $newSAM -replace @{proxyaddresses=[string[]]$ADUser.proxyaddresses} 
        
        

        #更改cloud UPN

        $oldmsolupn=Get-MsolUser -SearchString $ADUser.Name 
        $oldmsolupn=$oldmsolupn| select -First 1 | select -ExpandProperty UserPrincipalName

        $newmsolupn=$newSAM+'@'+$oldmsolupn.split('@')[1]

        write-host "Updating MSOLUPN: $oldmsolupn -> $newmsolupn" -ForegroundColor Cyan
        Set-MsolUserPrincipalName -UserPrincipalName $oldmsolupn -NewUserPrincipalName $newmsolupn 
		
		#Write-Host "Changes to the user $($GivenName) $($SurName) were made!"
        Write-Host ""
	}
    else{
        Write-Warning "Either GivenName or Surname is Empty"
    
    }
}

#Confirm 

get-aduser $newSAM -Properties proxyaddresses
Get-MsolUser -SearchString $ADUser.Name 





