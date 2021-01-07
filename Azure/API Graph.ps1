$clientId = "8d4538e6-b1a5-4c05-b449-54d62fb18413"
$tenantName = "vetpartners.com.au"
$clientSecret = ".2S_z50qp.BVff~~5J_9_cxM1e1TRXrJ94"
$resource = "https://graph.microsoft.com/"
$username='xyli@vet.partners'
$password = '@Goat20121xx2' 
       

$ReqTokenBody = @{
    Grant_Type    = "Password"
    client_Id     = $clientID
    Client_Secret = $clientSecret
    Username      = $Username
    Password      = $Password
    Scope         = "https://graph.microsoft.com/.default"
} 
 
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody




$data=(Invoke-RestMethod -uri "https://graph.microsoft.com/v1.0/security/alerts" -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Method Get) 
$all=$data.value | Where-Object {$_.severity -like '*medium*' -or $_.severity -like "*high"} 

$ret=@()

foreach($one in $all){

$obj=$one.userStates 
$category=$one.category
$Severity=$one.severity
$title=$one.title


$obj | Add-Member -NotePropertyName Category -NotePropertyValue $category
$obj | Add-Member -NotePropertyName Severity -NotePropertyValue $Severity
$obj | Add-Member -NotePropertyName Title -NotePropertyValue $title

$ret+=$obj
}

$ret = $ret | Where-Object {$_.domainname -ne $null}
$day=(get-date).AddDays(-5)

$style=@"
<style>
body {
    color:#333333;
    font-family:Calibri,Tahoma;
    font-size: 10pt;
}
h1 {
    text-align:center;
}
h2 {
    border-top:1px solid #666666;
}
th {
    font-weight:bold;
    color:#eeeeee;
    background-color:#333333;
    cursor:pointer;
}
.odd  { background-color:#ffffff; }
.even { background-color:#dddddd; }
.paginate_enabled_next, .paginate_enabled_previous {
    cursor:pointer; 
    border:1px solid #222222; 
    background-color:#dddddd; 
    padding:2px; 
    margin:4px;
    border-radius:2px;
}
.paginate_disabled_previous, .paginate_disabled_next {
    color:#666666; 
    cursor:pointer;
    background-color:#dddddd; 
    padding:2px; 
    margin:4px;
    border-radius:2px;
}
.dataTables_info { margin-bottom:4px; }
.sectionheader { cursor:pointer; }
.sectionheader:hover { color:red; }
.grid { width:100% }
.red {
    color:red;
    font-weight:bold;
} 
.green{
    color:green;
    font-weight:bold;
}
</style>

"@

$from = "xyli@vet.partners"
$to = "yuan.li@vet.partners"
$smtp = "smtp.office365.com" 
$sub = "Security Alerts Lists" 
$password = Get-Content "C:\temp\password.txt" | ConvertTo-SecureString 
$mycreds = New-Object System.Management.Automation.PsCredential("xyli@vet.partners",$password)

$htmlbody=$ret| where-object{[datetime]$_.LogonDatetime -gt $day}|select @{n='AccountName';e={$_.accountName}}, @{n='DomainName';e={$_.domainname}},@{n='LogonDateTime';e={[datetime]($_.logonDatetime)}}, @{n='LogonIP';e={$_.logonIP}}, @{n='LogonLocation';e={$_.logonlocation}}, @{n='UserPrincipalName';e={$_.userPrincipalName}}, Category, Severity | sort Severity| ConvertTo-Html -Body "<H1> Important Security Alerts in the past 5 days </H1>" -Head $style

Send-MailMessage -To $to -From $from -Subject $sub -Body ($htmlbody|Out-String) -Credential $mycreds -SmtpServer $smtp -DeliveryNotificationOption Never -BodyAsHtml -UseSsl -port 587