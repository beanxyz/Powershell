#$ou="OU=2.007 Figtree,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"

$password = "8qtVoKID" | ConvertTo-SecureString -asPlainText -Force
$username = "support@vetpartners.com.au" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password)


$session=Get-PSSession

if($session.ComputerName -like "outlook.office365*"){
    Write-Host "Outlook.Office365.com session is connected" -ForegroundColor Cyan
}
else{
    #MFA Authentication#
    #Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch "_none_"}|select -First 1)
    #$EXOSession = New-ExoPSSession
    #Import-PSSession $EXOSession

    #Normal login

    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
    Import-PSSession $Session
    Connect-MsolService -Credential $credential

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





$users=get-aduser -SearchBase "OU=4.011 Herriot House,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au" -Filter * -Properties proxyaddresses, emailaddress, displayname


#$users=get-aduser -filter "mail -eq 'annaleys.bennett@vetpartners.com.au'" -Properties proxyaddresses, emailaddersses, displayname



#Change SamAccountName and UPN
foreach ($ADUser in $users) {
    $ADUser.Name
	$GivenName = $ADUser.GivenName
	$SurName = $ADUser.Surname
	
	if (($GivenName -ne $null) -or ($SurName -ne $null))
	{
		$newSAM = $GivenName.ToLower() + '.'+$SurName.ToLower()
        $oldUPN=$ADUser.UserPrincipalName
        #$domainName= $oldUPN.Split('@')[1]
		$newUPN = $newSAM + '@vetpartners.net.au'
        
        write-host "Updating ADUPN: $oldupn -> $newUPN" -ForegroundColor Cyan
        

        #Change AD UPN and SamAccount
		Set-ADUser $ADUser -SamAccountName $newSAM -UserPrincipalName $newUPN 
       
        
        #Change AD email
        $oldEmail=$ADUser.emailaddress

        $newEmail=$newSAM+‘@vetpartners.net.au'

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

        $newmsolupn=$newSAM+'@vetpartners.net.au'

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

