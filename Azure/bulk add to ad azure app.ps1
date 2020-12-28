# The AppId (a.k.a. “client ID”) of the app to assign the user to
$appId = “97fbf608-5cd2-4661-a659-6b7db7a31c2e”

# Get the service principal for the app you would like to assign the user to
$servicePrincipal = Get-AzureADServicePrincipal | Where-Object {$_.appid -eq $appId}

#Bulk add users
$users = Get-AzureADUser -top 10000
foreach ($user in $users) {
new-AzureADUserAppRoleAssignment -ObjectId $user.ObjectId -PrincipalId $user.ObjectId -ResourceId $servicePrincipal.ObjectId -Id ([Guid]::Empty)
}