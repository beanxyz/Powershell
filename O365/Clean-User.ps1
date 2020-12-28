#Demo 

#Connect to Office365

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

#Import Old user list

<#

    For users inactive for 300 days and mailbox size is over 500M

#>

$users= Import-Excel 'C:\temp\Terminated Users\Convert to shared mailbox.xlsx'



#$user=$users[0]
foreach($user in $users){
    $UPN=$user.upn
    $upn
    $userinfo=Get-ADUser -Filter {userprincipalname -eq $upn} -Properties *

    #Remove all groups 

    $groups=$userinfo.MemberOf
    foreach($group in $groups){
        Remove-ADGroupMember -Identity $group -Members $userinfo.DistinguishedName -Confirm:$false

    }

    #Sync to Office365


   


    

    #Change Mailbox to Shared

    Set-Mailbox $UPN -Type shared

    #Remove all licenses

    (get-MsolUser -UserPrincipalName $upn).licenses.AccountSkuId |
    foreach{
        Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $_
    }


}
 Start-ADSyncSyncCycle -PolicyType Delta

foreach($user in $users){
#Disable AD account
    Disable-ADAccount -Identity $userinfo.DistinguishedName


}


$all=Import-Excel 'C:\temp\Terminated Users\Convert to shared mailbox.xlsx'

foreach($user in $all){

    
    $Mailbox=get-Mailbox $user.UPN
    $DN=$mailbox.DistinguishedName
    $Filter = "Members -like ""$DN"""

    write-host $user.DisplayName -ForegroundColor Cyan
    $groups=Get-DistributionGroup -ResultSize Unlimited -Filter $Filter 

   # foreach($group in $groups){
    
   #     Remove-DistributionGroupMember -Identity $group.Name -Member $DN -Confirm:$false
   # }


}



$all2=Import-Excel 'C:\temp\Terminated Users\To Be deleted.xlsx'


foreach( $one in $all2){

    $upn=$one.UPN
    get-aduser -filter { userprincipalname -eq $upn} | Remove-ADUser -Confirm:$false


}



