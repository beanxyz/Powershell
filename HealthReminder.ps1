$scriptblock={

while($true){
$MessageboxTitle = “Health Reminder”
$Messageboxbody = “Please have a break, my lord”
$MessageIcon = [System.Windows.MessageBoxImage]::Information
$ButtonType = [System.Windows.MessageBoxButton]::OK
[System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$messageicon)


Start-Sleep -Seconds 30

}

}

$job=[powershell]::create()
$job.addscript($scriptblock)
$job.begininvoke()
