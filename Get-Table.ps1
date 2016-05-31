

$web = 'http://www.proxylisty.com/country/Australia-ip-list'

$template = 
@'
<tr>
<td>{IP*:203.56.188.145}</td>
<td><a href='http://www.proxylisty.com/port/8080-ip-list' title='Port 8080 Proxy List'>{Port:8080}</a></td>
<td>HTTP</td>
<td><a style='color:red;' href='http://www.proxylisty.com/anonymity/High anonymous / Elite proxy-ip-list' title='High anonymous / Elite proxy Proxy List'>High anonymous / Elite proxy</a></td>
<td>No</td>
<td><a href='http://www.proxylisty.com/country/Australia-ip-list' title='Australia IP Proxy List'><img style='margin: 0px 5px 0px 0px; padding: 0px;' src='http://www.proxylisty.com/assets/flags/AU.png' title='Australia IP Proxy List'/>Australia</a></td>
<td>13 Months</td>
<td>2.699 Sec</td>
<td><div id="progress-bar" class="all-rounded">
<div title='50%' id="progress-bar-percentage" class="all-rounded" style="width: 50%">{Reliability:50%}</div></div></td>

</tr>




<tr>
<td>{IP*:103.25.182.1}</td>
<td><a href='http://www.proxylisty.com/port/8081-ip-list' title='Port 8081 Proxy List'>{Port:8081}</a></td>
<td>HTTP</td>
<td><a style='color:red;' href='http://www.proxylisty.com/anonymity/Anonymous proxy-ip-list' title='Anonymous proxy Proxy List'>Anonymous proxy</a></td>
<td>No</td>
<td><a href='http://www.proxylisty.com/country/Australia-ip-list' title='Australia IP Proxy List'><img style='margin: 0px 5px 0px 0px; padding: 0px;' src='http://www.proxylisty.com/assets/flags/AU.png' title='Australia IP Proxy List'/>Australia</a></td>
<td>15 Months</td>
<td>7.242 Sec</td>
<td><div id="progress-bar" class="all-rounded">
<div title='55%' id="progress-bar-percentage" class="all-rounded" style="width: 55%">{Reliability:55%}</div></div></td>

</tr>


'@

<#
$t2=@'
<tr>
<td valign="top">{Food*:Banana cake, made with sugar}</td>
<td valign="top">{GI:47}</td>
<td valign="top">{Size:60}</td>

</tr>
<tr>
<td valign="top">{Food*:Banana cake, made without sugar}</td>
<td valign="top">{GI:55}</td>
<td valign="top">{Size:60}</td>

</tr>
'@
#>

$web2='http://ultimatepaleoguide.com/glycemic-index-food-list/'


$temp=Invoke-RestMethod  -uri $web 
$result = ConvertFrom-String -TemplateContent $template   -InputObject  $temp      
$result  | sort reliability


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


write-host "Test Proxy Server:　$server" -NoNewline
$proxy = new-object System.Net.WebProxy($server)
$WebClient = new-object System.Net.WebClient
$WebClient.proxy = $proxy

Try
{
  $content = $WebClient.DownloadString($url)
  Write-Host " Opened $url successfully" -ForegroundColor Cyan
}
catch
{
  Write-Host " Unable to access $url" -ForegroundColor Yellow 
}
}


foreach ($r in $result){
$servername="http://"+$r.IP+":"+$r.Port

Test-proxy -server $servername -url "www.google.com"


}






#Invoke-RestMethod  -uri $web2 -OutFile c:\temp\tt1
#$result1 = ConvertFrom-String -TemplateContent $t2   -InputObject  (gc -raw -literalpath c:\temp\tt1)       #PowerShell 爬虫步骤3：根据模板匹配扣出需要的行列标准内容。关键就是做好模板。
#$result1  | Out-GridView


