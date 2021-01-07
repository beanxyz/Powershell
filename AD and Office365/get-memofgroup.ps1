$groups = Get-ADGroup -Filter * -SearchBase "OU=Email Distribution,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"
foreach ($group in $groups) {
    $Members = $group | Get-ADGroupMember | select Name
        Foreach ($member in $Members) {
            $table2 = [pscustomobject][ordered] @{
            "Group Name" = $group.name
            "Group Member" = $member.name
            }
            $table2 | Export-Csv C:\Users\xgrose\Documents\groupmembers.csv -Append -Force -NoTypeInformation

        }
}

"abc heading" | Export-Csv C:\Users\xgrose\Documents\groupmembers.csv -Append -Force -NoTypeInformation