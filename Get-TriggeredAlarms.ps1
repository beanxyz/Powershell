 
#Get-VIEvent -Start (Get-Date).AddDays(-5) -MaxSamples ([int]::MaxValue) |
#Where {$_ -is [VMware.Vim.AlarmStatusChangedEvent] -and ($_.To -eq "Yellow" -or $_.To -eq "Red") -and $_.To -ne "Gray"} |
#Select CreatedTime,FullFormattedMessage,@{N="Entity";E={$_.Entity.Name}},@{N="Host";E={$_.Host.Name}},@{N="Vm";E={$_.Vm.Name}},@{N="Datacenter";E={$_.Datacenter.Name}} | tee -Variable result
#


param (
	[String[]]$vCenters
)
 
Function Get-TriggeredAlarms {
	param (
		$vCenter = $(throw "A vCenter must be specified."),
		[System.Management.Automation.PSCredential]$credential
	)
 
	if ($credential) {
		$vc = Connect-VIServer $vCenter -Credential $credential
	}
	else {
		$vc = Connect-VIServer $vCenter
	}
 
	if (!$vc) {
		Write-Host "Failure connecting to the vCenter $vCenter."
		exit
	}
	$rootFolder = Get-Folder -Server $vc "Datacenters"
 
	foreach ($ta in $rootFolder.ExtensionData.TriggeredAlarmState) {
		$alarm = "" | Select-Object VC, EntityType, Alarm, Entity, Status, Time, Acknowledged, AckBy, AckTime
		$alarm.VC = $vCenter
		$alarm.Alarm = (Get-View -Server $vc $ta.Alarm).Info.Name
		$entity = Get-View -Server $vc $ta.Entity
		$alarm.Entity = (Get-View -Server $vc $ta.Entity).Name
		$alarm.EntityType = (Get-View -Server $vc $ta.Entity).GetType().Name	
		$alarm.Status = $ta.OverallStatus
		$alarm.Time = $ta.Time
		$alarm.Acknowledged = $ta.Acknowledged
		$alarm.AckBy = $ta.AcknowledgedByUser
		$alarm.AckTime = $ta.AcknowledgedTime		
		$alarm
	}
	Disconnect-VIServer $vCenter -Confirm:$false
}
 
Write-Host ("Getting the alarms from {0} vCenters." -f $vCenters.Length)
 
$alarms = @()
foreach ($vCenter in $vCenters) {
	Write-Host "Getting alarms from $vCenter."
	$alarms += Get-TriggeredAlarms $vCenter
}
 
$alarms | Out-GridView -Title "Triggered Alarms"