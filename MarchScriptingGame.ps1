
function Get-Diacritic
{
    [CmdletBinding()]
    
    Param
    (
        # Param1 help description
        [Parameter(
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Path=".\"
    )

    Begin
    {
    }
    Process
    {
    

        Get-ChildItem -Recurse -Path $path| 
        Where-Object {$_.name -match "[\u00C0-\u00FF]"} | 
        select Name, directory, creationtime, lastwritetime,
        @{
        n="Size";
        e={
        if($_.length -lt 1000){"{0:n1}" -f $_.length.tostring()+" Byte"}
        elseif($_.length -lt 1000000){("{0:n1}" -f ($_.length/1kb)).ToString()+" KB" }
        else{("{0:n1}" -f ($_.length/1mb)).ToString() + " MB"} 

        }
        } | tee -Variable file 

        if($file -eq $null){Write-Warning "No file name dectected with Latin Character"}
        else{
        $name=(get-date -Format yyyy.M.d)+"FileNamesWithDiacritics.csv"
        
        $file | export-csv c:\temp\$name -Encoding Unicode}

        $from = "ddbhelpdesk@aus.ddb.com"
        $to = "yuan.li@syd.ddb.com" 

        $smtp = "smtp.office365.com" 
        $sub = "User list" 
        #$body = "Attached is the file list"
        $attach="c:\temp\"+$name

        $secpasswd = ConvertTo-SecureString "Pass2014" -AsPlainText -Force 
        $mycreds = New-Object System.Management.Automation.PSCredential ($from, $secpasswd)


        $Body = $file | ConvertTo-Html -Head "Scanning Result" -As Table | Out-String



        Send-MailMessage -To $to -From $from -Subject $sub -Body $body -Credential $mycreds -SmtpServer $smtp -DeliveryNotificationOption Never -BodyAsHtml -UseSsl -port 587 -Attachments $attach






    }
    End
    {
    }
}

break;

mofcomp C:\Windows\System32\wbem\SchedProv.mof

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'c:\temp\Get-Diacritic.ps1'

$trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 2 -DaysOfWeek Saturday -At 3am

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "LatinName" -Description "Weekly FileName Scanning"


Start-ScheduledTask -TaskName "LatinName"