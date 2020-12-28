
$password = "8qtVoKID" | ConvertTo-SecureString -asPlainText -Force
$username = "support@vetpartners.com.au" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password)


$session=Get-PSSession

if($session.ComputerName -like "outlook.office365*"){
    Write-Host "Outlook.Office365.com session is connected" -ForegroundColor Cyan
}
else{
    #MFA Authentication#
    #Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch "_none_"}|select -First 1)
    #$EXOSession = New-ExoPSSession
    #Import-PSSession $EXOSession

    #Normal login

    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
    Import-PSSession $Session
    Connect-MsolService

}


$all=Get-DistributionGroup -Filter {displayname -like "*nurses*"}| where-object {$_.AcceptMessagesOnlyFromDLMembers -ne $null} |select displayname, AcceptMessagesOnlyFromDLMembers 

foreach($one in $all){
$id=$one.displayname


#$id='Adelaide Vet - Nurses'
Set-distributiongroup -Identity $id -AcceptMessagesOnlyFromSendersOrMembers @{add="send all"}
Set-distributiongroup -Identity $id -AcceptMessagesOnlyFromSendersOrMembers @{add="send-all2"} 

}