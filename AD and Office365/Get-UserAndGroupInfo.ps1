function Get-localuser{
$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$adsi.Children | where {$_.SchemaClassName -eq 'user'}  | select name,Lastlogin
}



function Get-localuserGroup{

$eventcritea = @{logname='security';id=4732}


$Events =get-winevent -ComputerName $env:COMPUTERNAME -FilterHashtable $eventcritea 
    

$result=@()
            
# Parse out the event message data            
ForEach ($Event in $Events) {    

      
    # Convert the event to XML            
    $eventXML = [xml]$Event.ToXml()    

    $groupname=$eventXML.Event.EventData.Data[2].'#text'.ToString()
    $sid= $eventXML.Event.EventData.Data[1].'#text'.ToString()
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
    $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
  

    $temp=[pscustomobject]@{Time=$Event.TimeCreated;Username=$objUser.Value;GroupName=$groupname}

   $result+=$temp
}            
  
  $result
}

function get-domainAdminUser{

$pdc=Get-ADDomainController -Discover -Service PrimaryDC
$dn=(get-adgroup "domain admins").distinguishedname
Get-ADReplicationAttributeMetadata $dn -Server $pdc -ShowAllLinkedValues | Where-Object {$_.attributename -eq 'member'} | select FirstOriginatingcreatetime, attributevalue
}