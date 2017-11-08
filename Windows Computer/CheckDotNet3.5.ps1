$a=Get-ADComputer -Filter {operatingsystem -like "*windows*"} | select -ExpandProperty name


$a=Invoke-Command -ComputerName $a -ErrorAction SilentlyContinue -ErrorVariable err{
""| select @{name=".Net 3 Installed";expression={
$temp=Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | 
Get-ItemProperty -name Version -EA 0 |
Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} | select -ExpandProperty version; if($temp -like "3.*"){"Yes"}else{"No"}}
},@{name="PowerShell Version";e={$PSVersionTable.psversion.major}},@{name="OS Version";expression={[environment]::osversion.version.build}}
} | sort ".Net 3 Installed" 


$a|ft

Write-Host "Following Hosts are offline/Disconnected" -BackgroundColor Red
$err.TargetObject


$err.TargetObject | measure

#$b=$a | Where-Object {($_.'.Net 3 Installed' -eq 'No')  }




#Invoke-Command -ComputerName $b.PSComputerName -ScriptBlock {  dism /online /enable-feature /featurename:netFx3 /all /source:\\sydav01\SophosUpdate\tightvnc\2012\sxs /LimitAccess}