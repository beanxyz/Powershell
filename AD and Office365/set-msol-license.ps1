$AzureAdCred = Get-Credential
Connect-AzureAD -Credential $AzureAdCred
Connect-MsolService -Credential $AzureAdCred

$users = Import-Csv C:\Users\xgrose\Documents\users1\ryde.csv

#Section to associate user to Exchange Online license
    foreach ($user in $users) {
    $Displayname = $User.name
    $UserFirstname = $Displayname.split()[0]
    $UserLastname = $Displayname.split()[1]
    $SAM = $UserFirstname + "." + $UserLastname
    write-host "now processing $Displayname"
    $email = (Get-ADUser -Identity $sam).userprincipalname
    Set-MsolUser -UserPrincipalName $email -UsageLocation AU
    Set-MsolUserLicense -UserPrincipalName $email -AddLicenses "vetpartners:EXCHANGESTANDARD"
    }



    $Displayname = "Lucy Asher"
    $users
