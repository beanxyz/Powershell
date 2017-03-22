$drive=New-Object -Com WScript.Network
$drive.MapNetworkDrive('N:', '\\syd02\IT',$true)

$sh=New-Object -com Shell.Application

$sh.NameSpace('N:').Self.Name = 'My new drive name'