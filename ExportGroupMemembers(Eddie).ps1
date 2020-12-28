$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking


$DGName = "Figtree - Hospital Director"
Get-DistributionGroupMember -Identity $DGName | Select Name, PrimarySMTPAddress |
Export-CSV "C:\\Figtree - Hospital Director.csv" -NoTypeInformation -Encoding UTF8
