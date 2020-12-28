#Set-MsolUserPrincipalName -UserPrincipalName pathology@vetpartners.com.au -NewUserPrincipalName pathology@southpaws.com.au

$password = ConvertTo-SecureString '8qtVoKID' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ('support@vetpartners.com.au', $password)

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection

Import-PSSession $Session -DisableNameChecking


Get-TransportRule "Prevent Display Name Spam" | select *



$name=Get-ADGroupMember "support office" -Recursive | select -ExpandProperty name | sort



#set-TransportRule "Prevent Display Name Spam" -HeaderContainsWords $name  -HeaderContainsMessageHeader "From"
set-TransportRule "External" -HeaderContainsWords $name  -HeaderContainsMessageHeader "From"

#Get-TransportRule "Prevent Display Name Spam" | select -ExpandProperty headercontainswords 

Get-TransportRule "External" | select -ExpandProperty headercontainswords 
Get-PSSession | Remove-PSSession
