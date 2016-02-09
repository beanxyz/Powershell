

function Get-Software{

[cmdletbinding()]

param(
[parameter(mandatory=$true,position=1)][string]$software,
[string]$OS
)



$a=Get-ADComputer -Filter "operatingsystem -like '*$OS*' " -Properties operatingsystem,ipv4address  | Where-Object{$_.ipv4address -ne $null} | select -ExpandProperty name



$s=Invoke-Command -ComputerName $a -erroraction SilentlyContinue -ErrorVariable disconnect{

param([string]$name)
if ([System.IntPtr]::Size -eq 4) {
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object{$_.displayname -like "*$name*"} | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate 


 } else { 
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |  Where-Object{$_.displayname -like "*$name*"} | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

}



} -ArgumentList $software

$disconnect.targetobjects


$s | Out-GridView


$s | Group-Object pscomputername


}

Get-software -software "java" -OS 2012