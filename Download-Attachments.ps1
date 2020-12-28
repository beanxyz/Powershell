#Author: Geoff Rose
#Description: This script processes invoices sent to invpro@vetpartners.com.au. It downloads the attachments and then splits each page into its own file. It then 
#Date: 22 March 2017

. C:\Scripts\Export-O365Attachments.ps1
. C:\Scripts\Function-Write-Log.ps1
$date = Get-Date -Format yyyyddMM
$pdfpath = "c:\pdfs\"
$to = "email@email.com"
$from = "email@email.com"

#Log File
$logfile = "C:\PDFs\Log\$date.log"

#Credentials
#$secpasswd = ConvertTo-SecureString “Vetp5000” -AsPlainText -Force
$secpasswd = "0" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential (“email@email.com”, $secpasswd)

#Connects to Office 365 for account
Connect-OSCEXOWebService -Credential $credential

#Create a temp virtual folder with the emails we require
Write-Log -Message 'Downloading Attachments' -Path $logfile
New-OSCEXOSearchFolder  -WellKnownFolderName Inbox | Export-OSCEXOEmailAttachment -Path C:\PDFs


#Move emails from inbox to processed folders in Office 365
Write-Log -Message 'Moving emails to processed folder' -Path $logfile
Search-OSCEXOEmailMessage -WellKnownFolderName Inbox | Move-OSCEXOEmailMessage -DestinationFolderDisplayName "Processed"

$pdffiles = Get-ChildItem $pdfpath*.pdf
cd $pdfpath

foreach ($file in $pdffiles) {
    Write-Log -Message "Splitting '$file'" -Path $logfile
    $newname = $file.name.TrimEnd(".pdf")
    pdftk $file.Name burst output $newname-%02d.pdf
    Write-Log -Message "Moving '$file' to processed" -Path $logfile
    mv $file.Name $pdfpath\Processed -Force
}
Remove-Item $pdfpath\doc_data.txt

$splitpdfs = Get-ChildItem $pdfpath\*.pdf
$totalpdfs = $splitpdfs.count
$i=1

    foreach ($splitpdf in $splitpdfs) 
          {
           Write-Host $i
           if ($i -eq 30)
                {
                 Write-Log -Message "Reached 30 emails, need to sleep for 60 secs" -Path $logfile
                 start-sleep 60
                 $i=0
                 Write-Log -Message "Sending '$splitpdf' item '$i' of '$totalpdfs'" -Path $logfile
                 Send-MailMessage -Attachments $splitpdf.name -Subject "Invoice" -Credential $credential -SmtpServer smtp.office365.com -From $from -To $to -UseSsl -Port 587
                 Remove-Item $splitpdf.name
                 $i++
                 }
            Else {
                  Write-Log -Message "Sending '$splitpdf' item '$i' of '$totalpdfs'" -Path $logfile
                  Send-MailMessage -Attachments $splitpdf.name -Subject "Invoice" -Credential $credential -SmtpServer smtp.office365.com -From $from -To $to -UseSsl -Port 587
                  Write-Log -Message "Deleting '$splitpdf'" -Path $logfile
                  Remove-Item $splitpdf.name
                  $i++
                  #Start-Sleep 30
                 }
            }
