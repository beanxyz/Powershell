$userid='geoff.rose@vet.partners'
$pass = "" | ConvertTo-SecureString
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userid, $pass
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $creds -Authentication Basic -AllowRedirection
Import-PSSession $Session

#Variables
$hd = "Hospital Directors"
$hd = "Hospitals"
$hd = "Nurses"
$hd = "Practice Managers"
$hd = "Regional Operations Manager"
$hd = "Teams"
$hd = "Vets"

$clinic = "AshgroveAvenue-"
$domain = "@ashgrovevet.com.au"

#region Variables for the groups
$ALL = "ALL - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "AU - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "NSW - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "NSW - 1 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "NSW - 2 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "NSW - 3 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "NSW - 4 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "NZ - 3 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "NZ - 2 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "QLD - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "QLD - 1 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "QLD - 2 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "QLD - 3 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "SA - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "SA - 1 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "SA - 2 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "SG - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "TAS - 1 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "VIC - 1 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed

$ALL = "WA - 1 - " + $hd
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"
New-DistributionGroup -Name $ALL -DisplayName $all  -Alias "$alias" -PrimarySmtpAddress $email -MemberDepartRestriction closed
#endregion
#Alias in use
$alias = $all.substring(0, [System.Math]::Min(22, $all.Length))
$alias = $alias -replace '\s',''
$email = $alias + "@vet.partners"

#state groups
$stateHD = "QLD - 3 - Hospital Directors"
$stateNU = "QLD - 3 - Nurses"
$statePM = "QLD - 3 - Practice Managers"
$stateTE = "QLD - 3 - Teams"
$stateVE = "QLD - 3 - Vets"

#Get members of the current groups
$cliniclist = get-content C:\scripts\cliniclist.txt
$domainlist = get-content C:\scripts\domainlist.txt
for ($i=0; $i -le $cliniclist.Length; $i++)


for ($i=0; $i -le 7; $i++)
{Write-Host "clinic is $cliniclist[$i]"}

$clinicHD = $cliniclist[$i] + "HD@" + $domainlist[$i]
$clinicNU = $cliniclist[$i] + "NU@" + $domainlist[$i]
$clinicPM = $cliniclist[$i] + "PM@" + $domainlist[$i]
$clinicTE = $cliniclist[$i] + "TE@" + $domainlist[$i]
$clinicVE = $cliniclist[$i] + "VE@" + $domainlist[$i]



    $clinicgroups = Get-DistributionGroup | where {$_.primarysmtpaddress -like "$clinic*ashgrovevet.com.au"}
    foreach ($clinicgroup in $clinicgroups)
    {
        switch ($clinicgroup.PrimarySmtpAddress)
        {
           #$clinicHD
            #{Add-DistributionGroupMember -Identity $stateHD -Member $clinicHD}
            $clinicNU
            {Add-DistributionGroupMember -Identity $stateNU -Member $clinicNU}
            $clinicPM
            {Add-DistributionGroupMember -Identity $statePM -Member $clinicPM}
            $clinicTE
            {Add-DistributionGroupMember -Identity $stateTE -Member $clinicTE}
            $clinicVE
            {Add-DistributionGroupMember -Identity $stateVE -Member $clinicVE}

        }
    }

}

Add-DistributionGroupMember -Identity "QLD - 3 - Nurses"

$state = @(""



$HDMembers = Get-DistributionGroup -Identity "NZ - Hospital Directors" | Get-DistributionGroupMember -Identity "ALL - Hospital Directors"
$NUMembers = Get-ADGroupMember -Identity "Nurses - $groupname" | get-aduser -Properties emailaddress | select emailaddress
$PMMembers = Get-ADGroupMember -Identity "Practice Manager - $groupname" | get-aduser -Properties emailaddress | select emailaddress
$TEMembers = Get-ADGroupMember -Identity "Team - $groupname" | get-aduser -Properties emailaddress | select emailaddress
$VEMembers = Get-ADGroupMember -Identity "Vets - $groupname" | get-aduser -Properties emailaddress | select emailaddress

foreach ($HDMember in $HDmembers) {
Add-DistributionGroupMember –Identity $hddisplayname –Member $HDMember.emailaddress
}
foreach ($NUMember in $NUmembers) {
Add-DistributionGroupMember -Identity $nursedisplayname -Member $NUMember.emailaddress
}
foreach ($PMMember in $PMmembers) {
Add-DistributionGroupMember –Identity $pmdisplayname –Member $PMMember.emailaddress
}
foreach ($TEMember in $TEmembers) {
Add-DistributionGroupMember –Identity $teamdisplayname –Member $TEMember.emailaddress
}
foreach ($VEMember in $VEmembers) {
Add-DistributionGroupMember –Identity $vetsdisplayname –Member $VEMember.emailaddress
}