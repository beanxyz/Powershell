

function Check_Message($sender='helpdesk@vetpartners.com.au', $hour=1){



$password = "8qtVoKID" | ConvertTo-SecureString -asPlainText -Force
$username = "support@vetpartners.com.au" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password)


$session=Get-PSSession

if($session.ComputerName -like "outlook.office365*"){
    Write-Host "Outlook.Office365.com session is connected" -ForegroundColor Cyan
}
else{
    #MFA Authentication#
    #Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch "_none_"}|select -First 1)
    #$EXOSession = New-ExoPSSession
    #Import-PSSession $EXOSession

    #Normal login

    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
    Import-PSSession $Session
    Connect-MsolService -Credential $credential

}


$dateEnd = get-date 
$dateStart = $dateEnd.AddHours(-$hour)


Get-MessageTrace -StartDate $dateStart -EndDate $dateEnd -SenderAddress $sender| Select-Object @{name='time';e={[System.TimeZone]::CurrentTimeZone.ToLocalTime($_.received)}}, SenderAddress, RecipientAddress, Subject, Status, ToIP, FromIP, Size, MessageID, MessageTraceID 
}


$messages=Check_Message -sender "sarah.kitchen@vetpartners.com.au" -hour 10


$messages | Out-GridView

#$messages=Get-MessageTrace -SenderAddress no-reply@dropboxmail.com  -StartDate (get-date).AddDays(-10) -EndDate (get-date)| Where-Object { $_.status -eq 'delivered'} 
<#
$i=0
$count=$messages | measure | select -ExpandProperty count

foreach($subject in $subjects){
      
    #Write-Progress -activity "Scanning User $user . . ." -status "Scanned: $i of $count" -percentComplete (($i / $count)  * 100)
    get-mailbox "anneke.vandyk@bexleyvet.com.au" | Search-Mailbox -SearchQuery "subject:$subject received:18-Nov-2019..19-Nov-2019" -DeleteContent -force 

}


#>