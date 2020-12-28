#Script by Geoff Rose
#2 June 2017
#This will add all the users in the OUs to the Team groups in each OU.

#Starting OU
$OU = "OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"

#Some OUs were already done so they can be skipped. Also the first one must be skipped as its the top level
$AllOUs = Get-ADOrganizationalUnit -SearchBase $OU -filter * | select -Skip 12

#Begin loop through all sub OUs

foreach ($OUsub in $AllOUs)
{
    #get the team name for the current OU
    $teamgroup = (get-adgroup -SearchBase $OUsub -Filter {Name -like "*Team*"}).name
        #Get an array of all the users in the OU
        $users = Get-ADUser -SearchBase $OUsub -Filter *
            # Loop through each user and add them to the Team group
            foreach ($user in $users)
            {
            #write the user's name so we know who is being processed incase there are errors
            write-host $user
            [string]$member = $user.SamAccountName
            Add-ADGroupMember -Members $member -Identity $teamgroup 
            }
}




