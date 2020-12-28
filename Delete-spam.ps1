
# Login to Office365 online 


$sender='twenty3events@live.com.au'
$password = "@nn23sdk6L6P2R4G5" | ConvertTo-SecureString -asPlainText -Force
$username = "xyli@vet.partners"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)


$session=Get-PSSession

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
Import-PSSession $Session

#Track Messages from the spam sender 

$messages=Get-MessageTrace -SenderAddress $sender -StartDate (get-date).AddDays(-1) -EndDate (get-date)| Where-Object { $_.status -eq 'delivered'} | Where-Object {$_.subject -like "*Your Village*"}


#Search by Subject Name
<#
$Messages = $null  
$Page = 1  
do  
{  
    Write-Host "Collecting Message Tracking - Page $Page..."  
    $CurrMessages = Get-MessageTrace -PageSize 5000 -Page $Page -StartDate (get-date).AddDays(-1) -EndDate (get-date)
    $Page++  
    $Messages += $CurrMessages  
}  
until ($CurrMessages -eq $null) 


$messages | Where-Object {$_.subject -like "*Awareness_Reg*"}


#>

$i=0
$count=$messages | measure | select -ExpandProperty count

foreach($one in $messages){
    

       
    $user=$one.'recipientaddress'
    $subject=$one.subject
    $i++
    Write-Progress -activity "Scanning User $user . . ." -status "Scanned: $i of $count" -percentComplete (($i / $count)  * 100)
    get-mailbox $user | Search-Mailbox -SearchQuery "subject:$subject received:22-Nov-2020..23-Nov-2020" -DeleteContent -force 

}




#Get-MessageTrace -SenderAddress no-reply@dropboxmail.com -StartDate (get-date).AddDays(-6) -EndDate (get-date) | Out-GridView