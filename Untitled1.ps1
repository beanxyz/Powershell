
#设置搜索的时间段和发件人
 
$dateEnd = get-date 
$dateStart = $dateEnd.AddDays(-2)
$recipient="andrew.little@aus.ddb.com"
 
#自定义时间，转换时区
 
Get-MessageTrace -StartDate $dateStart -EndDate $dateEnd -RecipientAddress $recipient|
Select-Object @{name='time';e={[System.TimeZone]::CurrentTimeZone.ToLocalTime($_.received)}}, SenderAddress, RecipientAddress, Subject, Status, ToIP, FromIP, Size, MessageID, MessageTraceID | 
Out-GridView
