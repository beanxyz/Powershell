#$all=import-excel 'C:\temp\Kwinana Veterinary Hospital.xlsx' -WorksheetName 'Kwinana Veterinary Hospital'
#$path='C:\Temp\Kwinana Veterinary Hospital Vets\Kwinana Veterinary Hospital vet-mailusers.xlsx'
#$path='C:\Temp\Kwinana Veterinary Hospital Vets\Kwinana Veterinary Hospital vet-mailusers.xlsx'
$all=import-excel 'C:\Temp\Vetcare Tauranga\Vetcare Tauranga.xlsx' -WorksheetName 'Email Choice'
$path='C:\Temp\todolist\Vetcare Tauranga-mailusers'


$temp=$all | Where-Object {$_.mailtype -eq 'mailbox' -and $_.preference -like '*mail box*'} | select -First 1
$tempemail=$temp.Companyemail
$tmpuser=get-aduser -filter { mail -eq $tempemail} 
$OU = "OU="+($tmpuser.DistinguishedName -split "=",3)[-1]

#$ou="OU=2.007 Figtree,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"
#$ou="OU=64.010 Barkes Corner,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"

#$credential.Password | ConvertFrom-SecureString | set-content "c:\temp\password.txt"
$password = Get-Content "C:\temp\password.txt" | ConvertTo-SecureString 
$credential = New-Object System.Management.Automation.PsCredential("xyli@vet.partners",$password)
Connect-ExchangeOnline -Credential $credential -ShowProgress $true
Connect-MsolService -Credential $credential
Connect-AzureAD -Credential $credential



foreach($one in $all){


    if($one.mailtype -eq 'mailbox' -and $one.preference -like "*Mail user*" -and $one.'Mailbox backed up?' -like "*no*"){
    
        $name=$one.name
        Write-Host "Mailbox $name has not been backed up yet, please update the file and try again " -ForegroundColor Red
        exit 
    
    }



}




foreach($one in $all){

    $name=$one.name
    $companyemail=$one.Companyemail
    $externalemail=$one.Personalemail
    $firstname=$one.Firstname
    $lastname=$one.Surname
    $externalemail=$one.Personalemail

    $Displayname = $one.Firstname + " " + $one.Surname
    $UserFirstname = $one.Firstname
    $UserLastname = $one.Surname
    $UserLastnamenospace = $UserLastname -replace(' ',"")
    $UserFirstnamenospace = $UserFirstname -replace(' ',"")
    $SAM = $UserFirstnamenospace + "." + $UserLastnamenospace
    $samaccount=$UserFirstname + "." + $UserLastname


# Existing mailbox without forward but want a forward

#    if ( $one.Mailtype -eq 'mailbox' -and $one.Preference -like 'mailbox*forward' -and $one.Forward -eq ''){
#        Write-Host "Add forward to existing mailbox $companyemail to $externalemail" -ForegroundColor Yellow

#        Set-Mailbox -Identity $companyemail -DeliverToMailboxAndForward $true -ForwardingSMTPAddress $externalemail 
#    }



# New Mailuser

    if($one.Mailtype -eq 'none' -and $one.Preference -like '*Mail User*'){


        
    
      
        $result=get-aduser -Filter {userprincipalname -eq $companyemail}

        if ($result -eq $null){
  
        
        }

        else {



         
            Write-Host "Delete AD account $companyemail - >  convert to Mailuser" -ForegroundColor Yellow
        
            get-aduser -Filter  {userprincipalname -eq $companyemail}| Remove-ADUser -Confirm:$false 
            
        
        }






    }




# Convert existing mailbox to mailuser ->  delete AD first !

    if( $one.mailtype -eq 'mailbox' -and $one.preference -like '*Mail User*'){
   


        Write-Host "Delete AD account $companyemail - >  convert from mailbox to mailuser" -ForegroundColor red

        get-aduser -filter {mail -eq $companyemail} |Remove-ADUser  -Confirm:$false 

    
    }



# Create New AD user and mailbox + forward  /  Add mail to existing AD

    if ( $one.Mailtype -eq 'None' -and $one.Preference -like '*mail box*'){
    
        # Create new AD
     

        $Displayname = $one.Firstname + " " + $one.Proper
        $UserFirstname = $one.Firstname
        $UserLastname = $one.proper
        $UserLastnamenospace = $UserLastname -replace(' ',"")
        $UserFirstnamenospace = $UserFirstname -replace(' ',"")
        $SAM = $UserFirstnamenospace + "." + $UserLastnamenospace
        $Password = "Vets1234@"
        write-host "creating user $Displayname" -ForegroundColor Green
        #find the right OU
        #$PN = "*" + $one.Clinic + "*"
        #$OU = (Get-ADOrganizationalUnit -Filter {name -like $PN}).distinguishedname | select -first 1
        #$OU="OU=5.007 Salisbury Park,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"
        #find domain for user email address
        $finddomain = (get-aduser -SearchBase $OU -Filter * | select -First 1).userprincipalname
        $domain = $finddomain.Split("{@}")[1]
        $email = $UserFirstname + "@" + $domain 
        $email1 = $UserFirstname + "." + $UserLastname + "@" + $domain 
        $email2=$one.Companyemail

        $samaccount=$UserFirstname + "." + $UserLastname
      
        $result=get-aduser -Filter {userprincipalname -eq $email2 }

        if($result -eq $null){
            #Create New User
            $newuser = @{
            Name = $Displayname
            DisplayName = $Displayname
            EmailAddress = $email2
            SamAccountName = $SAM
            UserPrincipalName = $email2
            GivenName = $UserFirstname
            Surname = $UserLastname
            AccountPassword = (ConvertTo-SecureString $Password -AsPlainText -Force)
            Enabled = $true
            Path = $OU
            ChangePasswordAtLogon = $false
            PasswordNeverExpires = $false
            }
            New-ADUser @newuser  
        
            Add-ADGroupMember -Members $sam -Identity "VetPartners - All" 
        
         
            Set-ADUser $sam -Add @{proxyAddresses="SMTP:"+$email2;mailNickname=$Displayname} 
        
        }
        else{
        
            # Add Email address
            set-aduser $sam -EmailAddress $email2
            Set-ADUser $sam -Add @{proxyAddresses="SMTP:"+$email2;mailNickname=$Displayname} 
            
        }

        
      
       
    }


    


}



