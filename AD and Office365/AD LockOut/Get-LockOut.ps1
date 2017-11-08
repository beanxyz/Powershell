
function get-lockout{

$eventcritea = @{logname='security';id=4740}

$Events =get-winevent -ComputerName (Get-ADDomain).pdcemulator -FilterHashtable $eventcritea 

#$Events = Get-WinEvent -ComputerName syddc01 -FilterHashtable $eventcritea     


            
# Parse out the event message data            
ForEach ($Event in $Events) {    

      
    # Convert the event to XML            
    $eventXML = [xml]$Event.ToXml()    

          
    # Iterate through each one of the XML message properties            
    For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) { 
     
            
        # Append these as object properties            
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  $eventXML.Event.EventData.Data[$i].name -Value $eventXML.Event.EventData.Data[$i].'#text'            
    }            
}            
  
    
$events | select  TargetUserName,timecreated, targetdomainname | Out-GridView -Title LockOutStatus

}


get-lockout

Search-ADAccount -LockedOut | ForEach-Object {Unlock-ADAccount -Identity $_.distinguishedname }