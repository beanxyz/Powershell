
# Test VPN connection from AWS to Galdesville, if lost connection then reset the tunnel on VPN server 172.16.1.52 ( VPN1 )
<#
if( Test-connection -ComputerName au-svr-dc-01 -Count 3 -Quiet){
    Write-Host "Connection to Gladsville is good" -ForegroundColor Green
}
else{

    $nopasswd = new-object System.Security.SecureString
    $Crendential= New-Object System.Management.Automation.PSCredential ("vyos", $nopasswd)


    New-SSHSession –ComputerName 172.16.1.52 -KeyFile 'c:\temp\vpau.pem' -Credential $Crendential
    $session = Get-SSHSession -Index 0
    $stream = $Session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)


    
    #Invoke-VyOSCommand -Command "show vpn ike sa | grep -A5 -B5 Bexley" -Stream $stream
    #sleep 4
    $command="reset vpn ipsec-peer 61.69.91.242"
    $stream.write($command)
    sleep 2

    $stream.read()
    Remove-SSHSession -SessionId 0
        
    $Changetime=get-date
    "$Changetime Reset tunnel of Gladsvilled" | out-file C:\temp\bexley\logs.txt -Append


}

#>
#Test vpn connection to Ashgrove
<#
if( Test-connection -ComputerName 10.4.7.1 -Count 3 -Quiet){
    Write-Host "Connection to Ashgrove is good" -ForegroundColor Green
}
else{

    $nopasswd = new-object System.Security.SecureString
    $Crendential= New-Object System.Management.Automation.PSCredential ("vyos", $nopasswd)


    New-SSHSession –ComputerName 172.16.1.52 -KeyFile 'c:\temp\vpau.pem' -Credential $Crendential
    $session = Get-SSHSession -Index 0
    $stream = $Session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)


    
    #Invoke-VyOSCommand -Command "show vpn ike sa | grep -A5 -B5 Bexley" -Stream $stream
    #sleep 4
    $command="reset vpn ipsec-peer 211.27.172.84"
    $stream.write($command)
    sleep 2

    $stream.read()
    Remove-SSHSession -SessionId 0
        
    $Changetime=get-date
    "$Changetime Reset tunnel of Ashgrove" | out-file C:\temp\bexley\logs.txt -Append


}
#>
#Test vpn connection to Chatswood


<# Test VPN connection from AWS to Bexley. 
If lost connection , check IP address; 
If IP is the same, then reset the tunnel on VPN Server 172.16.1.52; 
if IP address changed, then delete the old entry and create new one;

#>
if(Test-Connection -ComputerName BX-SVR-DCDB-01 -Count 3 -Quiet){
    #if connection is fine, ignore
    Write-Host "Connection to Bexley is good" -ForegroundColor Green
}
else{

    $temp=gc C:\temp\bexley\bexley.txt
    $computer='bexleyvet.dyndns.org'
    $new=[system.net.Dns]::GetHostAddresses($computer) | select -expand IPaddressTostring

    if($temp -eq $new){

        Write-Host "IP is the same, will reset tunnel.." -ForegroundColor Yellow
    #if IP is the same, simply reset the tunnel
        $nopasswd = new-object System.Security.SecureString
        $Crendential= New-Object System.Management.Automation.PSCredential ("vyos", $nopasswd)


        New-SSHSession –ComputerName 172.16.1.52 -KeyFile 'c:\temp\vpau.pem' -Credential $Crendential
        $session = Get-SSHSession -Index 0
        $stream = $Session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)


    
        #Invoke-VyOSCommand -Command "show vpn ike sa | grep -A5 -B5 Bexley" -Stream $stream
        #sleep 4
        $command="reset vpn ipsec-peer $new"
        $stream.write($command)
        sleep 2

        $stream.read()
        Remove-SSHSession -SessionId 0
        
        $Changetime=get-date
        "$Changetime Reset tunnel of Bexley" | out-file C:\temp\bexley\logs.txt -Append

    }

    else{

        Write-Host "IP is changed, will create new entry" -ForegroundColor Red

        

        $nopasswd = new-object System.Security.SecureString
        $Crendential= New-Object System.Management.Automation.PSCredential ("vyos", $nopasswd)


        New-SSHSession –ComputerName 172.16.1.52 -KeyFile 'c:\temp\vpau.pem' -Credential $Crendential
        $session = Get-SSHSession -Index 0
        $stream = $Session.Session.CreateShellStream("dumb", 0, 0, 0, 0, 1000)
        #Invoke-VyOSCommand -Command "config" -Stream $stream
        sleep 6

        $commands=@(
        "config"
        "set vpn ipsec site-to-site peer $new"
        "set vpn ipsec site-to-site peer $new authentication mode pre-shared-secret"
        "set vpn ipsec site-to-site peer $new authentication pre-shared-secret 8M6bbp1KTJSZZDB9vjQa"
        "set vpn ipsec site-to-site peer $new connection-type respond"
        "set vpn ipsec site-to-site peer $new default-esp-group AWSGL"
        "set vpn ipsec site-to-site peer $new description Bexley"
        "set vpn ipsec site-to-site peer $new ike-group AWSGL"
        "set vpn ipsec site-to-site peer $new local-address 172.16.1.52"
        "set vpn ipsec site-to-site peer $new tunnel 0 local prefix 172.16.0.0/16"
        "set vpn ipsec site-to-site peer $new tunnel 0 remote prefix 10.2.2.0/24"
        "set vpn ipsec site-to-site peer $new authentication id 54.66.164.57"
        "del vpn ipsec site-to-site peer $temp"
        "commit"
        "save"
        "exit"
        )


        foreach ($command in $commands){
            #Invoke-VyOSCommand -Command $command -Stream $stream
            $stream.write($command+"`n")
            $stream.read()
            
            
            sleep 2
        
        }

        $stream.write("show vpn ike sa | grep -A5 -B5 Bexley") 

        $Changetime=get-date
        "$Changetime IP Address is changed from $temp to $new" | out-file C:\temp\bexley\logs.txt -Append

        $new | out-file C:\temp\bexley\bexley.txt

        Remove-SSHSession -SessionId 0
    }
}