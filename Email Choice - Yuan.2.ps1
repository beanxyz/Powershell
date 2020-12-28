
function Precheck-file{
    
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $filename

       
    )

    Begin
    {
        if(Test-Path $filename){
            Write-Verbose "Loading file from $filename"
            
            $all=import-excel $filename -WorksheetName 'Email Choice'
        }
        else{
            Write-Error "Can't find the filepath $filename"
        }

    }
    Process
    {
        #Check OU information
        $temp=$all | Where-Object {$_.'mailtype' -eq 'mailbox'} | select -First 1
        $tempemail=$temp.Companyemail
        $domain=$tempemail.split('@')[1]

        try{
            $tmpuser=get-aduser -filter { mail -eq $tempemail} -ErrorAction Stop
            $OU = "OU="+($tmpuser.DistinguishedName -split "=",3)[-1]
            Write-Verbose "OU is $ou"
        }catch{
            Write-HOST "Can't retrieve OU information, please review your master file and excel file" -ForegroundColor Red
            
        }


     


        foreach($one in $all){

            write-verbose $one.Companyemail
            
            <#$mail=$one.Companyemail
            $name=$one.Firstname+ " "+$one.Proper
             try{
                    $tmpuser=get-aduser -filter { name -eq $name} -ErrorAction Stop
                    $mail2=$tmpuser.userprincipalname
                    if($mail2 -ne $mail){

                        write-host "$Name is in AD, but its email address is $mail2"
                    }


                }catch{
                    break
                }



                #>

            if($one.proper -eq $null){
            
                Write-host "Proper column is empty " -
                
            }

            $email=$one.Companyemail
           
            if($one.Companyemail.Split().count -ne 1){
                Write-host "There are space in the company email address $email" -ForegroundColor Red
                
            }

            if($one.Preference -like "*Select*"){
                Write-host "This user $email hasn't choose a preference yet" -ForegroundColor Red
            }

            if($one.mailtype -eq 'mailbox' -and $one.preference -like "*Mail user*" -and $one.'Mailbox backed up?' -like "*no*"){
    
                $name=$one.name
                Write-HOST "Mailbox $name has not been backed up yet, please update the file and try again " -ForegroundColor Red
         
    
            }


                 # check email 
            $domain2=$one.Companyemail.Split('@')[1]

            if ($domain2 -ne $domain){
                $name=$one.name
                $e=$one.Companyemail
                Write-HOST "Mailbox $name has a different company email $e and the domain should be $domain" -ForegroundColor Red
            }

        
        }

        
             # check replication
        $a=$all.personalemail
        $ht = @{}
        $a | foreach {$ht["$_"] += 1}
        $ht.keys | where {$ht["$_"] -gt 1} | foreach {write-host "Duplicate element found $_" -ForegroundColor Red }

 

    }
    End
    {
        Write-Verbose "Prescan completed"
        return $OU
    }
}

function Connect-Office365{


#$credential.Password | ConvertFrom-SecureString | set-content "c:\temp\password.txt"
    $session=Get-PSSession

    if( $session.ComputerName -eq 'outlook.office365.com' -and $session.State -eq 'opened'){

        Write-host 'PowerShell Exchange Online is connected'
    }
    else{
        $password = Get-Content "C:\temp\password.txt" | ConvertTo-SecureString 
        $credential = New-Object System.Management.Automation.PsCredential("xyli@vet.partners",$password)
        Connect-ExchangeOnline -Credential $credential -ShowProgress $true
        Connect-MsolService -Credential $credential
        Connect-AzureAD -Credential $credential

    }

}

function Create-ADuser{
   Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $filename,
        [string]
        $OU

       
    )
    $all=import-excel $filename -WorksheetName 'Email Choice'
    foreach($one in $all){
    
    $name=$one.name
    $companyemail=$one.Companyemail
    $externalemail=$one.Personalemail
    $firstname=$one.Firstname.Split()[0]
    $lastname=$one.Surname
    $externalemail=$one.Personalemail
  


# New Mailuser

    if($one.Mailtype -eq 'none' -and $one.Preference -like '*Mail User*'){

        $result=get-aduser -Filter {userprincipalname -eq $companyemail}

        if ($result -eq $null){
  
        
        }

        else {
        # Excel error 
         
            Write-Verbose "Delete AD account $companyemail - >  convert to Mailuser" 
        
            get-aduser -Filter  {userprincipalname -eq $companyemail}| Remove-ADUser -Confirm:$false 
            
        
        }



    }


# Convert existing mailbox to mailuser ->  delete AD first !

    if( $one.mailtype -eq 'mailbox' -and $one.preference -like '*Mail User*'){
   


        Write-Verbose "Delete AD account $companyemail - >  convert from mailbox to mailuser" 

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
        $Password = "Password1234@"
        write-host "creating user $Displayname" -ForegroundColor Green

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
        
            #Add-ADGroupMember -Members $sam -Identity "VetPartners - All" 
        
         
            Set-ADUser $sam -Add @{proxyAddresses="SMTP:"+$email2;mailNickname=$Displayname} 
        
        }
        else{
            Write-Host "$sam has already existed in your AD" -ForegroundColor Yellow
            # Add Email address
            #set-aduser $sam -EmailAddress $email2
            #Set-ADUser $sam -Add @{proxyAddresses="SMTP:"+$email2;mailNickname=$Displayname} 
            
        }

       
    }



}


}

