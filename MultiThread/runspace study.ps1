$rs=[runspacefactory]::CreateRunspace()
$rs.name="MyRunSpace"
$rs.open()
get-runspace

$ps=[powershell]::create()
$ps.runspace=$rs
$ps.addscript('C:\users\yli\documents\github\Powershell\Restart-WSUSComputers.ps1') > $null
$async=$ps.BeginInvoke()
get-runspace

Debug-Runspace Myrunspace

#example1

$PowerShell = [powershell]::Create()

[void]$PowerShell.AddScript({

    Get-Date
    
    Start-Sleep -Seconds 10
})

$PowerShell.Invoke()


#example2

$Runspace = [runspacefactory]::CreateRunspace()

$PowerShell =[powershell]::Create()

$PowerShell.runspace = $Runspace

$Runspace.Open()

[void]$PowerShell.AddScript({

    Get-Date

    Start-Sleep -Seconds 10

})

$AsyncObject = $PowerShell.BeginInvoke()


$Data = $PowerShell.EndInvoke($AsyncObject)

$Data

$PowerShell.Dispose()

#example 3

$name = 'James'
$title = 'Manager'
$PowerShell =[powershell]::Create()
[void]$PowerShell.AddScript({
    Param ($Param1, $Param2)
    [pscustomobject]@{
        Param1 = $Param1
        Param2 = $Param2
    }
}).AddArgument($name).AddArgument($title)
#Invoke the command
$PowerShell.Invoke()
$PowerShell.Dispose()