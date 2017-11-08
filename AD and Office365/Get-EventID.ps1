[xml]$xmlFilter = @"
<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[(EventID=1002) and TimeCreated[timediff(@SystemTime) &lt;= 604800000]]]</Select>
  </Query>
</QueryList>
“@

#Get-WinEvent -ComputerName $DC.DC -LogName Security -FilterXPath "*[System[(EventID=529 or EventID=644 or EventID=675 or EventID=676 or EventID=681 or EventID=4625) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]" #-MaxEvents 50
$Events = Get-WinEvent -ComputerName syddc01 -FilterXML $xmlFilter



ForEach ($Event in $Events) {            
    # Convert the event to XML            
    $eventXML = [xml]$Event.ToXml()            
    # Iterate through each one of the XML message properties            
    For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) { 
     
            
        # Append these as object properties            
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  "App" -Value $eventXML.Event.EventData.Data[5]           
    }            
}    


$Events | select Message, App, providerName, timecreated | Out-GridView

break;

# Grab the events from a DC   

Search-ADAccount -LockedOut | select -ExpandProperty distinguishedname


$username=read-host "Input username"
$time=get-aduser $username -Properties * | select -ExpandProperty lastbadpasswordattempt 
$endtime=$time.addminutes(2)
$starttime=$endtime.addminutes(-1)

$eventcritea = @{logname='security';id=4740,4771;starttime=$starttime;endtime=$endtime}

$Events =get-winevent -ComputerName syddc01 -FilterHashtable $eventcritea 
#$Events =Get-WinEvent -ComputerName syddc01 -FilterHashtable @{Logname='Security';Id=4740}

#$Events = Get-WinEvent -ComputerName syddc01 -Filterxml $xmlfilter        


            
# Parse out the event message data            
ForEach ($Event in $Events) {    

      
    # Convert the event to XML            
    $eventXML = [xml]$Event.ToXml()    
    $eventxml.Event.EventData.Data
    write-host "-------------"
       
    # Iterate through each one of the XML message properties            
    For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) { 
     
            
        # Append these as object properties            
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  $eventXML.Event.EventData.Data[$i].name -Value $eventXML.Event.EventData.Data[$i].'#text'            
    }            
}            
  
    
$events |where-object{$_.targetusername -eq $username}|select id,ipaddress, TargetUserName,timecreated, targetdomainname | Out-GridView


break;





$Event = Get-WinEvent -ComputerName syddc01 -FilterHashtable @{Logname='Security';Id=4740} -MaxEvents 1

$eventXML = [xml]$Event.ToXml()
$eventxml.Event.EventData.Data