function clean-clouduser {

    Param
        (
            # Param1 help description
            [Parameter(Mandatory=$true,
                       ValueFromPipelineByPropertyName=$true,
                       Position=0)]
            [string]
            $filename

       
        )

    $all=import-excel $filename -WorksheetName 'Email Choice'

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
    


############### Clean Mail Guest Users#####################################
        if($mailguestuers.mail -contains $externalemail){
        
            Write-Host "Guest User account $externalemail exists - Deleting " -ForegroundColor Yellow
            
            foreach($guest in $mailguestuers){
                if($guest.mail -eq $externalemail){
                
                        Remove-AzureADUser -ObjectId $guest.ObjectID -Verbose    

                
                }
            
            }
            
            
        
        
        }  

############## Clean Mail Contact ##########################################
        if($mailcontact.email -contains $externalemail){
            Write-Host "MailContact account exists - Deleting " -ForegroundColor Yellow
            
            get-mailcontact -Filter "externalemailaddress -like '*$externalemail*'" | Remove-MailContact 

        
        }
        
    
      

    }



    }




}

function Assign-License{
    Param
        (
            # Param1 help description
            [Parameter(Mandatory=$true,
                       ValueFromPipelineByPropertyName=$true,
                       Position=0)]
            [string]
            $filename

       
        )

    $all=import-excel $filename -WorksheetName 'Email Choice'

    foreach($one in $all){

        $email=$one.companyemail
        if($one.Mailtype -eq 'none' -and $one.Preference -like "*mail box*"){
                Write-Verbose $one
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

        
        }
    
    }

    }

}

function Create-MailUser{
    Param
        (
            # Param1 help description
            [Parameter(Mandatory=$true,
                       ValueFromPipelineByPropertyName=$true,
                       Position=0)]
            [string]
            $filename,
            [string]
            $outputpath

       
        )

    $all=import-excel $filename -WorksheetName 'Email Choice'
    $result2=@()
    foreach($one in $all){
    
    $companyemail=$one.Companyemail.trim()
    $externalemail=$one.Personalemail.trim()
    $firstname=$one.Firstname.Trim()
    $lastname=$one.Proper.trim()
    $email=$one.Companyemail
    $externalemail=$one.Personalemail
    $name=$firstname+" "+$lastname
    $samaccount="$firstname.$lastname"
   # write-host $samaccount

#################Create new mailuser######################################

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

                            get-mailuser -Identity $companyemail | Set-MailUser -PrimarySmtpAddress $companyemail

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

}

    $result2 
    $result2 | Export-Excel $outputpath -Append
    #$result2 = Import-Excel $outputpath
    $result3= $all | Where-Object {$_.preference -like "*mail user*"} | select firstname, surname,personalemail,companyemail
    foreach($item in $result3){
    $upn=$item.Companyemail
    #Force to reset password after 1st sign in

    Set-MsolUserPassword -UserPrincipalName $item.companyemail -ForceChangePassword $true -NewPassword 'Password1234@'

    Write-Verbose "Swap Mailuser Primary address $upn"
    get-mailuser -Identity $upn | Set-MailUser -PrimarySmtpAddress $upn
    #Force to register self service password reset


    $userid=Get-MsolUser -UserPrincipalName $item.CompanyEmail | select -ExpandProperty objectid 
    $userid=$userid.Guid


    $groupid=Get-AzureADGroup -SearchString 'enable sspr' | select -ExpandProperty objectid
    try{
    Add-AzureADGroupMember -ObjectId $groupid -RefObjectId $userid -ErrorAction Stop
    }
    catch{
    "$upn is already in the sspr group"
    }
}


}