Start-ADSyncSyncCycle -PolicyType Delta

Write-Host "Wait for 30 min until Sync is completed" 


<##################################################### Part Two ##############################>

Connect-MsolService 

Connect-AzureAD 



$mailguestuers=Get-AzureADUser -Filter "userType eq 'Guest'" -All $true  |Select DisplayName, UserPrincipalName, AccountEnabled, mail, UserType, objectId

$mailcontact=Get-MailContact | select name, alias, @{n='email';e={$_.externalemailaddress.split(':')[1]}} 

####### Clean Guest User and Mail Contact #################################

foreach($one in $all){
    $name=$one.name
    $companyemail=$one.Companyemail
    $externalemail=$one.Personalemail
    $firstname=$one.Firstname
    $lastname=$one.proper
    $email=$one.Companyemail
    $externalemail=$one.Personalemail

    if($one.preference -like "*Mail User*"){
    


    ############### Clean Mail Guest Users##############################
        if($mailguestuers.mail -contains $externalemail){
        
            Write-Host "Guest User account $externalemail exists - Deleting " -ForegroundColor Yellow
            
            foreach($guest in $mailguestuers){
                if($guest.mail -eq $externalemail){
                
                        Remove-AzureADUser -ObjectId $guest.ObjectID -Verbose    

                
                }
            
            }
            
            
        
        
        }  

        ########## Clean Mail Contact ####################
        if($mailcontact.email -contains $externalemail){
            Write-Host "MailContact account exists - Deleting " -ForegroundColor Yellow
            
            get-mailcontact -Filter "externalemailaddress -like '*$externalemail*'" | Remove-MailContact 

        
        }
        
    
      

    }



}



$result2=@()


