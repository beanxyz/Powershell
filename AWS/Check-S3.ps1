$sites = get-content "c:\scripts\sites.txt"
$cssites = get-content "c:\scripts\cssites.txt"
$date = get-date
$summary = @()
#begin RX sites
    Foreach ($site in $sites) {
        $sitelast = get-S3Object -BucketName "$site" -key "dbbackup" -Region ap-southeast-2 -AccessKey "AKIAISFROE5GIQLDRTHQ" -SecretKey "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" | sort lastmodified | select -Last 1
        $date = get-date
        $lastupload = $date - $sitelast.LastModified
        if ($lastupload.Hours -gt 24) 
        {write-verbose -Message "Backup Has been missed!" -Verbose
        $backupstatus = $false}
        else {$backupstatus = $true}
        $summary += New-Object -Type PSObject -Prop @{'Name' = $site;'Status' = $backupstatus}
     }

#Begin CS sites
Foreach ($cssite in $cssites) {
        $sitelast = get-S3Object -BucketName "$cssite" -Key "\cstone\" -Region ap-southeast-2 -AccessKey "AKIAISFROE5GIQLDRTHQ" -SecretKey "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" | sort lastmodified | select -Last 1
        $lastupload = $date - $sitelast.LastModified
        if ($lastupload.Hours -gt 24) 
        {write-verbose -Message "Backup Has been missed!" -Verbose
        $backupstatus = $false}
        else {$backupstatus = $true
        write-verbose -Message "$cssite Backup Has NOT been missed!" -Verbose}
        $summary += New-Object -Type PSObject -Prop @{'Name' = $cssite;'Status' = $backupstatus}
     }

#Begin VL2 Sites
     $erinaheights = get-S3Object -BucketName "erinaheights" -key "\VL2Backup\" -Region ap-southeast-2 -AccessKey "AKIAISFROE5GIQLDRTHQ" -SecretKey "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" | sort lastmodified | select -Last 1
      $date = get-date
        $lastupload = $date - $erinaheights.LastModified
        if ($lastupload.Hours -gt 24) 
        {write-verbose -Message "Backup Has been missed!" -Verbose
        $backupstatus = $false}
        else {$backupstatus = $true}
        $summary += New-Object -Type PSObject -Prop @{'Name' = 'Erina Heights';'Status' = $backupstatus}

#total vets
     $totalvets = get-S3Object -BucketName "totalvets" -key "\SQLBackup\" -Region ap-southeast-2 -AccessKey "AKIAISFROE5GIQLDRTHQ" -SecretKey "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" | sort lastmodified | select -Last 1
      $date = get-date
        $lastupload = $date - $totalvets.LastModified
        if ($lastupload.Hours -gt 24) 
        {write-verbose -Message "Backup Has been missed!" -Verbose
        $backupstatus = $false}
        else {$backupstatus = $true}
        $summary += New-Object -Type PSObject -Prop @{'Name' = 'TotalVets';'Status' = $backupstatus}



        $objects | ConvertTo-HTML -As Table -Fragment | Out-String