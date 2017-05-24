$day=get-date "03/10/2017"

#get user lists who were created before 10 March
$user1=Get-ADUser -filter {whencreated -lt $day} -SearchBase “ou=melbourne,dc=omnicom,dc=com,dc=au” -Properties *| select name, samaccountname, @{n='lastlogontime';e={[datetime]::FromFileTime($_.lastlogon)}},mail, company,whencreated, enabled, whenchanged,@{n='passwordexpiredate';e={[datetime]$_.passwordlastset.adddays(90)}},passwordneverexpires



#users who were created before 10 March and disabled after 10 march
$user2=$user1 | Where-Object{($_.enabled -eq $false ) -and ($_.whenchanged -gt $day)}

#users who were created before 10 March, and Not disabled before 10 March

$user3=$user1 | Where-Object{ !(($_.enabled -eq $false ) -and ($_.whenchanged -lt $day))}

$user3 | Export-Csv C:\temp\MelMarchUsers.csv -NoTypeInformation

