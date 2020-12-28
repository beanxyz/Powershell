$ip = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
if ($ip -notlike "123*") { 
. 'C:\Program Files\Amazon\AWSCLI\aws.exe' s3 sync 'f:\OPMs 7z' s3://ryde/backup}
else {
    $userid='frank@vet.partners'
    $pass = "01000000d08c9ddf0115d1118c7a00c04fc297eb010000009c661e80efeea34895f95588b76457c40000000002000000000003660000c000000010000000f0640e460edac76eb3d8932c199e57730000000004800000a0000000100000009b4ef81e792fa95b69799ef655ddfd5a18000000497a47bad81874703f7e22b5bd1fb2d882ec2069656bdd3a140000003bc8e1d189a1b45d61688873ca877f61cb839178" | ConvertTo-SecureString
    $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userid, $pass
    Send-MailMessage `
        -To 'backup@vetpartners.com.au' `
        -Subject 'Offsite Backup Not Run at Ryde - 4G In Use' `
        -Body 'The AWS S3 Backup did not run because 4G is in use' `
        -UseSsl `
        -Port 587 `
        -SmtpServer 'smtp.office365.com' `
        -From $userid `
        -Credential $creds
}

    "Vetp5000" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString