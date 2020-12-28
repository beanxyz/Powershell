#This is a script to add members to distribution groups. It was primarily used when setting up the groups for the hospitals
#See here for how the groups are arranged: https://vetpartners.atlassian.net/wiki/spaces/ID/pages/439255050/Email+Groups+-+Tree+Chart
#This was used to add either existing groups or import a list of groups into the higher tier groups.

# I manually change these groups - it might be possible to automate but I havent tried yet.
$identityold = "WA - Vets"
$identitynew = "WA - 1 - Vets"

#Take old groups and get the members and add to the new groups - works where the members are groups - prob not useful bec memberships have changed
$members = Get-DistributionGroupMember -Identity $identityold
foreach ($member in $members) {
Add-DistributionGroupMember -Identity $identitynew -Member $member.Name
}

#Take old groups and get the members and add to the new groups - works where the members are users
$members = Get-ADGroupMember -Identity $identityold | select samaccountname | %{Get-ADUser $_.samaccountname -Properties mail} 
foreach ($member in $members) {
Add-DistributionGroupMember -Identity $identitynew -Member $member.mail
}

#Take old groups and get the members and add to the new groups - works where the members are groups - prob not useful bec memberships have changed
$members = Get-ADGroupMember -Identity $identityold
foreach ($member in $members) {
$newgroup = ($member.Name.Split("{-}")[1]).substring(1) + " - " + ($member.Name.Split("{-}")[0]).trimend(" ")
Add-DistributionGroupMember -Identity $identitynew -Member $newgroup
}



#The next section is for when we have a list of clinics for each rom - they are put into a text file in the format "NAME - "
#The below is for when the location has a number associated with it. If it doesn't then it will need to be reformatted.
#You need to run the function Add-Members for the below commands to work.

#Variables
$statelist = get-content C:\scripts\nz3.txt
$location = "NZ - "
$locationpad = " - "
$locationnumber = 3

#Begin Adding the members to the groups
$Job = "Nurses"
$identitynew = $location + $locationnumber + $locationpad + $job
Add-Members
$job = "Vets"
$identitynew = $location + $locationnumber + $locationpad + $job
Add-Members
$job = "Hospital Director"
$identitynew = $location + $locationnumber + $locationpad + $job + "s"
Add-Members
$job = "Practice Manager"
$identitynew = $location + $locationnumber + $locationpad + $job + "s"
Add-Members
$job = "Team"
$identitynew = $location + $locationnumber + $locationpad + $job + "s"
Add-Members

#Note - this does not add members for Hospitals or ROMs - please do this manually.

function Add-Members {
foreach ($local in $statelist)
{$member = $local + $Job
Add-DistributionGroupMember -Identity $identitynew -Member $member
}
}


#whats the email address for GL??
#who at Shirley gets the email?
# NSW - 1 - Nurses - cant add eastside and Syd uni - double check
#no winston hills?
#no 4paws
#no pets in the city
# no allison, eng, syl
# no animal doctors
# no erina heights
#no herriot house
#no riverbank
#no vet happiness
#engadine, kialla, Riverbank, vet happiness, new norfolk, shepparton, south eastern animal hospital, canberra x 3
#victor, riverport, adl vet hospitals,
#bayfair vets, 


#no contact info for vetcare bethlehem and cherrywood