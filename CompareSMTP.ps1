Import-Module MSOnline
$msolCred = Get-Credential
Connect-MsolService –Credential $msolCred

#$allmailboxes = Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName,@{Name=”EmailAddresses”;Expression={$_.EmailAddresses |Where-Object {$_ -like “smtp:*”}}} | Sort 
$allmailusers = Get-Mailuser -ResultSize Unlimited | Select-Object DisplayName,@{Name=”EmailAddresses”;Expression={$_.EmailAddresses |Where-Object {$_ -like “smtp:*”}}} | Sort 

$users = @("AWINYA957@GMAIL.COM")

foreach ($user in $users){
    foreach ($line in $allmailboxes){
    $test="smtp:$user"
    $email=$line.EmailAddresses
    $test
    If ($email -contains $test ) {
        Write-Host "$user exist " -foregroundcolor "green"
    } else {
        #Write-Host "$user not found" -foregroundcolor "red"
    }}
    }
