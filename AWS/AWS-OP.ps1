Import-Module AWSPowershell

# Get EC2 instance TAG and IP etc
$all=Get-EC2Instance | select -expand instances


$result=@()
foreach($item in $all){

    $Name=$item.tag | Where-Object {$_.Key -eq 'Name'} | select -ExpandProperty value
    $item | add-member -NotePropertyName Description -NotePropertyValue $name
    $item = $item | select *
    $result+=$item

}


$result | select Description, instanceType, privateipaddress, launchtime, platform 

# Get Snapshot size and price

#$Snapshots=Get-EC2Snapshot 


$day=(get-date).AddDays(-5)
$filter= New-Object Amazon.EC2.Model.Filter -Property @{Name = "owner-id"; Values ='386115804199' }
$snapshots=Get-EC2Snapshot -Filter $filter 
$snapshots=$snapshots | Where-Object {$_.starttime -gt $day} 


# Tag instance
foreach($line in $result){


$id=$line.InstanceId



$snap=$Snapshots | Where-Object {$_.Description -like "*$id*"} | select *
$Name=$line.Description

Write-Host $name -ForegroundColor Green
foreach($item in $snap){
    $snapid=$item.snapshotid
    New-EC2Tag -Resource $snapid -Tag @{Key="Name";value=$Name}
}
}


<#
$Snapshots=Get-EC2Snapshot | ? { $_.Tags.Count -gt 0 -and $_.Tags.Key -eq "Name" }

$04=$Snapshots | Where-Object {$_.Tags.value -like '*aws-svr-rds-04*'}


$sum=0
$04 | foreach{$sum+=$_.VolumeSize}

$sum
$rate=0.055
$price=$sum*$rate
$price

#>
