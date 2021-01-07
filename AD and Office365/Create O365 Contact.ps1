 function Connect-Office365{


#$credential.Password | ConvertFrom-SecureString | set-content "c:\temp\password.txt"
    $session=Get-PSSession

    if( $session.ComputerName -eq 'outlook.office365.com' -and $session.State -eq 'opened'){

        Write-host 'PowerShell Exchange Online is connected'
    }
    else{


    #(get-credential).password | ConvertFrom-SecureString | set-content "C:\temp\password.txt"

        $password = Get-Content "C:\temp\password.txt" | ConvertTo-SecureString 
        $credential = New-Object System.Management.Automation.PsCredential("xyli@vet.partners",$password)
        Connect-ExchangeOnline -Credential $credential -ShowProgress $true
        Connect-MsolService -Credential $credential
        Connect-AzureAD -Credential $credential

    }

}
#Get-PSSession | Remove-PSSession

Connect-Office365
 
 
 $all=import-csv 'C:\temp\VW and AV support office staff.csv'

 foreach($one in $all){
 
 
 new-mailconta
 
 
 }