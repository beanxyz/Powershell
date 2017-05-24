
function load-ADModule{
$s= New-PSSession -ComputerName "syddc01"
Invoke-Command -Session $s {Import-Module activedirectory}
Import-PSSession -Session $s -Module activedirectory 

}

load-ADModule

break

function Load-PowerCLI
{
    #pls download and install module first
    Add-PSSnapin VMware.VimAutomation.Core
   # Add-PSSnapin VMware.VimAutomation.Vds
   # Add-PSSnapin VMware.VumAutomation
    . "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}


Load-PowerCLI


Connect-VIServer sydvcs2012



, @{n="NIC";e={$_.guest.networkadpters}} | sort "IP Address" | ft Export-Csv C:\temp\vsphere.csv

get-vm | Get-HardDisk -vm {$_.Name} | select capacitygb, filename, name, parent | sort parent, name | Export-Csv C:\temp\disk.csv

break;
$s| Remove-PSSession
break;



$UserCredential = Get-Credential 

Connect-MsolService -Credential $UserCredential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

#Delete  Calendar
#Search-Mailbox -Identity "mcrabtree" -SearchQuery {subject:"weekly wip - telstra,DDB,Code"} -DeleteContent


get-mailbox cking

Search-Mailbox -Identity "cking" -SearchQuery {subject:"FW: Weekly NBN Marketing Review"} -DeleteContent

FW: Weekly NBN Marketing Review

Remove-PSSession $Session


Set-MsolUserPrincipalName -UserPrincipalName jbroadrick@syd.ddb.com -NewUserPrincipalName justin.broadrick@syd.ddb.com