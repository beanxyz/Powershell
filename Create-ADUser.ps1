##############Connect to Office365 from Powershell via MFA############################

<#

Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch "_none_"}|select -First 1)
$EXOSession = New-ExoPSSession
Import-PSSession $EXOSession



#>


###################Import user list from csv file##########################

$users=import-csv 'C:\Users\xdhennessy\Desktop\Auto Emails\Email Creation Script.csv'


#################Create AD account and setup their properties#################

foreach ($User in $Users)            
{            

    if($User -eq $null){break}
             
    $UserFirstname = ($User.'Firstname').trim()            
    $UserLastname = ($User.'Lastname').trim()    
    $Displayname = $UserFirstname + " " + $UserLastname    
    $OU = $User.'OU'            
    $SAM = "$UserFirstname.$UserLastname"           
    $UPN = $UserFirstname + "." + $UserLastname + "@" + $User.'domains'            
           
    $Password = $User.'Password'    
    $email=$user.email
    
    if ($email -eq ""){
        $email=$UPN
    }
     
    #######delete all users objects######     
    #get-aduser -Filter {displayname -eq $Displayname} | Remove-ADUser -Confirm:$false
    
    ############create new AD account#########
    #New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname"  -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $false –PasswordNeverExpires $true -EmailAddress $email 


    ######Configure Group of the user########
    #$nursegroup = (get-adgroup -SearchBase $OU -Filter {Name -like "*Nurse*"}).name
    #Add-ADGroupMember -Members $sam -Identity $pmgroup


    #######configure Proxyaddresses for Office365###########
   # $aduser=Get-ADUser $Sam 
   # $Aduser.proxyaddresses.add("SMTP:"+$email)
   #Set-Aduser $Sam -replace @{proxyaddresses=[string[]]$ADUser.proxyaddresses} 

   

    #######################  Assign Office365 Licenses -  ExchangeOnline1 License##############

    Get-MsolUser -UserPrincipalName $upn
    Set-MsolUser -UserPrincipalName $upn -UsageLocation AU
    Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses vetpartners:EXCHANGESTANDARD    

}


