
function Connect-Office365{


#$credential.Password | ConvertFrom-SecureString | set-content "c:\temp\password.txt"
    $session=Get-PSSession

    if( $session.ComputerName -eq 'outlook.office365.com' -and $session.State -eq 'opened'){

        Write-host 'PowerShell Exchange Online is connected'
    }
    else{
        $password = Get-Content "C:\temp\password.txt" | ConvertTo-SecureString 
        $credential = New-Object System.Management.Automation.PsCredential("xyli@vet.partners",$password)
        Connect-ExchangeOnline -Credential $credential -ShowProgress $true
        Connect-MsolService -Credential $credential
        Connect-AzureAD -Credential $credential

    }

}


Connect-Office365
$all=Get-MailUser -ResultSize unlimited 

$all | Get-Member

#Connect-MsolService
#get-help Connect-MsolService -examples

$domainnames=(Get-MsolDomain).name
$result=@()

foreach($one in $all){
    
    $primary=$one.PrimarySmtpAddress

    $domain=$primary.split('@')[1]

    $email=$one.EmailAddresses

    $email

    foreach($add in $email){
    
        if ($add -clike '*smtp*'){
        
            $smtp=$add.split(':')[1]
            $domain2=$smtp.split('@')[1]
            #$domain2
        }
    
    }

    if($domainnames -notcontains $domain){

       if($domainnames -contains $domain2){

       #Get-MailUser $primary | Set-MailUser -PrimarySmtpAddress $smtp -WhatIf
    
        $temp=[pscustomobject]@{name=$one.Name;PrimarySMTP=$one.PrimarySmtpAddress;SmallSMTP=$smtp}
        $result+=$temp
        }
    }

}

$result 


#$result1=$result[1..500]

foreach($one in $result){
$primary=$one.PrimarySMTP
$smtp=$one.SmallSMTP
get-mailuser $primary | select name, emailaddresses
Get-MailUser $primary | Set-MailUser -PrimarySmtpAddres $smtp


}

