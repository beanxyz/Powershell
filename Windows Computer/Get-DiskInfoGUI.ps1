#ERASE ALL THIS AND PUT XAML BELOW between the @" "@ 
$inputXML = @"
<Window x:Class="WpfApplication1.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication1"
        mc:Ignorable="d"
        Title="Tool1.0" Height="400" Width="525">
    <Grid>
        <Image x:Name="image" HorizontalAlignment="Left" Height="81" Margin="28,22,0,0" VerticalAlignment="Top" Width="100" Source="C:\temp\kangaroo.png"/>
        <Button x:Name="button" Content="Get-DiskInfo" HorizontalAlignment="Left" Margin="310,133,0,0" VerticalAlignment="Top" Width="75"/>
        <Label x:Name="label" Content="ComputerName" HorizontalAlignment="Left" Margin="18,133,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="textBox1" HorizontalAlignment="Left" Height="23" Margin="159,133,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <TextBlock x:Name="textBlock" HorizontalAlignment="Left" Margin="209,41,0,0" TextWrapping="Wrap" Text="Please use this tool to find out the Computer disk information. Have Fun!" VerticalAlignment="Top" Height="62" Width="275"/>
        <ListView x:Name="listView" HorizontalAlignment="Left" Height="150" Margin="18,180,0,0" VerticalAlignment="Top" Width="466" >
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="Drive Letter" DisplayMemberBinding ="{Binding 'Drive Letter'}" Width="120"/>
                    <GridViewColumn Header="Drive Label" DisplayMemberBinding ="{Binding 'Drive Label'}" Width="120"/>
                    <GridViewColumn Header="Size(GB)" DisplayMemberBinding ="{Binding Size(GB)}" Width="120"/>
                    <GridViewColumn Header="FreeSpace%" DisplayMemberBinding ="{Binding FreeSpace%}" Width="120"/>
                </GridView>
            </ListView.View>
        </ListView>
        <Button x:Name="button1" Content="Clear" HorizontalAlignment="Left" Margin="409,133,0,0" VerticalAlignment="Top" Width="75"/>

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
# Load XAML Objects In PowerShell
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
 
Function Get-DiskInfo {
param($computername =$env:COMPUTERNAME)
 
Get-WMIObject Win32_logicaldisk -ComputerName $computername | Select-Object @{Name='ComputerName';Ex={$computername}},`
                                                                    @{Name=‘Drive Letter‘;Expression={$_.DeviceID}},`
                                                                    @{Name=‘Drive Label’;Expression={$_.VolumeName}},`
                                                                    @{Name=‘Size(GB)’;Expression={[int]($_.Size / 1GB)}},`
                                                                    @{Name=‘FreeSpace%’;Expression={[math]::Round($_.FreeSpace / $_.Size,2)*100}}
                                                                 }
                                                                  
$WPFtextBox1.Text = $env:COMPUTERNAME

 
$WPFbutton.Add_Click({
$WPFlistView.Items.Clear()
$WPFlistView.items.Refresh()

Get-DiskInfo -computername $WPFtextBox1.Text | % {$WPFlistView.AddChild($_)}
})


$WPFbutton1.add_click({
#Get-DiskInfo -computername $WPFtextBox1.Text | % {$WPFlistView.AddChild($_)}
$WPFlistView.Items.Clear()
$WPFlistView.items.Refresh()
}

)
#Sample entry of how to add data to a field
 
#$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})
 
#===========================================================================
# Shows the form
#===========================================================================
write-host "To show the form, run the following" -ForegroundColor Cyan
'$Form.ShowDialog() | out-null'
$Form.ShowDialog() | out-null