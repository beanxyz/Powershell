#LabA

function Get-ComputerInfo {
<#
.Synopsis
   Short description
.DESCRIPTION
   Get Computer Info
.EXAMPLE
   Get-ComputerInfo -ComputerName "sydav01","sydit01"

   Get Computer Info from multiple computers
.EXAMPLE
   "Localhost" | Get-ComputerInfo

   Pipe computer names into this function
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
[cmdletbinding()]
param(
[Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
[string[]]
[validatenotnullorempty()]$ComputerName,
[string]$Errorfile="c:\errors.txt"
)


begin{
Write-Verbose "Start Querying "
Write-Verbose "Log file is $errorfile"


}

process{

write-verbose "Start Process $computerName"

Get-WmiObject -ComputerName $computerName -Class win32_computersystem -ErrorAction SilentlyContinue -ErrorVariable err| 
select @{n="ComputerName";e={$_.pscomputername}}, Workgroup, @{n="AdminPassword";e={if($_.AdminPasswordStatus -eq "1"){"Disabled"}elseif($_.AdminPasswordStatus -eq "2"){"Enabled"}elseif($_.AdminPasswordStatus -eq "3"){"NA"}else{"Unknown"}}}, Model, Manufacturer,`
@{n="BIOSVERSION";e={Get-WmiObject -computername $computername -Class win32_bios | select -ExpandProperty SerialNumber}},`
@{n="OSVersion";e={Get-WmiObject -computername $computername -Class win32_Operatingsystem | select -ExpandProperty Version}},`
@{n="SPVersion";e={Get-WmiObject -computername $computername -Class win32_Operatingsystem | select -ExpandProperty ServicePackMajorVersion}} 

}

end{

if($err -ne $null){
Write-verbose "There are some errors, please check details from the log files "
$err | Out-File $Errorfile


}
else{

Write-Verbose "Complete Successfully"
}
}
}

#Get-ComputerInfo -computerName "sss","sydav01" -Errorfile c:\temp\error.txt -Verbose
#get-computerInfo -computerName "sydwsus" -Verbose



#LabB

Function Get-DiskInfo {
<#
.Synopsis
   Short description
.DESCRIPTION
   Get Disk Info
.EXAMPLE
   Get-DiskInfo -computername "sydwsus","sydav01" -Verbose
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
[cmdletbinding()]
Param (
[parameter(Mandatory=$true, 
                   ValueFromPipeline=$true)]
[string[]]$computername,
[int]$MinimumFreePercent=10,
[string]$errorfile="c:\errors.txt"
)



$disks=Get-WmiObject -Class Win32_Logicaldisk -Filter "Drivetype=3" -ComputerName $computername -ErrorAction SilentlyContinue -ErrorVariable err


$result=foreach ($disk in $disks) {

$perFree=($disk.FreeSpace/$disk.Size)*100;

if ($perFree -ge $MinimumFreePercent) {$OK=$True}
else {$OK=$False};

$disk|Select @{n="Computer";e={$disk.pscomputername}},DeviceID,VolumeName,`
@{n="Size";e={"{0:N2}" -f ($_.Size/1GB)}},`
@{n="FreeSpace";e={"{0:N2}" -f ($_.Freespace/1GB)}},`
@{Name="OK";Expression={$OK}}

}

$result 

if($err -ne $null){
Write-verbose "There are some errors, please check details from the log files "
$err | Out-File $Errorfile


}
else{

Write-Verbose "Complete Successfully"
}

}


#Get-DiskInfo -computername "sydwsus","sydav01" -Verbose

#LabC

function Get-ComputerService {

param(

[string[]]$computername="localhost"

)

get-wmiobject -ComputerName $computername -Class win32_service -Filter "State like 'Running'" | 
select @{n="ComputerName";e={$_.pscomputername}} ,`
name, displayname, Processid, `
@{n="Virtual Memory";e={get-process -id $_.processid|select -ExpandProperty virtualMemorysize}},`
@{n="Peak Page file Usage(M)";e={get-process -id $_.processid|select @{n="PeakPagedMemorySize(M)";e={"{0:N2}" -f ($_.PeakPagedMemorySize/1MB)}}| select -ExpandProperty "PeakPagedMemorySize(M)" }},`
@{n="Threads count";e={(get-process -id $_.processid|select -expand threads).count}} | ft


}

#get-computerservice 

#Chap 7

Function Get-SystemInfo{

[cmdletbinding()]
param(
[string[]]$ComputerName
)
begin{}

process{


$result=@()

foreach($computer in $ComputerName){

try{

write-verbose "Querying OS and Computer System"
$os=Get-WmiObject -Class win32_operatingsystem -ErrorAction Stop 
$cs=Get-WmiObject -Class win32_computersystem -ErrorAction Stop

}catch{

$computer |out-file c:\temp\error.txt -Append


}


$prop=@{ComputerName=$computer;LastBootTime=$os.ConvertToDateTime($os.LastBootUpTime);OSVersion=$os.Version;Manufacture=$cs.Manufacturer;Model=$cs.model}



$obj=New-Object -TypeName psobject -property $prop

$obj.psobject.typenames.insert(0,'Yuan.systeminfo')

write-output $obj |gm

}




}


end {}





}


Get-SystemInfo -ComputerName "localhost"


function Get-DetailedInfo{

[cmdletbinding()]
param(
[string[]]$ComputerNames
)


foreach($ComputerName in $ComputerNames){
$disks=get-diskinfo -computername $ComputerName
$service=Get-ComputerService -computername $ComputerName

$props=@{'ComputerName'=$computerName;'disksInfo'=$disks;'Services'=$service}
$obj=New-Object -TypeName psobject -Property $props
$obj
}

}