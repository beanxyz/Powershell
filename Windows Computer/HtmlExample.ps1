$style=@"
<style>
BODY{background-color:Lavender ;}
TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;b
ackground-color:thistle}
TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:PaleGoldenrod}</style>

"@

Get-DiskInfo -computername sydit01,sydav01,sydwsus,yli-ise | ConvertTo-Html -Body "<H1>DiskInfo</H1>" -Head $style | 
Set-CellColor -Property FreeSpace -color red -filter "FreeSpace -lt 20" | out-file C:\temp\disk.html 
