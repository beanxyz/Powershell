
$path='C:\temp\Parramatta - Email Choice RfE.xlsx'

#$worksheetnames= Get-ExcelSheetInfo -Path $path| select -ExpandProperty name
function Convert-UTCtoLocal

{
param(
[parameter(Mandatory=$true)]
[String] $UTCTime
)

$strCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName
$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
$LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
}



$names=Import-Excel $path -WorksheetName 'Parramatta Veterinary Hospital'

$result=foreach($name in $names){
            
        if($name.Preference -like "*Mail User*"){
                
            $email=$name.Companyemail
            #get-mailuser -Filter "emailaddresses -like '*$email*' " | select name, @{n='PersonalEmail';e={$name.Personalemail}}, @{n='CompanyEmail';e={$name.Companyemail}}, @{n='Clinic';e={$name.Clinic}}, whenchanged , ResetPasswordOnNextLogon
            Get-MsolUser -UserPrincipalName $email | select displayname,  @{n='LocalPasswordChangedtimestamp';e={$_.LastPasswordChangeTimestamp.tolocaltime()}}
                
        }
    
    
}


$result | sort whenchanged -Descending | Export-Excel 'C:\temp\ParramattaReport.xlsx'