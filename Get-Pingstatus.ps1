
function ComputerStatus{
param(
[string]$os1=200

)

$a="*"+$os1+"*"

Get-ADComputer -Filter{(operatingsystem -like $a) } -Properties operatingsystem,ipv4address |
 sort operatingsystem| select name, operatingsystem, 
@{name="status";expression={if(Test-Connection -ComputerName $_.name -count 1 -quiet ){return "Connected"}else{return "Disconnected"}}}, ipv4address
 

 }

