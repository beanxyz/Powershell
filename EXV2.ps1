[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 


Install-Module -Name PowerShellGet -Force

Update-Module -Name PowerShellGet

Install-Module -Name ExchangeOnlineManagement

Update-Module -Name ExchangeOnlineManagement

Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement

$UserCredential = Get-Credential

Connect-ExchangeOnline -Credential $UserCredential -ShowProgress $true

Connect-ExchangeOnline -UserPrincipalName xyli@vet.partners -ShowProgress $true

Get-EXOMailbox yuan.li | select *
Get-EXOMailbox -PropertySets Archive,Custom

Get-EXOMailbox -Properties IsMailboxEnabled,SamAccountName -PropertySets Delivery -ResultSize 4