#Script to automatically create groups for VetPartners
#Created by Geoff Rose 18 May 2017
Param
(
    [string]$practicename
)
Import-Module azuread

$AzureAdCred = Get-Credential
Connect-AzureAD -Credential $AzureAdCred
Connect-MsolService -Credential $AzureAdCred
#Connects to Exchange Online and loads the PS Cmdlets
$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $AzureAdCred -Authentication "Basic" -AllowRedirection
Import-PSSession $ExchangeSession

$practicename = "Angle Vale"
$practicename = "Dernancourt"
$practicename = "Golden Grove"
$practicename = "Mawson Lakes"
$practicename = "Northgate"
$practicename = "Ridgehaven"
$practicename = "Salisbury Park"

$nurse = "Nurse"
$vets = "Vets"
$practicemanagers = "PracticeManagers"
$Hospitaldirector = "HospitalDirector"
$vendor = "Staff"

$PN = "*" + $practicename 
$DN = (Get-ADOrganizationalUnit -Filter {name -like $PN}).distinguishedname
$email = (get-aduser -SearchBase $DN -Filter * | select -First 1).userprincipalname
$domain = $email.Split("{@}")[1]
$domain = "@" + $domain

$domain = "@vet.partners"

$smtp1 = $practicename + $nurse + $domain
$smtp2 = $practicename + $vets + $domain
$smtp3 = $practicename + $practicemanagers + $domain
$smtp4 = $practicename + $Hospitaldirector + $domain
$smtp5 = $practicename + $vendor + $domain


new-distributiongroup -name "$practicename Nurse" -alias "$practicename`Nurse" -type "security" -primarysmtpaddress $smtp1
new-distributiongroup -name "$practicename Vets" -alias "$practicename`Vets" -type "security" -primarysmtpaddress $smtp2
new-distributiongroup -name "$practicename Practice Managers" -alias "$practicename`PM" -type "security" -primarysmtpaddress $smtp3
new-distributiongroup -name "$practicename Hospital Director" -alias "$practicename`HD" -type "security" -primarysmtpaddress $smtp4
#new-distributiongroup -name "$practicename Vendor" -alias "$practicename`Vendor" -type "security" -primarysmtpaddress $smtp5

