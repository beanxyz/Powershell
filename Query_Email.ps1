Write-Host "Check AD" -ForegroundColor Cyan

get-aduser -Filter { proxyaddresses -like "*megan.jones@aus.ddb.com*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*laura.mccarthy@syd.ddb.com*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*juliav@thisismango.com.au*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*interactive@ddb.com.au*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*feri.danes@syd.ddb.com*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*david.brown@ddb.com.au*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*cwilson@ddb.com.au*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*bryson.holt@syd.ddb.com*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*alfredo.aguanta@mel.ddb.com*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*amby.davies@syd.ddb.com*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*alex@tribalddb.com.au*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*aledbury@ddb.com.au*"} -Properties proxyaddresses
get-aduser -Filter { proxyaddresses -like "*acarver@ddb.com.au*"} -Properties proxyaddresses 
get-aduser -Filter { proxyaddresses -like "*halloran@anz.ddb.com*"} -Properties proxyaddresses 

write-host "Check O365" -ForegroundColor Cyan

$users=Get-Mailbox -Identity * 
$users| Where-Object {$_.EmailAddresses -like 'smtp:laura.mccarthy@syd.ddb.com'} | Format-List Identity, EmailAddresses
$users| Where-Object {$_.EmailAddresses -like 'smtp:juliav@thisismango.com.au'} | Format-List Identity, EmailAddresses
$users| Where-Object {$_.EmailAddresses -like 'smtp:interactive@ddb.com.au'} | Format-List Identity, EmailAddresses
$users| Where-Object {$_.EmailAddresses -like 'smtp:feri.danes@syd.ddb.com'} | Format-List Identity, EmailAddresses

$users| Where-Object {$_.EmailAddresses -like 'smtp:david.brown@ddb.com.au'} | Format-List Identity, EmailAddresses
$users| Where-Object {$_.EmailAddresses -like 'smtp:cwilson@ddb.com.au'} | Format-List Identity, EmailAddresses
$users| Where-Object {$_.EmailAddresses -like 'smtp:bryson.holt@syd.ddb.com'} | Format-List Identity, EmailAddresses

$users| Where-Object {$_.EmailAddresses -like 'smtp:alfredo.aguanta@mel.ddb.com'} | Format-List Identity, EmailAddresses
$users| Where-Object {$_.EmailAddresses -like 'smtp:amby.davies@syd.ddb.com'} | Format-List Identity, EmailAddresses
$users| Where-Object {$_.EmailAddresses -like 'smtp:alex@tribalddb.com.au'} | Format-List Identity, EmailAddresses
$users| Where-Object {$_.EmailAddresses -like 'smtp:aledbury@ddb.com.au'} | Format-List Identity, EmailAddresses
$users| Where-Object {$_.EmailAddresses -like 'smtp:acarver@ddb.com.au'} | Format-List Identity, EmailAddresses
$users| Where-Object {$_.EmailAddresses -like 'smtp:halloran@anz.ddb.com'} | Format-List Identity, EmailAddresses