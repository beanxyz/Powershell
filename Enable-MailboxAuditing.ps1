#Create a secure string of the your password
#Read-Host -AsSecureString | ConvertFrom-SecureString > c:\temp\key.txt


#Check if O365 session is setup, if not, create a new one

$Sessions=Get-PSSession

if (($Sessions.ComputerName -eq "outlook.office365.com") -and ($Sessions.State -ne 'Broken')){

    write-host "Detect existing Office365 session, skip.." -ForegroundColor Cyan

}
else{
    
    $username = "yuan.li@aus.ddb.com"
    $secureStringPwd = gc C:\temp\key.txt | ConvertTo-SecureString
    $creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd

    $ExoSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $creds -Authentication Basic -AllowRedirection
    Import-PSSession $ExoSession
}



#Find Mailboxes that haven't enabled auditing

$users=get-mailbox -Filter {(AuditEnabled -eq $false) -and ( RecipientTypeDetails -eq "UserMailbox" `
            -or RecipientTypeDetails -eq "SharedMailbox" `
            -or RecipientTypeDetails -eq "RoomMailbox" `
            -or RecipientTypeDetails -eq "DiscoveryMailbox")} | select name, alias, auditenabled, auditlogagelimit, distinguishedname


foreach($user in $users){

    try{
        Set-Mailbox $user.distinguishedname -AuditEnabled $true -AuditLogAgeLimit 365 -AuditOwner Create,HardDelete,MailboxLogin,MoveToDeletedItems,SoftDelete,Update -ErrorAction Stop
       # Create a Windows Eventlog if needed
        $username=$user.name
        Write-Eventlog  -Logname 'Application' -Source 'Application' -EventID 666 -EntryType Information -Message "$username Maibox Auditing is enabled" 
        }
    catch{
        Write-Eventlog  -Logname 'Application' -Source 'Application' -EventID 666 -EntryType Error -Message "$user Mailbox Auditing is failed to enable" 
    }
  
}



#There are two ways to check the resut, Event Viewer or Email

#Check again if the status is changed 
$result=foreach($user in $users){
    get-mailbox $user.name | select name, alias, auditenabled, auditlogagelimit, distinguishedname
} 



#Send Email to the admin
$from = "yuan.li@aus.ddb.com"
$to = "yuan.li@syd.ddb.com"
$smtp = "smtp.office365.com" 
$sub = "Auditing list" 
$secureStringPwd = gc C:\temp\key.txt | ConvertTo-SecureString
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $from, $secureStringPwd
 
$date=get-date 
$htmlbody=$result| ConvertTo-Html -Body " <H1> $date Mailbox Auditing Enabled record </H1>" -CssUri C:\tmp\table.css 


Send-MailMessage -To $to -From $from -Subject $sub -Body ($htmlbody|Out-String) -Credential $creds -SmtpServer $smtp -DeliveryNotificationOption Never -BodyAsHtml -UseSsl -port 587 





#Check from Event Viewer
try{
    $eventcritea = @{logname='Application';id=666}
    $Events =get-winevent -FilterHashtable $eventcritea -ErrorAction Stop

    ForEach ($Event in $Events) {    
            
        $eventXML = [xml]$Event.ToXml()              
        $Event | Add-Member -MemberType NoteProperty -Force -Name  Information -Value $eventXML.Event.EventData.Data             
        $Event.Information         
    }            
}catch [system.Exception] {
    
    "Couldn't fine any mailbox auditing logs"
}
    
$events | select information, id, logname, timecreated| Out-GridView -Title Status

    

