#ERASE ALL THIS AND PUT XAML BELOW between the @" "@ 
$inputXML = @"
<Window x:Class="WpfApplication3.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication3"
        mc:Ignorable="d"
        Title="UnlockTool" Height="350" Width="525" Background="#FFCDDFEC">
    <Grid>
        <Label x:Name="label" Content="Click the Button to query LockOut history" HorizontalAlignment="Left" Margin="18,10,0,0" VerticalAlignment="Top" Width="292"/>
        <Button x:Name="button" Content="Query" HorizontalAlignment="Left" Margin="27,56,0,0" VerticalAlignment="Top" Width="75"/>
        <Button x:Name="button1" Content="Unlock" HorizontalAlignment="Left" Margin="27,260,0,0" VerticalAlignment="Top" Width="75"/>
        <ListView x:Name="listView" HorizontalAlignment="Left" Height="140" Margin="27,99,0,0" VerticalAlignment="Top" Width="454">
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="UserName" DisplayMemberBinding ="{Binding 'username'}" Width="160"/>
                    <GridViewColumn Header="LockOut Computer" DisplayMemberBinding ="{Binding 'computer'}" Width="160"/>
                    <GridViewColumn Header="LockOut Time" DisplayMemberBinding ="{Binding 'time'}" Width="160"/>
                </GridView>
            </ListView.View>
        </ListView>
        <Image x:Name="image" HorizontalAlignment="Left" Height="75" Margin="372,10,0,0" VerticalAlignment="Top" Width="95" Source="c:\temp\unlock.png"/>

    </Grid>
</Window>


"@        

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'


[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML

    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}

#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================

$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}

Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}

Get-FormVariables

#===========================================================================
# Actually make the objects work
#===========================================================================

function get-lockout{
$eventcritea = @{logname='security';id=4740}

$Events =get-winevent -ComputerName (Get-ADDomain).pdcemulator -FilterHashtable $eventcritea 

#$Events = Get-WinEvent -ComputerName syddc01 -Filterxml $xmlfilter        


            
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


$events | select  @{n='UserName';e={$_.targetusername}},@{n='Computer';e={$_.targetdomainname}},@{n='time';e={$_.timecreated}}
}


$WPFbutton.add_click({
get-lockout | %{$WPFlistView.AddChild($_)}

}
  )
    

$WPFbutton1.add_click(
{
Search-ADAccount -LockedOut | ForEach-Object {Unlock-ADAccount -Identity $_.distinguishedname -PassThru }
})


#Reference Sample entry of how to add data to a field
    #$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})
    #$WPFtextBox.Text = $env:COMPUTERNAME
    #$WPFbutton.Add_Click({$WPFlistView.Items.Clear();start-sleep -Milliseconds 840;Get-DiskInfo -computername $WPFtextBox.Text | % {$WPFlistView.AddChild($_)}  })

#===========================================================================
# Shows the form
#===========================================================================
write-host "To show the form, run the following" -ForegroundColor Cyan

function Show-Form{
$Form.ShowDialog() | out-null

}

Show-Form