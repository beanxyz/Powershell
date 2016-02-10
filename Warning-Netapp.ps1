

function sendmail(){
Write-host "Sending Emails to the Administrtor"

$from = "ddbhelpdesk@aus.ddb.com"
$to = "yuan.li@syd.ddb.com" 
$smtp = "smtp.office365.com" 
$sub = "Volume over 90%" 
$body="This is the warning message for volume usage over 90%"
$secpasswd = ConvertTo-SecureString "Pass2014" -AsPlainText -Force 
$mycreds = New-Object System.Management.Automation.PSCredential ($from, $secpasswd)


if ((get-content $path).length -gt 0){


Send-MailMessage -To $to -From $from -Subject $sub -Body $body -Credential $mycreds -SmtpServer $smtp -DeliveryNotificationOption Never -BodyAsHtml -UseSsl -port 587 -Attachments $path
}
}


$syd01=Connect-NaController syd01
$syd02=Connect-NaController syd02
$filers=$syd01,$syd02
$logtime=Get-Date -Format "MM-dd-yyyy_hh-mm-ss"

$path="C:\temp\logs\$logtime.txt"


New-Item -Path $path -ItemType file -Force 


Write-Verbose "Createing Reports"

foreach($filer in $filers){

Connect-NaController $filer 
$a=Get-NaVol | Where-Object{$_.used -ge 90} 


foreach($b in $a){



$b | ft >> $path
$b| Get-NaSnapshot  |sort created |ft >> $path
$b | ft
#$sw=read-Host "Please confirm if you want to remove snapshots older than 4 months (Yes/No)"
#switch ($sw){
#"yes" {Write-Warning "Following snapshots will be deleted";$b| get-nasnapshot | Where-Object{$_.created -lt (date).AddDays(-120)} |ft}
#"No" {sendmail}


#}
}

}


sendmail