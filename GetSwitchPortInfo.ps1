#ping 10.2.1.255
#sh ip arp vlan                ....> t1
#sh mac address-table vlan 10  ....> t2




$t1=import-csv C:\temp\arptable.csv -head Protocol, IP, Age, Mac, Type, Interface
$t2=gc C:\temp\mactable.txt


$obj=$t1| foreach{


$info=$t2 | select-string -Pattern $_.mac

if($info -ne $null){

$test=$info | ConvertFrom-String -PropertyNames mark,vlan,mac, type, connecte, speed, port

[pscustomobject]@{IP=$_.IP;mac=$test.mac;port=$test.port}

}

}

$obj | select IP, Mac, @{n='DNS';e={[System.Net.Dns]::gethostentry($_.IP).hostname}}, Port | tee -Variable result