#connect to office365

$password = "Vets5000" | ConvertTo-SecureString -asPlainText -Force
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


$all=Import-Excel C:\temp\username.xlsx


foreach($one in $all){

    if($one.oldname -ne $null){
    $oldmsolupn=$one.oldname.Trim()
    $newmsolupn=$one.newname.Trim()
    
    
   Get-MsolUser -UserPrincipalName $oldmsolupn -ErrorAction SilentlyContinue

    
    if ($? -eq $false){
        #write-host $newmsolupn -ForegroundColor 
        
        "Update $newmsolupn to $oldmsolupn"
        Set-MsolUserPrincipalName -UserPrincipalName $newmsolupn -NewUserPrincipalName $oldmsolupn 

    }


    }


     #Get-MsolUser -UserPrincipalName $newmsolupn
    #$newmsolupn
    #Set-MsolUserPrincipalName -UserPrincipalName $newmsolupn -NewUserPrincipalName $oldmsolupn 
    #Get-MsolUser -UserPrincipalName $newmsolupn | Set-MsolUserPrincipalName -NewUserPrincipalName $oldmsolupn
}







#Get-PSSession | Remove-PSSession