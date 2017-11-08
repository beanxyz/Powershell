

function get-dotnet {
<#
.Synopsis
   Get .net and Powershell Version from remtoe machine
.DESCRIPTION
   Get .net and Powershell and OS Version from remtoe machine
.EXAMPLE
   get-dotnet -osname 2012
   This will get the .net, powershell and OS version of connected Windows 2012 Server
.EXAMPLE
   get-dotnet -osname "2012 R2"

   This will get the .net, powershell and OS version of connected Windows 2012 R2 Server
.INPUTS
   String name of OS, such as winows 7, 2008, 2012 etc
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   This is a test function
.COMPONENT
   The component this cmdlet belongs to Yuan Li
.ROLE
   The role this cmdlet belongs to Yuan Li
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

[cmdletbinding()]

param(
[parameter(mandatory=$true,position=1)][string]$osname
)


$a=Get-ADComputer -Filter "operatingsystem -like '*$osname*'" -Properties operatingsystem,ipv4address| Where-Object{$_.ipv4address -ne $null} | select -ExpandProperty name


Invoke-Command -ComputerName $a {
""| select @{name=".Net version";expression={
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | 
Get-ItemProperty -name Version -EA 0 |
Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} | Sort-Object version -Descending | 
Select-Object -ExpandProperty Version -First 1 }
},@{name="PowerShell Version";e={$PSVersionTable.psversion.major}},@{name="OS Version";expression={[environment]::osversion.version.build}}
} | ft



}