$all=Get-ADUser -filter {enabled -eq $false} -properties memberof | where { ($_.memberof | measure).count -gt 1} 

#Remove users from all Groups
foreach($one in $all){
    
    $Samaccountname=$one.SamAccountName
    $Samaccountname
    
    Get-AdPrincipalGroupMembership -Identity $Samaccountname | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $Samaccountname


}

#Enabled, update attribute and sync
foreach($one in $all){
    $Samaccountname=$one.SamAccountName
    Enable-ADAccount -Identity $Samaccountname
    get-aduser $Samaccountname -Properties * | Set-ADUser -Replace @{'mailnickname'=$Samaccountname}
    Get-ADUser $Samaccountname -Properties * | Set-ADUser -Replace @{'msExchHideFromAddressLists'=$true}

}

Start-ADSyncSyncCycle -PolicyType Delta


#Delete Cloud Group
foreach($one in $all){
    $Samaccountname=$one.SamAccountName
    C:\temp\Remove_User_All_Groups.ps1 -Identity $Samaccountname -IncludeOffice365Groups 

}


#Disabled Users
foreach($one in $all){
    $Samaccountname=$one.SamAccountName
    Disable-ADAccount $Samaccountname
    
}



