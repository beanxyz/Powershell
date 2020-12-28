Search-MailboxAuditLog -Identity "hr@vetpartners.com.au" -ShowDetails
Set-Mailbox -Identity "hr@vetpartners.com.au" -AuditEnabled $true
Set-Mailbox "hr@vetpartners.com.au" -AuditOwner "HardDelete,SoftDelete,MoveToDeletedItems"
Get-Mailbox "hr@vetpartners.com.au" | FL Audit*

Get-MessageTrace  -SenderAddress "hr@vetpartners.com.au" -MessageId "MEXPR01MB08228749512C0003A0705959EFDE0@MEXPR01MB0822.ausprd01.prod.outlook.com"

Get-MessageTrace  -SenderAddress "hr@vetpartners.com.au" -StartDate 3/9/2018 -EndDate 3/10/2018 | sort received | where {$_.subject -like "New Contract James Wright"} | select -First 1 | Get-MessageTraceDetail | 
$today = Get-Date
$today4 = (Get-Date).addhours(-4)

Get-MessageTrace -SenderAddress "geoff.rose@vet.partners" -startdate $today4 -EndDate $today -RecipientAddress cheryl.loredo@vet.partners | Get-MessageTraceDetail


Get-MessageTraceDetail -SenderAddress "hr@vetpartners.com.au" -MessageTraceId "3222fd17-5b79-4e45-e3e3-08d585769f6b" -RecipientAddress "lauren.border@vetpartners.com.au" | select *


Get-MessageTrace -MessageId "MEXPR01MB08228749512C0003A0705959EFDE0@MEXPR01MB0822.ausprd01.prod.outlook.com" | Get-MessageTraceDetail