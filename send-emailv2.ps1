$users=Import-Excel 'C:\temp\totalvets mailuser.xlsx'

$from='helpdesk@vetpartners.com.au'
$to='helpdesk@vetpartners.com.au'
#$bcc=issa.willoughby@eppingvet.com.au","masumi.ichikawa@eppingvet.com.au","Melissa.Baulman@eppingvet.com.au","rachel.franklin@eppingvet.com.au","Scott.Cumming@eppingvet.com.au","sonya.gonsalves@eppingvet.com.au","taryn.proellocks@eppingvet.com.au","Wen.Song@eppingvet.com.au","Kitty.Cheung@eppingvet.com.au","Cleo.Sevier@eppingvet.com.au","yuan.li@vet.partners"

#$users=Import-Excel $path
$smtp = "smtp.office365.com" 
$sub = '"Email Choice" program completed: please login to the Intranet page and change your password'
$attach="C:\temp\Self Service Password Reset after mail-user set up.docx"

$secpasswd = ConvertTo-SecureString "ad36fdace8d6e875f70fad79e6470f67A" -AsPlainText -Force 
$mycreds = New-Object System.Management.Automation.PSCredential ($from, $secpasswd)


foreach($one in $users){



$name=$one.name
$email=$one.companyemail

$body=@"
Dear $name,
 
As you may be aware, we are currently executing an "Email Choice Program", which will help with our communication and also enables all team members to have a single login method to multiple systems such as the intranet, IT Help Desk and the upcoming nest learning platform. 

One of the results of the email choice program is that your company email is now forwarded to your private email address (where you are reading this now).
 
We have worked closely with your practice manager and a new intranet account has been created for you with the following format: $email

To create the new account we also had to set a temporary password on this account, which needs to be changed at first logon.
 
Please go to our VetPartners Intranet site from https://intranet.vet.partners and change your password accordingly.

The initial password to use when logging on is Password1234@ and you will be asked to change it immediately at login.
 
The attached document and this link https://www.youtube.com/watch?v=jYMq4yb_ryw will help you in the reset process, but if required you can also contact the service desk on 1800 VETCOM (1800 838 266).
 
Kind Regards,

 

The VetPartners IT team
"@



$body



Send-mailMessage -to $from -From $from -Subject $sub -Bcc $email -Body $body -Attachments $attach -Credential $mycreds -SmtpServer $smtp -DeliveryNotificationOption Never  -UseSsl -port 587



}





#Send-mailMessage -to yuan.li@vet.partners -From $from -Subject $sub -Body $body -Attachments $attach -Credential $mycreds -SmtpServer $smtp -DeliveryNotificationOption Never  -UseSsl -port 587
