Connect-ExchangeOnline -UserPrincipalName yli@nvcltd.com.au 


# Login to Office365 online 


$sender='twenty3events@live.com.au'



$messages=Get-MessageTrace -SenderAddress $sender -StartDate (get-date).AddDays(-10) -EndDate (get-date)| Where-Object { $_.status -eq 'delivered'} 

$messages=Get-MessageTrace -StartDate (get-date).AddDays(-1) -EndDate (get-date)| Where-Object { $_.status -eq 'delivered'} 
$m=$messages | Where-Object {$_.subject -like "*Your Village*"}


$i=0
$count=$m | measure | select -ExpandProperty count

foreach($one in $m){
    

       
    $user=$one.'recipientaddress'
    $subject=$one.subject
    $i++
    #$user
    Write-Progress -activity "Scanning User $user . . ." -status "Scanned: $i of $count" -percentComplete (($i / $count)  * 100)
   Search-Mailbox $user -SearchQuery "subject:$subject received:14-Oct-2020..15-Oct-2020" -DeleteContent -force 



    #New-ComplianceSearch -Name "Remove Phishing Message" -ExchangeLocation all -ContentMatchQuery "subject:$subject"



}



$UserCredential = Get-Credential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic –AllowRedirection

Import-PSSession $Session



Connect-IPPSSession -UserPrincipalName xyli@vet.partners



$Search=New-ComplianceSearch -Name "Remove Phishing Message" -ExchangeLocation All -ContentMatchQuery '(Received:11/22/2020..11/23/2020) AND (Subject:"[External]  Your Village Vet Balgownie")'
Start-ComplianceSearch -Identity $Search.Identity

Get-ComplianceSearch | sort JobEndTime

New-ComplianceSearchAction -SearchName "Remove Phishing Message" -Purge -PurgeType SoftDelete

Get-ComplianceSearchAction 