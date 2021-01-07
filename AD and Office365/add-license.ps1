<#This is a script to import a csv list of users then add the exchange online license to their accounts
There must be available licenses in O365 so create these first if required.
Also use one of the scripts e.g. new user to create the connection to exchange online first.
Created by Geoff Rose 17 August 2017
#>
$users = import-csv C:\Users\xgrose\Documents\jsv.csv
Foreach ($user in $users) {
write-host $user.firstname
    $UserFirstname = $User.Firstname
    $UserLastname = $User.Lastname
    $UserLastnamenospace = $UserLastname -replace(' ',"") -replace('-','')
    $UserFirstnamenospace = $UserFirstname -replace(' ',"")
    $SAM = $UserFirstnamenospace + "." + $UserLastnamenospace
    $maxchar = $sam.Length - 20
    $sam = $sam -replace ".{$maxchar}$"

    write-host "now processing $Displayname"
    $email = (Get-ADUser -Identity $sam).userprincipalname
    Set-MsolUser -UserPrincipalName $email -UsageLocation AU
    Set-MsolUserLicense -UserPrincipalName $email -AddLicenses "vetpartners:EXCHANGESTANDARD"
}

