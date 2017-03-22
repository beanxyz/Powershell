

function Get-Software{

[cmdletbinding()]

param(
[parameter(mandatory=$true,position=1)][string]$software,
[string]$computername="*",
[string]$OS='*'
)


Write-Verbose "Scanning Computers..."

if($computername -ne '*'){
$a=Get-ADComputer -Filter "name -like '*$computername*' " -Properties operatingsystem,ipv4address  | Where-Object{$_.ipv4address -ne $null} | select -ExpandProperty name
}else
{

$a=Get-ADComputer -Filter  *  -Properties operatingsystem,ipv4address  | Where-Object{$_.ipv4address -ne $null} | select -ExpandProperty name

}

Write-Verbose "Scanning Software ..."

$s=Invoke-Command -ComputerName $a -erroraction SilentlyContinue -ErrorVariable disconnect{

param([string]$name)
if ([System.IntPtr]::Size -eq 4) {
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object{$_.displayname -like "*$name*"} | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, @{n='OS';e={(Get-WmiObject Win32_OperatingSystem).name.split("|")[0]}} 


 } else { 
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |  Where-Object{$_.displayname -like "*$name*"} | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate,@{n='OS';e={(Get-WmiObject Win32_OperatingSystem).name.split("|")[0]}} 

}



} -ArgumentList $software

Write-Verbose "Disconnected Computers"

$disconnect.targetobject


$s | Out-GridView


$s | Group-Object pscomputername


}

#Get-software -software "skype"  -verbose