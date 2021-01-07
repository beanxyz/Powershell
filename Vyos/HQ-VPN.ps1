. C:\Scripts\Function-Write-Log.ps1
$date = Get-Date -Format yyyyddMM

#Credentials
$secpasswd = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000db00a10114a7bc48a287b2069f6ca3240000000002000000000003660000c00000001000000022c117b9125b0933460064b000d1643d0000000004800000a0000000100000004d557d9e9192a99e0c33264889c19b9218000000ccb5fe411a9ae020af9572cf56849271e3e4a44f08a284a314000000b6a1ef3dd108c1eb995137e7ded07e0ab9dafdfd" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential (“invpro@vetpartners.com.au”, $secpasswd)

#Connects to Office 365 for account
Connect-OSCEXOWebService -Credential $credential

#Log Settings
$logfile = "C:\scripts\log\$date-vpn.log"


#Begin Main Program

#for ($i=0;$i -lt 5;$i++) {
while ($true)
{
$connstatus = Test-Connection -ComputerName hq-router.on.vetpartners.com.au  -Count 1 | Select-Object Address,responsetime
if ($connstatus -eq $null) 
    {
    Write-Log "VPN is down! Waiting 10 Seconds" -PATH $logfile
    start-sleep 10
    $connstatus = Test-Connection -ComputerName hq-router.on.vetpartners.com.au  -Count 1 | Select-Object Address,responsetime
        if ($connstatus -eq $null)
           {
           Write-Log "VPN is down again! Waiting 30 Seconds" -PATH $logfile
           start-sleep 30
           $connstatus = Test-Connection -ComputerName hq-router.on.vetpartners.com.au  -Count 1 | Select-Object Address,responsetime
                if ($connstatus -eq $null) 
                {
                Write-Log "VPN is confirmed down!" -PATH $logfile
                Send-MailMessage -Subject "Alert! VPN Connection To HQ is DOWN!!!" -Credential $credential -SmtpServer smtp.office365.com -From invpro@vetpartners.com.au -To it-all@vetpartners.com.au -UseSsl -Port 587
                Start-Sleep 600
                }
            }
    }
Else
    {
    Write-Log -Message $connstatus -Path $logfile
    Start-Sleep 15
    }
}