foreach($one in $all){
    
    $companyemail=$one.Companyemail.trim()
    $externalemail=$one.Personalemail.trim()
    $firstname=$one.Firstname
    $lastname=$one.Proper
    $email=$one.Companyemail
    $externalemail=$one.Personalemail
    $name=$firstname+" "+$lastname

    #Convert new mailuser

    if(  $one.preference -like '*Mail User*'){
        

        $result=get-aduser -Filter {samaccount -eq $samaccount }

        if ($result -eq $null){
            

             $exist = [bool](Get-mailbox $companyemail -erroraction SilentlyContinue)

             if($exist){ Write-Host "Mailbox $companyemail still exist.. please wait for 10 min and try again.." }
             else{

                $flag=get-mailuser $name -erroraction sil
                
                if($flag){
        
                    Write-Host "This Mailuser $companyemail already exists"
                }
        
                else{
                 
                        Write-Host "Create MailUser for user $companyemail "
        
                        try{

                            $Password = ([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..10] -join ''
                        
                            New-MailUser -Name $name -ExternalEmailAddress $externalemail -MicrosoftOnlineServicesID $companyemail  -Password (ConvertTo-SecureString -String $password -AsPlainText -Force) -FirstName $firstname -LastName $lastname -DisplayName $name -ErrorAction stop

                            $tmp=[pscustomobject]@{Name=$name; PrivateEmail=$externalemail; CompanyEmail=$companyemail}

                            $result2+=$tmp

                            # "$name $password" | Out-File c:\temp\test.txt -Append
                         

                        }catch{
                        
                            $ErrorMessage = $_.Exception.Message
                            Write-Host $ErrorMessage -ForegroundColor Red

                        }

                }
             }

           
        
        }

    
    
    }

    #Assign Exchange Licenses

    if($one.Mailtype -eq 'none' -and $one.Preference -like "*mail box*"){


        	
        $lic=Get-MsolUser -UserPrincipalName $email | select -ExpandProperty licenses | select -ExpandProperty accountskuid
        if($lic -ne $null){
        
            write-host "Licenses is already assigned"
            $lic
        }
        else{
        
            Write-Host "Assign Exchange License to $email" -ForegroundColor Cyan

        Set-MsolUser -UserPrincipalName $email -UsageLocation AU
        Set-MsolUserLicense -UserPrincipalName $email -AddLicenses "vetpartners:EXCHANGESTANDARD"
    
        sleep 5

        $exist=$false
                
        while($exist -eq $false){
            Write-Host "Loading New MailBox" 
        
            $exist = [bool](Get-mailbox $_.name -erroraction SilentlyContinue)

            sleep 5     
        }

        
        }

        
   

    
    }

    
}


$result2 

$result2 | Export-Excel $path -Append


$result2 = Import-Excel 'C:\Temp\todolist\Barkes Corner Veterinary-mailusers.xlsx'
foreach($item in $result2){

    #Force to reset password after 1st sign in

    Set-MsolUserPassword -UserPrincipalName $item.companyemail -ForceChangePassword $true -NewPassword 'Password1234@'


    #Force to register self service password reset


    $userid=Get-MsolUser -UserPrincipalName $item.CompanyEmail | select -ExpandProperty objectid 
    $userid=$userid.Guid


    $groupid=Get-AzureADGroup -SearchString 'enable sspr' | select -ExpandProperty objectid

    Add-AzureADGroupMember -ObjectId $groupid -RefObjectId $userid
}


#$result2  | Export-Excel c:\temp\nsvh-mailuser.xlsx 
  
#######################Verify Result ################################

$mailusers=get-mailuser | where-object { $_.recipienttypedetails -eq "MailUser"} | select name, emailaddresses

$result=@()
#$all=import-excel 'C:\temp\Alexandria - Email Choice.xlsx' -WorksheetName 'Alexandria Vet Clinic'

foreach( $one in $all){
    
    if($one.Name -eq $null){continue}

    $name=$one.Name
    $email=$one.Companyemail
    if($email -ne ''){
        
        $adaccount=get-aduser -Filter { name -eq $name} -Properties mail| select -ExpandProperty mail
    }
    else{
        Write-host "Email is empty, ignore"
        $temp=[pscustomobject]@{Name=$name;CompanyEmail=''; PersonalEmail=$one.Personalemail; Type='None'; Forward=''; Preference=$one.Preference}
        $result+=$temp

        continue
    }


    if($mailusers.name -contains $name){
    
        $type='MailUser'
        $mailuser=$mailusers | Where-Object {$_.name -eq $name}
        $add1=$mailuser.emailaddresses | Select-String -CaseSensitive 'smtp'
        if($add1 -eq $null){
            $add1=$mailuser.emailaddresses | Select-String -CaseSensitive 'SMTP'
           
        }
         $add2=$add1.tostring().split(':')[1]
         $adaccount=$add2
         $forward=''
    }


     elseif($adaccount -like "*"){
        $type="Mailbox"


        
        $forwardAddress=get-mailbox $one.companyemail | select -expand ForwardingSmtpAddress

        if($forwardAddress -ne $null){
            $forward=$forwardAddress.Split(":")[1]
            Write-Host $forward -ForegroundColor Cyan
        }else{
    
            $forward=''
        }
    
        
      
    
    }

     else{
        $type="None"
        

    }


      

    
    $temp=[pscustomobject]@{Name=$name;CompanyEmail=$one.Companyemail; PersonalEmail=$one.Personalemail; Type=$type; Forward=$forward; Preference=$one.Preference}
    $result+=$temp
}


$result | Out-GridView




Remove-PSSession $Session