$file=import-excel C:\temp\1iG5NDGVre.xlsx -StartRow 10


$result=@()
foreach($one in $file){
   
    $id=$one.'Security Group ID'.Split()[0].trim()
    $all=Get-EC2Instance -Filter @{name='instance.group-id';value=$id } | select -ExpandProperty Instances     
    foreach($item in $all){
    
        $Name=$item.tag | Where-Object {$_.Key -eq 'Name'} | select -ExpandProperty value
        $item | add-member -NotePropertyName Description -NotePropertyValue $name
        $item
        $result+=$item
    }
   
    
}

$result | select -Unique Description, InstanceID, SecurityGroups, @{n='State';e={$_.state.Name}} | Where-Object {$_.state -ne 'stopped'} 



$all=Get-EC2SecurityGroup
$temp=@()
foreach($one in $all){
    $id=$one.groupid
    #$id='sg-0ee7e66bf246d86d0'
    $all=Get-EC2NetworkInterface -Filter @{name='group-id';value=$id } 
    #$all=Get-EC2Instance -Filter @{name='instance.group-id';value=$id } 
      
    if ($all -eq $null){
    
        $temp+=$one
    }


}

$temp | ft




