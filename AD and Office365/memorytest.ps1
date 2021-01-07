### First, we create one or more MetricDatum objects
$Metric = [Amazon.CloudWatch.Model.MetricDatum]::new()
$Metric.MetricName = 'Status'
$Metric.Unit="%"
$Metric.Timestamp = [DateTime]::UtcNow;
$os = Get-Ciminstance Win32_OperatingSystem
$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
$Metric.Value=$pctFree




### Second, we write the metric data points to a CloudWatch metrics namespace
Write-CWMetricData -MetricData $Metric -Namespace Yuantest/test2