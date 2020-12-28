Set-AWSCredential -AccessKey AKIAVTZSLTQTVWDTOY77 -SecretKey 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 

Write-Host "Checking EC2 instance Tags status" -ForegroundColor Yellow

$all=Get-EC2Instance | select -expand instances


$return=$all | Where-Object {$_.tag.key -notcontains "Clinic"}

if($return -ne $null){
$username = "frank@vet.partners" 
$password = "Vetp5000" | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
$id=$return.InstanceId

Send-MailMessage -From frank@vet.partners -to yuan.li@vet.partners -SmtpServer smtp.office365.com -Port 587 -UseSsl -Subject "EC2 instance Tag" -body "$id" -Credential $credential
exit


}
# confirm EC2 instances were tagged

$result=@()
foreach($item in $all){

    $Name=$item.tag | Where-Object {$_.Key -eq 'Name'} | select -ExpandProperty value
    $clinic=$item.tag | Where-Object {$_.Key -eq 'clinic'} | select -ExpandProperty value
    $sg=$item.securitygroups.groupname
    $item | add-member -NotePropertyName Description -NotePropertyValue $name
    $item | add-member -NotePropertyName Clinic -NotePropertyValue $clinic
    $item | add-member -NotePropertyName sg -NotePropertyValue $sg

    $item = $item | select *
    $result+=$item

}

$result | select Description, InstanceId, InstanceType,privateIpaddress, Clinic,@{n='Status';e={$_.state.name}},sg | Export-Excel C:\temp\EC2.xlsx


write-host "Updating Volume Tags Status ... " -ForegroundColor Yellow 
#Tag all volumes based on their attached EC2 Clinic Tag

$allvol=Get-EC2Volume | Where-Object {$_.tag.key -notcontains "Clinic"}

foreach($item in $result){
    foreach($item2 in $allvol){
    
        if ($item2.attachments.instanceid -eq $item.InstanceId){
                $value=$item.Clinic
              New-EC2Tag -Resource $item2.VolumeId -Tag @{Key="Clinic";value=$value} 
           }
        
        
        }
    
}


Write-Host "Updating Snapshot Tags Status..." -ForegroundColor Yellow 
#Tag all snapshots based on the volume Tag
$allvol=Get-EC2Volume 
$filter= New-Object Amazon.EC2.Model.Filter -Property @{Name = "owner-id"; Values ='386115804199' } 
$snapshots=Get-EC2Snapshot -Filter $filter 


$snapshots1= $snapshots | ? {$_.Tag.key -notcontains "Clinic"} 


foreach($i in $snapshots1){
    $volid=$i.VolumeId
    
    foreach($j in $allvol){
    
        if($volid -eq $j.Volumeid){
           
            $value=$j.tag | Where-Object {$_.key -eq 'Clinic'} | select -ExpandProperty value
            
            $name=$j.Tag | Where-Object {$_.key -eq "Name"} | select -ExpandProperty value

            $snapid=$i.snapshotid
            write-host $snapid
            New-EC2Tag -Resource $snapid -Tag @{Key="Clinic";value=$value} 
            New-EC2Tag -Resource $snapid -Tag @{Key="Name";value=$name}
           
            
        
        }
    }


}

write-host "Deleting Snapshots older than over 60 days !" -ForegroundColor Yellow

$date=(get-date).AddDays(-40)


foreach($snapshot in $snapshots){
    $id=$snapshot.snapshotid

    if($snapshot.starttime -lt $date){
        write-host $snapshot
        Remove-EC2Snapshot -SnapshotId $id -Confirm:$false
    }
}


    


