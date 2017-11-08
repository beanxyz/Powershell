
#Get Connected servers from AD


Write-Host "Scanning Online Servers ..."

$a=get-adcomputer -filter {operatingsystem -like "*20*"}

$computers=@()
foreach ($b in $a ){

if(Test-Connection -computername $b.name -Count 1 -Quiet){

$temp=[psobject]@{'name'=$b.name}
$computers+=$temp
}

}


Write-Host "Scanning Nagios Clients ..."

$c2=@()
$computers | ForEach-Object {

$path="\\"+$_.name+"\c$\Program Files\NSClient++\nsclient.ini"
$bakpath="\\"+$_.name+"\c$\Program Files\NSClient++\nsclient.ini.bak"


if ((Test-Path -Path $path) -and !(Test-Path -Path $bakpath))
{

 #copy $path $bakpath
 #copy "\\sydav01\c`$\program files\NSClient++\nsclient.ini" $path 
 #"Restart nscp service on "+$_.name
 #Invoke-Command -ComputerName $_.name {restart-service nscp}

}else
{

$path + " Folder doesn't Esixt"
$temp=[pscustomobject]@{'name'=$_.name}
$c2+=$temp


}

}

$end=$false

while ( $end -eq $false){

Write-Host "Following servers don't have Nagios Client Installed. "
$c2.name

$option= read-host "Do you want to Install ? ( Y/N ) "



switch($option)
{

"Y"{ 

    $c2| foreach-object {

    $path2="\\"+$_.name+"\c$\temp\NSCP.msi"

    if( Test-Path $path2){}
    else {
    New-Item $path2 -Force
    }
    Write-host "Copying NSCP.msi files to "$path2
    copy '\\sydit01\c$\Temp\NSCP-0.4.4.15-x64.msi' $path2 | Out-Null
    Write-host "Copying is completed and start to install"
    Invoke-Command -ComputerName $_.name -ScriptBlock {

    Start-Process -FilePath msiexec.exe -ArgumentList "/i c:\temp\NSCP.msi /q" -Wait -PassThru
    }

    $path3="\\"+$_.name+"\c$\Program Files\NSClient++\nsclient.ini"

    Write-host "Installation is completed and now is updting config file"
    copy "\\sydav01\c$\program files\NSClient++\nsclient.ini" $path3

    Invoke-Command -ComputerName $_.name {restart-service nscp}

}
$end=$true;

}

"N"{
    $end=$true
    }
default{
    "Please answer Y or N"
}




}
}


   Invoke-Command -ComputerName sydit01 -ScriptBlock {

    Start-Process -FilePath msiexec.exe -ArgumentList "/i c:\temp\NSCP-0.4.4.15-x64.msi.msi /q" -Wait -PassThru
    }
