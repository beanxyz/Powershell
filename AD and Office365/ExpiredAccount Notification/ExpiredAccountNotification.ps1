#author: Yuan Li
#date: 07-Nov-2016

$date = Get-Date                       
         
      
$body=Get-ADUser -Filter {(AccountExpirationDate -lt $date) -and (Enabled -eq $true )} -Properties * | select Name, Distinguishedname, AccountExpirationDate | sort accountExpirationDate



$from = "ddbhelpdesk@aus.ddb.com"
$to = @("yuan.li@syd.ddb.com")

$smtp = "smtp.office365.com" 
$sub = "Expired User list" 

$secpasswd = ConvertTo-SecureString "Pass2014" -AsPlainText -Force 
$mycreds = New-Object System.Management.Automation.PSCredential ($from, $secpasswd)

#Send-MailMessage -To $to -From $from -cc $cc -Subject $sub -Body $body -Credential $mycreds -SmtpServer $smtp -DeliveryNotificationOption Never -BodyAsHtml -UseSsl -port 587 -Attachments $attach


$a = "<style>"
$a = $a + "BODY{background-color:Lavender ;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:PaleGoldenrod}"
$a = $a + "</style>"

#import-csv C:\scripts\users.csv | ConvertTo-Html -Body "<H1> User List </H1>" -Head $a | out-file C:\temp\tt.html

$htmlbody=$body| ConvertTo-Html -Body "<H1> User Expired List (Exclude Disabled Account) </H1>" -CssUri C:\tmp\table.css


Send-MailMessage -To $to -From $from -Subject $sub -Body ($htmlbody|Out-String) -Credential $mycreds -SmtpServer $smtp -DeliveryNotificationOption Never -BodyAsHtml -UseSsl -port 587 