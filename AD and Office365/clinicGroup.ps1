

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

$list="corio","lara","east bentleigh","fawkner","kialla","shepparton","south eastern","southpaws","montrose","new norfolk","ferntree gully","flemington","forest hill","gisborne","korumburra","koo wee rup","hume","melrose"


foreach($item in $list){



$groups=Get-DistributionGroup | Where-Object {$_.displayname -like "*$item*"}
foreach($group in $groups){

    write-host $group.name -ForegroundColor Cyan 

    Get-DistributionGroupMember $group.name | select name , emailaddresses | Out-String


    $group.name | Out-File c:\temp\groupmember.txt -Append

    Get-DistributionGroupMember $group.name | select name , emailaddresses | Out-File C:\temp\groupmember.txt -Append

  
}

}