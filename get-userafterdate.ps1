$When = ((Get-Date).AddDays(-42)).Date


$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*northshorevet.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\nsvh.csv -Append -Force -NoTypeInformation
}


$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*ftgvet.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\ftg.csv -Append -Force -NoTypeInformation
}

$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*coriovet.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\corio.csv -Append -Force -NoTypeInformation
}

$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*bexleyvet.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\bexley.csv -Append -Force -NoTypeInformation
}

$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*vetfriends.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\chatswood.csv -Append -Force -NoTypeInformation
}


$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*eppingvet.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\epping.csv -Append -Force -NoTypeInformation
}

$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*glenhavenvet.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\glenhaven.csv -Append -Force -NoTypeInformation
}

$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*guildfordvet.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\guildford.csv -Append -Force -NoTypeInformation
}

$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*matravillevet.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\matraville.csv -Append -Force -NoTypeInformation
}

$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*parramattavet.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\parramatta.csv -Append -Force -NoTypeInformation
}

$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*riverbankvet.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\riverbank.csv -Append -Force -NoTypeInformation
}

$lists = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated,emailaddress | Where-Object {$_.userprincipalname -like "*rydevet.com.au"} | select name,emailaddress
foreach ($list in $lists) {
$table1 = [pscustomobject][ordered] @{
Name = $list.name
Email = $list.emailaddress
}
$table1 | Export-Csv C:\Users\xgrose\Documents\users\ryde.csv -Append -Force -NoTypeInformation
}