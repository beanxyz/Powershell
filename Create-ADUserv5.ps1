
################# Connect Exchange Online PowerShell V2 #####################
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


$credential=Get-Credential
$credential.Password | ConvertFrom-SecureString | set-content "c:\temp\password.txt"
$password = Get-Content "C:\temp\password.txt" | ConvertTo-SecureString 
$credential = New-Object System.Management.Automation.PsCredential("700.eddie@vet.partners",$password)
Connect-ExchangeOnline -Credential $credential -ShowProgress $true
Connect-MsolService -Credential $credential
Connect-AzureAD -Credential $credential



$filepath='C:\Temp\Copy of New_Start_HR3_15-12-2020.xlsx'
$users=Import-Excel $filepath -StartRow 2
$masterlist=import-excel 'C:\temp\Master list.xlsx' -WorksheetName 'Group and AD'
$path1='c:\temp\Copy of New_Start_HR3_15-12-2020.xlsx'
$path2='c:\temp\Copy of New_Start_HR3_15-12-2020.xlsx'

$result1=@()
$result2=@()

foreach($user in $users){
   # $user
    if($user.ignore -eq 'yes'){continue}



    $profitcode=$user.'cost Centre Code'
    if($profitcode -eq $null ){
        
        continue
   }

    $firstname=$user.'First Name'.Split()[0].trim()
    $firstname=$firstname.Split('-')[0]
    $lastname=$user.'Surname'.split()[-1].Trim()
    $privatemail=$user.'Email (Kiosk)'
    $mailtype=$user.'VetPartners Email'
    $extensionattribute15=$user.'Employee no.'
    $Position=$user.Position
    $status=$user.status


   

   if($status -like '*transfer*'){
        #manual update at moment
        continue

   }
 
   
   
    #Create Mailbox and Mailuser
    
    $flag=0
    foreach($line in $masterlist){
     
    
        if($line.'profitcode' -eq $profitcode){
           
            $clinicName=$line.'HospitalName'
            if($line.DomainOwnership -like '*yes*'){
                
            $domainname=$line.PrimaryDomain

            }else{
            
                $domainname='vetpartners.net.au'
                
            }


            if($Position -like '*Locum*'){
            
                $domainname='vetpartners.net.au'
                $ou="OU=Locum,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"
            }

            if($Position -like "*intern*"){
                $domainname='vetpartners.net.au'
                $ou='OU=Interns,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au'
            
            }

            if($Position -like "*Support Office*"){
                $domainname='vetpartners.com.au'
                $mailtype='yes'
            }


            $upn="$firstname.$lastname@$domainname".ToLower()
            $displayname="$firstname $lastname"
            $firstname=$firstname.split()[0]
       
            $lastname=$lastname.Split()[-1]
            $sam=$firstname+"."+$lastname
            $password='B9F($8@7mXR@'

            
            $ou=$line.ou
            $flag=1

            #Create Mailbox

            if($mailtype -eq 'Yes'){

                $result=get-aduser -Filter {userprincipalname -eq $upn }


                if(!$result){
            
                $newuser = @{
                    Name = $Displayname
                    DisplayName = $Displayname
                    EmailAddress = $upn
                    SamAccountName = $sam
                    UserPrincipalName = $upn
                    GivenName = $Firstname
                    Surname = $Lastname
                    #password=$password
                    PasswordNeverExpires = $false
                    AccountPassword = (ConvertTo-SecureString $password -AsPlainText -Force)
                    Enabled = $true
                    Path = $OU
                    ChangePasswordAtLogon = $false
                    
                }
               # Write-Host 'Create new AD account for $upn'
         

                New-ADUser @newuser 
                Add-ADGroupMember -Members $sam -Identity "VetPartners - All" 
    
                Set-ADUser $sam -Add @{proxyAddresses="SMTP:"+$upn;mailNickname=$Displayname} 
               
                get-aduser -filter { userprincipalname -eq $upn} -ErrorAction SilentlyContinue -ErrorVariable aa -Properties * | Set-ADUser -Replace @{extensionattribute15=$extensionattribute15.ToString()}
                $temp1=[pscustomobject]$newuser
                $result1+=$temp1
            
            }
                else{

                    Write-Host "AD account $upn exists"

                           
            }

            #Create mailuser
            }else{
                

                 $flag2=get-mailuser $displayname -erroraction sil
                
                if($flag2){
        
                    Write-Host "This Mailuser $upn already exists"
                    continue
                }
        
                else{
                 
                        Write-Host "Create MailUser for user $upn "
        
                        try{

                            $Password = 'B9F($8@7mXR@'
                        
                            New-MailUser -Name $displayname -ExternalEmailAddress $privatemail -MicrosoftOnlineServicesID $upn  -Password (ConvertTo-SecureString -String $password -AsPlainText -Force) -FirstName $firstname -LastName $lastname -DisplayName $displayname -ErrorAction stop

                            $tmp=[pscustomobject]@{Name=$displayname; PrivateEmail=$privatemail; CompanyEmail=$upn}


                            write-host 'Wait for 5 sec until the mailuser is ready'
                            sleep 5

                            get-mailuser $displayname | Set-MailUser -CustomAttribute15 $extensionattribute15


                            $result2+=$tmp

                            
                         

                        }catch{
                        
                            $ErrorMessage = $_.Exception.Message
                            Write-Host $ErrorMessage -ForegroundColor Red

                        }

                }



                
            }

        }
    
        
    
    }

    if($flag -eq 0){
    
        Write-host "Could not find the Clinic info from the profit Code $profitcode" -ForegroundColor Red
        continue
    }
   
   



}

write-host "New Mailbox users" -ForegroundColor Green

$result1 | Export-Excel $path1 -Append
$result1=Import-Excel $path1
$result1

