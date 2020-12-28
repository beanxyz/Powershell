[string]$doy = (get-date).DayOfYear

$upload = Get-childitem "F:\SQL Backup" | select -Last 1
$filepathname = Join-Path "F:\SQL Backup" $upload.Name
Get-ChildItem 'F:\RxWorks\Practice Information' | compress-archive -DestinationPath C:\Backups\$doy`practice.zip -Force

#Upload to S3
Write-S3Object -BucketName "corioandlara" -Region ap-southeast-2 -File "C:\Backups\$doy`practice.zip" -Key "$doy`practice.zip" -AccessKey "AKIAISFROE5GIQLDRTHQ" -SecretKey "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"

#Remove Old Files
Get-ChildItem 'F:\SQL Backup' | select -First 1 | Remove-Item
Get-ChildItem C:\backups | select -first 1 | remove-item

Get-S3Object -BucketName "corioandlara" -Region ap-southeast-2 -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" | Where-Object {$_.Key -like "*practice.zip"} | select -first 1 | Remove-S3Object -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" -Confirm:$false
Get-S3Object -BucketName "corioandlara" -Region ap-southeast-2 -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" | Where-Object {$_.Key -like "RxMain*.zip"} | select -first 1 | Remove-S3Object -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" -Confirm:$false



get-ec2instance

write-s3


#cleanup S3 files
$count1 = (Get-S3Object -BucketName "chatswood" -key "\cstone" -Region ap-southeast-2 -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" | Where-Object {$_.Key -like "*cstone.zip"}).count 
$count2 = (Get-S3Object -BucketName "chatswood" -key "\cstonelog" -Region ap-southeast-2 -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" | Where-Object {$_.Key -like "*cstonelog.zip"}).count 
if ($count1 -gt 35) {Get-S3Object -BucketName "chatswood" -key "\cstone" -Region ap-southeast-2 -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" | Where-Object {$_.Key -like "*cstone.zip"} | select -first 1 | Remove-S3Object -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" -Confirm:$false}
if ($count2 -gt 35) {Get-S3Object -BucketName "chatswood" -key "\cstonelog" -Region ap-southeast-2 -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" | Where-Object {$_.Key -like "*cstonelog.zip"} | select -first 1 | Remove-S3Object -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" -Confirm:$false}

#Cleanup old files
Get-ChildItem D:\RxBackup\Gladesville | where-Object {$_.Name -like 'RxMain*'} | select -First 1 | Remove-Item
Get-ChildItem D:\RxBackup\Parramatta | where-Object {$_.Name -like 'RxParra*'} | select -First 1 | Remove-Item

#cleanup S3 RX files
$count1 = (Get-S3Object -BucketName "nsvh" -key "\dbbackup\" -Region ap-southeast-2 -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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").count 
if ($count1 -gt 35) {Get-S3Object -BucketName "chatswood" -key "\cstone" -Region ap-southeast-2 -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" | select -first 1 | Remove-S3Object -AccessKey "AKIAIMCSQD3IUHE2CHQA" -SecretKey "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" -Confirm:$false}
