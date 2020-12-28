#Script to automatically create users for VetPartners - this will eventually be converted to be used with a webform
#Created by Geoff Rose 18 May 2017
Param
(
    [string]$firstname,
    [string]$lastname,
    [string]$domain,
    [string]$position
)

$AzureAdCred = Get-Credential
Connect-MsolService -Credential $AzureAdCred

    $ou = ((get-aduser -Filter * | Where-Object {$_.userprincipalname -like "*$domain"} | select -First 1).DistinguishedName -split “,”, 2)[1]
    $Displayname = $firstname + " " + $lastname
    $SAM = ($Firstname + "." + $Lastname).ToLower()
    $Password = "V3tP@rtners"
    $email = $sam + "@" + $domain 

write-host "creating user $Displayname"

#SAM can only be max of 20 Char
    $maxchar = $sam.Length - 20
    $sam = $sam -replace ".{$maxchar}$"
    write-host "$Displayname was trimmed!"

 #Create a hashtable for the new user's data
  $newuser = @{
        Name = $Displayname
        DisplayName = $Displayname
        EmailAddress = $email
        SamAccountName = $SAM
        UserPrincipalName = $email
        GivenName = $firstname
        Surname = $Lastname
        AccountPassword = (ConvertTo-SecureString $Password -AsPlainText -Force)
        Enabled = $true
        Path = $OU
        ChangePasswordAtLogon = $true
        PasswordNeverExpires = $false
        }



    #Create the new user with the data from the hashtable
    New-ADUser @newuser  
    #Check for group membership and add to the group if 1 is specified in the CSV
    $nursegroup = (get-adgroup -SearchBase $OU -Filter {Name -like "*Nurse*"}).name
    $pmgroup = (get-adgroup -SearchBase $OU -Filter {Name -like "*Practice*"}).name
    $vetgroup = (get-adgroup -SearchBase $OU -Filter {Name -like "*Vet*"}).name
    $hosdirgroup = (get-adgroup -SearchBase $OU -Filter {Name -like "*Hospital*"}).name
    $teamgroup = (get-adgroup -SearchBase $OU -Filter {Name -like "*Team*"}).name
    if ($position -eq "Nurse") {Add-ADGroupMember -Members $sam -Identity $nursegroup} 
    if ($position -eq "PM") {Add-ADGroupMember -Members $sam -Identity $pmgroup}
    if ($position -eq "Vet") {Add-ADGroupMember -Members $sam -Identity $vetgroup}
    if ($position -eq "HD") {Add-ADGroupMember -Members $sam -Identity $hosdirgroup}
    #Add the user to the Team group
    Add-ADGroupMember -Members $sam -Identity $teamgroup 
    #Set the AD attributes    
Set-ADUser $sam -Add @{proxyAddresses="SMTP:"+$email;mailNickname=$Displayname}
#Sync account to Azure AD
Invoke-Command -ComputerName "au-svr-av-01" -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
write-host "Waiting for new account to sync to Azure"
Start-Sleep 90
write-host "Now assigning License"
#Assign the Office 365 License - note: licenses must be available
Set-MsolUser -UserPrincipalName $email -UsageLocation AU
Set-MsolUserLicense -UserPrincipalName $email -AddLicenses "vetpartners:EXCHANGESTANDARD"