function Update-Group{
 Param
        (
            # Param1 help description
            [Parameter(Mandatory=$true,
                       ValueFromPipelineByPropertyName=$true,
                       Position=0)]
            [string]
            $filename

       
        )

    $all=import-excel $filename -WorksheetName 'Email Choice'
    $masterlist=Import-Excel 'C:\temp\Master list.xlsx' -WorksheetName 'group and ad'


    $name=$all[0].Clinic

    foreach($clinic in $masterlist){
    
        if( $clinic.hospital -eq $name){
        $teamgroup=$clinic.TeamGroupName.Trim()
        $hdgroup=$clinic.HDGroupName.Trim()
        $vetgroup=$clinic.VetsGroupName.Trim()
        $nursegroup=$clinic.NurseGroupName.trim()
        $pmgroup=$clinic.PMGroupName.Trim()

        }

    }


    Write-Host "You will users into following groups" -ForegroundColor Yellow
    Write-Host $teamgroup
    Write-Host $hdgroup
    Write-Host $vetgroup
    Write-Host $nursegroup
    Write-Host $pmgroup

    $choice=Read-Host "Do you want to continue ? (y/n)"


    if($choice -eq 'n'){exit}

    foreach($one in $all){

    if($one.Preference -like '*ignore*'){
    
        continue
    
    }

    $companyemail=$one.CompanyEmail.trim()
    write-verbose "#########Processing $companyemail##########"
        
    if($companyemail -eq $null){
    
        $companyemail =''
    }


    if($companyemail -ne ''){


        if($one.Classification -like "*locum*"){ continue}


        
        if($one.Classification -like '*vet*'){  
        
            $names=Get-DistributionGroupMember -Identity $vetgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $companyemail){
            
                Write-Verbose "$companyemail already exists in the $vetgroup"
            }
            else{
                    Write-host "Add $companyemail into $vetgroup"
                    Add-DistributionGroupMember -Identity $vetgroup -Member $companyemail

                }
        }

        if($one.Classification -like "*nurse*"){
            $names=Get-DistributionGroupMember -Identity $nursegroup | select name, windowsliveid

            if ($names.windowsliveid -contains $companyemail){
            
                Write-Verbose "$companyemail already exists in the $nursegroup"
            }
            else{
                    Write-host "Add $companyemail into $nursegroup"
                    Add-DistributionGroupMember -Identity $nursegroup -Member $companyemail
                }
        }
    
        if($one.'Is this person the PM/HD?' -like "*PM*"){
        
            $names=Get-DistributionGroupMember -Identity $pmgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $companyemail){
            
                Write-Verbose "$companyemail already exists in the $pmgroup"
            }
            else{

                Write-host "Add $companyemail into $pmgroup"
                Add-DistributionGroupMember -Identity $pmgroup -Member $companyemail
                }
        }
     
        if($one.'Is this person the PM/HD?' -like "*HD*"){

        
            $names=Get-DistributionGroupMember -Identity $hdgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $companyemail){
            
                Write-Verbose "$companyemail already exists in the $hdgroup"
            }
            else{

                Write-Host "Add $companyemail into $hdgroup"
                Add-DistributionGroupMember -Identity $hdgroup -Member $companyemail
                }
        
        }
    
        else{
        
            $names=Get-DistributionGroupMember -Identity $teamgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $companyemail){
            
                Write-Verbose "$companyemail already exists in the $teamgroup"
            }
            else{
                 Write-Host "Add $companyemail into $teamgroup"
                Add-DistributionGroupMember -Identity $teamgroup -Member $companyemail
                }
        
        
        }    
    
    }

    else{
        $name=$one.Name
        write-host "Locum users $name , ignore" -ForegroundColor Yellow
    }

}

}

function Verify-account{
     Param
        (
            # Param1 help description
            [Parameter(Mandatory=$true,
                       ValueFromPipelineByPropertyName=$true,
                       Position=0)]
            [string]
            $filename,
            [string]
            $outputpath

       
        )

    $all=import-excel $filename -WorksheetName 'Email Choice'
    $mailusers=get-mailuser -ResultSize unlimited | where-object { $_.recipienttypedetails -eq "MailUser"} | select name, emailaddresses
    $result=@()
    foreach( $one in $all){
    
        if($one.Name -eq $null){continue}
        $name=$one.Name
        $email=$one.Companyemail
        if($email -ne ''){
        
            $adaccount=get-aduser -Filter { userprincipalname -eq $email} -Properties mail| select -ExpandProperty mail
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


}



#$file="C:\Temp\(EaYa)  Sunbury Animal Hospital - Email Choice.xlsx"
#$path='C:\temp\Sunbury Hospital mailuser.xlsx'

#$file=  'C:\temp\(EaYa)  Gisborne Veterinary Clinic - Email Choice.xlsx'
#$path = 'C:\temp\gisborne mailuser.xlsx'
$file = 'C:\temp\TA - Vet Associates Takanini (002).xlsx'
$path= 'c:\temp\takanini mailuser.xlsx'


$OU=Precheck-file -filename $file -Verbose


#$OU='OU=2.570 Email Users,OU=2.570 Camden Valley,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au'
#$OU='OU=3.002 Email Users,OU=3.002 Ferntree Gully,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au'


Connect-Office365

Create-ADuser -filename $file -OU $OU -Verbose

Start-ADSyncSyncCycle -PolicyType Delta

clean-clouduser -filename $file -Verbose

Assign-License -filename $file -Verbose

Create-MailUser -filename $file -outputpath $path -Verbose

Verify-account -filename $file -Verbose

Update-Group -filename $file -Verbose