
function Get-PrimarySMTP(){

    [CmdletBinding()]
    
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $users
    )

$pp=$null
$pp=@{'name'=$null;'primarysmtp'=$null}
$obj=New-Object -TypeName psobject -Property $pp
 
$result=@()
foreach($user in $users){
$info=get-aduser -Filter {name -eq $user} -Properties proxyaddresses
$primarySMTPAddress = ""
foreach ($address in $info.proxyAddresses)
{
    if (($address.Length -gt 5) -and ($address.SubString(0,5) -ceq 'SMTP:') )
    {
        $primarySMTPAddress = $address.SubString(5)
        
        break
    }

}
$objtemp=$obj | select *
$objtemp.name=$info.Name
$objtemp.primarysmtp=$primarySMTPAddress
$result+=$objtemp
}
$result 
}


get-aduser -Filter * -SearchBase "ou=sydney,dc=omnicom,dc=com,dc=au" -Properties name,mobile,title,ipphone, canonicalname,company,office |
?{$_.distinguishedname -notlike '*Sydney Non-Replication*'}| 
select Name, Title, @{n="PrimarySMTP";e={(Get-PrimarySMTP -users $_.name).primarysmtp}}, Mobile,@{name="Extension";expression={$_.ipphone}},@{name="OU";expression={$temp=($_.canonicalname -split '/');$temp[$temp.count-2]}}, company, office | sort name | Export-Csv c:\scripts\users.csv -NoTypeInformation




$from = "ddbhelpdesk@aus.ddb.com"
$to = "nik.kastrounis@aus.ddb.com" 
$cc="yuan.li@syd.ddb.com"
$smtp = "smtp.office365.com" 
$sub = "User list" 
$body = "Attached is the latest Sydney users list"
$attach="C:\scripts\users.csv"

$secpasswd = ConvertTo-SecureString "Pass2014" -AsPlainText -Force 
$mycreds = New-Object System.Management.Automation.PSCredential ($from, $secpasswd)

#Send-MailMessage -To $to -From $from -cc $cc -Subject $sub -Body $body -Credential $mycreds -SmtpServer $smtp -DeliveryNotificationOption Never -BodyAsHtml -UseSsl -port 587 -Attachments $attach

break;

$a = "<style>"
$a = $a + "BODY{background-color:Lavender ;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:PaleGoldenrod}"
$a = $a + "</style>"

import-csv C:\scripts\users.csv | ConvertTo-Html -Body "<H1> User List </H1>" -Head $a | out-file C:\temp\tt.html


invoke-item C:\temp\tt.html

#Send-MailMessage -To yuan.li@live.com -From $from -cc $cc -Subject $sub -Body $body -Credential $mycreds -SmtpServer $smtp -DeliveryNotificationOption Never -BodyAsHtml -UseSsl -port 587 -Attachments $attach
$body=import-csv C:\scripts\users.csv | ConvertTo-Html -body "<h1> User list</h1>" -head $a |Out-String

Send-mailMessage -to "yuan.li@syd.ddb.com" -From $from -Subject "User List" -BodyAsHtml -Body $body -Credential $mycreds -SmtpServer $smtp -DeliveryNotificationOption Never  -UseSsl -port 587