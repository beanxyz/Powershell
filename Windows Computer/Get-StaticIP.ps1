
#获取domain里面所有的静态地址的机器
function get-static{

    $computers=Get-ADComputer -Filter {operatingsystem -like "*windows*"}

    $result=invoke-command -ComputerName $computers.name -ScriptBlock {Get-WmiObject win32_networkadapterconfiguration | Where-Object { ($_.IPAddress -ne $null) -and ($_.dhcpenabled -eq $false)}
    } -ErrorAction SilentlyContinue -ErrorVariable aa 

    $result
}