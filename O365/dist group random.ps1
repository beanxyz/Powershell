$identity = "BarkesCorner-HD@barkesvet.co.nz"
$identities = Get-Content C:\scripts\groups99.txt
#remove spaces from file
$identities | Foreach {$_.TrimEnd()} | Set-Content c:\scripts\groups999.txt

$identities = Get-Content C:\scripts\timmacrae.txt
#process file
foreach ($identity in $identities) {
Set-DistributionGroup -Identity $identity -AcceptMessagesOnlyFromDLMembers "rd-nsw@vet.partners","Regional Operations Manager - NSW - 2",send-all@vet.partners,$identity
}

Set-DistributionGroup -Identity $identity -AcceptMessagesOnlyFrom brett.simpson@vetpartners.com.au,nicole.birrell@vetpartners.com.au -AcceptMessagesOnlyFromDLMembers send-all@vet.partners,$identity


Set-DistributionGroup -Identity $identity -AcceptMessagesOnlyFromDLMembers GeoffTest-HD@vet.partners 

Get-DistributionGroup -Identity $identity | select acceptmessagesonlyfrom,acceptmessagesonlyfromDLmembers
Get-DistributionGroup -Identity "GeoffTest - Hospital Director" | select acceptmessagesonlyfromDLmembers
Get-DistributionGroup -Identity $identity | select managedby

Get-DistributionGroup | Where-Object {$_.primarysmtpaddress -like "*-HD*"} | select primarysmtpaddress
Get-DistributionGroup | Where-Object {$_.primarysmtpaddress -like "*northshorevet.*"} | select primarysmtpaddress | sort primarysmtpaddress



foreach ($t2 in $t3){
#string]$t2 = $2 -replace '\s',''
$t2
}