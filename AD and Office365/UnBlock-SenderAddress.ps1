Write-Host "Removing Session"
Get-PSSession | Remove-PSSession

Write-Host "Login to Office365"
$password = ConvertTo-SecureString 'Vets5000' -AsPlainText -Force
$Usercredential = New-Object System.Management.Automation.PSCredential ('support@vetpartners.com.au', $password)

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking


write-host "Unblock accounts"

$all= Get-BlockedSenderAddress

if($all -eq $null){
    Write-Host "nothing dected"
}
else{
 #   $body=$all[0].senderaddress
 #   Send-MailMessage -From support@vetpartners.com.au -to yuan.li@vet.partners -Body $body -Subject "Unblock sender address" -SmtpServer smtp.office365.com -Port 587 -UseSsl
}

Get-BlockedSenderAddress | ForEach-Object -Process {Remove-BlockedSenderAddress -SenderAddress $_.senderaddress}