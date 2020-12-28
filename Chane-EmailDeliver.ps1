Function Get-UsersInGroup ([string]$Group) {
    ForEach ($Object in (Get-ADGroupMember $Group) ) {
        if ($Object.objectClass -eq "group") {
            Get-UsersInGroup -Group $Object.Name
        } else {
            [PSCustomObject]@{Group=$Group;User=$Object.Name;}
        }
    }
}

$return = Get-UsersInGroup "Support Office & Field Ops" 

$return | Sort-Object Group