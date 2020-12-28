#Connect to O365 if required
$creds = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $creds  -Authentication Basic -AllowRedirection
Import-PSSession $Session
#note this script will replace and not add to existing owners of groups
$manager = "robyn.whitaker@vetpartners.com.au"
$groups = Get-DistributionGroup | Where-Object {$_.identity -like "WA -*"}
foreach ($group in $groups) {Set-DistributionGroup -Identity $group.name -ManagedBy $manager}
