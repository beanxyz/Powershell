$Sessions=Get-PSSession

#Import AD Module

Import-Module activedirectory

#Import Office 365 Module



if (($Sessions.ComputerName -like "outlook.office365.com") -and ($Sessions.State -ne "Broken")){

    write-host "Detecting current Office365 session, skip.." -ForegroundColor Cyan

}
else{
    
    $Sessions | Remove-PSSession

    write-host "Starting new Office365 session" -ForegroundColor Cyan
    $UserCredential = Get-Credential 
    Connect-MsolService -Credential $UserCredential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session
}




#Get Primary SMTP Address
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

#Get AD User Informtion

#$ADUsers = Get-ADUser -SearchBase "ou=mango,ou=ddb_group,ou=melbourne,dc=omnicom,dc=com,dc=au" -Properties proxyaddresses, emailaddress, displayname -Filter *
Write-Host " "

#$uName=Read-Host "Please input User AD name" 

$ADUsers=get-aduser gwilson -Properties proxyaddresses, emailaddress, displayname


#Change SamAccountName and UPN
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
        

        #Change AD UPN and SamAccount
		Set-ADUser $ADUser -SamAccountName $newSAM -UserPrincipalName $newUPN 
       
        
        #Change AD email
        $oldEmail=$ADUser.emailaddress

        $newEmail=$newSAM+‘@'+$oldemail.split('@')[1]

        write-host "Updating Email:$oldEmail -> $newEmail" -ForegroundColor Cyan

        set-aduser $newSAM -EmailAddress $newEmail

        #Change Primary SMTP

        $primary=Get-PrimarySMTP -users $ADUser.name | select -ExpandProperty primarysmtp

        Write-Host "Updating ProxyAddress.." -ForegroundColor Cyan

        #Write-Host "Current Primary address is $primary" -ForegroundColor Cyan
        
        $Aduser.proxyaddresses.remove("SMTP:"+$primary)
        
        $Aduser.proxyaddresses.add("smtp:"+$primary)

        $Aduser.proxyaddresses.add("SMTP:"+$newEmail)

        set-aduser $newSAM -replace @{proxyaddresses=[string[]]$ADUser.proxyaddresses} 
        
        

        #Change cloud UPN. If Office365 session is not connected properly, follow commands wont' work!

        $oldmsolupn=Get-MsolUser -SearchString $ADUser.Name 
        $oldmsolupn=$oldmsolupn| select -First 1 | select -ExpandProperty UserPrincipalName

        $newmsolupn=$newSAM+'@'+$oldmsolupn.split('@')[1]

        write-host "Updating MSOLUPN: $oldmsolupn -> $newmsolupn" -ForegroundColor Cyan
        Set-MsolUserPrincipalName -UserPrincipalName $oldmsolupn -NewUserPrincipalName $newmsolupn 
		
        Write-Host ""
	}
    else{
        Write-Warning "Either GivenName or Surname is Empty"
    
    }
}

#Confirm result 

Write-Host "Confirm AD Result " -ForegroundColor Cyan
get-aduser $newSAM -Properties proxyaddresses,mail | select Name, SamAccountName, UserPrincipalName, proxyaddresses, mail

Write-Host "Confirm O365 Result" -ForegroundColor Cyan
Get-MsolUser -SearchString $ADUser.Name | select UserPrincipalName