write-host "New Mailusers " -ForegroundColor Green

if($result2 -ne $null){
$result2 | Export-Excel $path2 -Append
$result2=Import-Excel $path2
$result2
}

$result2=Import-Excel $path2


if($result2 -ne $null){
    

    foreach($item in $result2){

        $upn=$item.companyemail.trim()
        $name=$item.Name
        Set-MsolUserPassword -UserPrincipalName $upn -ForceChangePassword $true -NewPassword 'B9F($8@7mXR@'


        #Force to register self service password reset
                          

        $userid=Get-MsolUser -UserPrincipalName $upn | select -ExpandProperty objectid 
        $userid=$userid.Guid


        $groupid=Get-AzureADGroup -SearchString 'enable sspr' | select -ExpandProperty objectid

        $member=Get-AzureADGroupMember -ObjectId $groupid 

        if($member.displayname -contains $name){
            'This mailuser is already in the sspr group'
        }
        else{

        try{
            Add-AzureADGroupMember -ObjectId $groupid -RefObjectId $userid
            }

        catch{
            "The user $upn is already added"        
        
        }
        }


  

    }

}


start-ADSyncSyncCycle -PolicyType Delta

############################ Wait for 5 min #################################


if (Test-Path $path1){

$result1=Import-Excel $path1
}

else{

    "$path1 doesn't exist"
}

$check=$true

while($check){
    foreach($one in $result1){

        $email=$one.EmailAddress

        try{
            Get-MsolUser -UserPrincipalName ($one.emailaddress) -ErrorAction Stop
            #Write-Host "The Mailbox user $email is ready to go"
            $check=$false
        }catch{
            write-host  "The Mailbox user $email is not sync yet" -ForegroundColor Red
            sleep 2
            $check=$true
            break
        }

    }
}



# Assign License to new Mailbox users
$users=Import-Excel $path1

foreach($user in $users){
    
    $upn=$user.userprincipalname

    if($upn -ne $null){
        	
    $lic=Get-MsolUser -UserPrincipalName $upn | select -ExpandProperty licenses | select -ExpandProperty accountskuid
    if($lic -ne $null){
        
        write-host "Licenses for $upn is already assigned"
        $lic
        continue
    }
    else{
        
        Write-Host "Assign Exchange License to $upn" -ForegroundColor Cyan
        Set-MsolUser -UserPrincipalName $upn -UsageLocation AU
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses "vetpartners:EXCHANGESTANDARD"
    
}
}
}





# Update Group


$users=import-excel $filepath -StartRow 2
$masterlist=Import-Excel 'C:\temp\Master list.xlsx' -WorksheetName 'group and ad'


foreach($user in $users){

    if($user.Clinic -eq $null){continue}

    $profitcode=$user.'Cost Centre Code'.ToString().trim()
    $firstname=$user.'First Name'.Split()[0].split('-')[0]
    $lastname=$user.'Surname'.split()[-1].Trim()
    $privatemail=$user.'Email (Kiosk)'
    $mailtype=$user.'VetPartners Email'
    $position=$user.Position

    
    foreach($clinic in $masterlist){

        $code=$clinic.Profitcode


        if( $code -eq $profitcode){
            #"Found"        
            $teamgroup=$clinic.TeamGroupName
            $hdgroup=$clinic.HDGroupName
            $vetgroup=$clinic.VetsGroupName
            $nursegroup=$clinic.NurseGroupName
            $pmgroup=$clinic.PMGroupName
            #$clinic
            if($clinic.DomainOwnership -like '*yes*'){
                
                $domainname=$clinic.PrimaryDomain

            }else{
            
                $domainname='vetpartners.net.au'
            }
            

            if($Position -like '*Locum*'){
                Write-Host "$firstname $lastname is locum, ignore" -ForegroundColor Yellow
            
                continue
            }

            if($Position -like "*intern*"){
                $domainname='vetpartners.net.au'
                $ou='OU=Interns,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au'
            
            }

            if($Position -like "*Support Office*"){
                $domainname='vetpartners.com.au'
                $mailtype='yes'
            }
            $upn="$firstname.$lastname@$domainname".ToLower()

            #$upn

        
        if($user.Position -eq 'Vet'){
            
            $names=Get-DistributionGroupMember -Identity $vetgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $upn){
            
                Write-Host "$upn already exists in the $vetgroup"
            }

            else{
                    Add-DistributionGroupMember -Identity $vetgroup -Member $upn
            }
              
        }
        elseif($user.Position -eq 'Nurse'){
            

            $names=Get-DistributionGroupMember -Identity $nursegroup | select name, windowsliveid

            if ($names.windowsliveid -contains $upn){
            
                Write-Host "$upn already exists in the $nursegroup"
            }

            else{
            
            Add-DistributionGroupMember -Identity $nursegroup -Member $upn
            }
        }
           elseif($user.Position -eq 'Practice Manager'){
            

            $names=Get-DistributionGroupMember -Identity $pmgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $upn){
            
                Write-Host "$upn already exists in the $pmgroup"
            }

            else{
            
            Add-DistributionGroupMember -Identity $pmgroup -Member $upn
            }
        }


           elseif($user.Position -eq 'Hospital Director'){
            

            $names=Get-DistributionGroupMember -Identity $hdgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $upn){
            
                Write-Host "$upn already exists in the $hdgroup"
            }

            else{
            
            Add-DistributionGroupMember -Identity $hdgroup -Member $upn
            }
        }




        else{

            $names=Get-DistributionGroupMember -Identity $teamgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $upn){
            
                Write-Host "$upn already exists in the $teamgroup"
            }

            else{
                $teamgroup

                Add-DistributionGroupMember -Identity $teamgroup -Member $upn
                }
            
        }
        

        
        }



    }

}

