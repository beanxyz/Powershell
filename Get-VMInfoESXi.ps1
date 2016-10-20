
Connect-viserver sydvcs2012

get-VM | select version,Name, powerstate, numcpu, Memorygb, @{N="IP Address";E={@($_.guest.IPAddress[0])}},@{n="OS";e={$_.guest.osfullname}}, @{n="scsi";e={(Get-ScsiController $_.name).type}} | 
tee -variable result

$result | sort scsi 

Disconnect-VIServer 