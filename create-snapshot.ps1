
$allvol=Get-EC2Volume 

foreach( $vol in $allvol){
    
    $volumeid=$vol.volumeId
    New-EC2Snapshot -VolumeId $volumeid


}