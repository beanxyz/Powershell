Import-Module ActiveDirectory


$ADUsers = Get-ADUser 'arojas'

#Change User SamAccountName and User Principal Name
foreach ($ADUser in $ADUsers) {
	$GivenName = $ADUser.GivenName
	$SurName = $ADUser.Surname
	
	if (($GivenName -ne $null) -or ($SurName -ne $null))
	{
		$newSAM = $GivenName.ToLower() + '.'+$SurName.ToLower()
        $oldUPN=$ADUser.UserPrincipalName
        $domainName= $oldUPN.Split('@')[1]
		$newUPN = $newSAM + '@'+$domainName
        write-host "Change from $oldupn to $newUPN"
            
		Set-ADUser $ADUser -SamAccountName $newSAM -UserPrincipalName $newUPN
        
        Set-MsolUserPrincipalName -UserPrincipalName $oldUPN -NewUserPrincipalName $newUPN
		
		Write-Host "Changes to the user $($GivenName) $($SurName) were made!"
	}
}




#Connecto to Office365
#$UserCredential = Get-Credential 
#Connect-MsolService -Credential $UserCredential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session

#Change O365 login Name

#Set-MsolUserPrincipalName -UserPrincipalName alex.rojas@syd.ddb.com -NewUserPrincipalName alex.rojas@aus.ddb.com

