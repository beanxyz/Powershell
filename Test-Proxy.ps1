function Test-Proxy{

[cmdletbinding()]
param(
 [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   position=0 
                   )
                ]
 [string]$server,
 [string]$url = "http://www.microsoft.com"


)


write-host "Test Proxy Server:　$server"
$proxy = new-object System.Net.WebProxy($server)
$WebClient = new-object System.Net.WebClient
$WebClient.proxy = $proxy

Try
{
  $content = $WebClient.DownloadString($url)
  Write-Host "Opened $url successfully" -ForegroundColor Cyan
}
catch
{
  Write-Host "Unable to access $url" -ForegroundColor Yellow 
}
}

Test-Proxy -server sydtmg01

