$UserCredentialEO = New-Object System.Management.Automation.PSCredential($credUser, $secpasswd);

$sessionPS = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/?proxymethod=rps -Credential $userCredentialEO -Authentication Basic -AllowRedirection -WarningAction SilentlyContinue

Import-pssession $sessionPS -DisableNameChecking 