#Script by Geoff Rose
#2 June 2017
#This will count the number of users in the Team - All group

(get-aduser -filter {memberof -recursivematch "CN=Team - ALL,OU=Email Distribution,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"}).count