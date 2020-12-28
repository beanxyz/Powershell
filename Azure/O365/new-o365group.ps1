$365Logon = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $365Logon -Authentication Basic -AllowRedirection
Import-PSSession $Session
$clinicname = "Chatswood"
$displayname = $clinicname + " - Hospital Director"
New-UnifiedGroup –DisplayName $displayname -Alias "$clinicname-HD" -AccessType Private
Add-UnifiedGroupLinks –Identity $displayname –LinkType Members –Links Morgan
Add-UnifiedGroupLinks –Identity $displayname –LinkType Owners –Links Morgan

