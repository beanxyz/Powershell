# The UserPrincipalName or ObjectId of the user
$userId = “aberfoylehub@vetpartners.com.au”
$userId = "amanda.gough@vetpartners.com.au"

# The AppId (a.k.a. “client ID”) of the app to assign the user to
$appId = “97fbf608-5cd2-4661-a659-6b7db7a31c2e”

# Connect to Azure AD
Connect-AzureAD -Confirm

# Get the user to be added
$user = Get-AzureADUser -ObjectId $userId

# Get the service principal for the app you would like to assign the user to
$servicePrincipal = Get-AzureADServicePrincipal | Where-Object {$_.appid -eq $appId}


# Create the app role assignment
new-AzureADUserAppRoleAssignment -ObjectId $user.ObjectId -PrincipalId $user.ObjectId -ResourceId $servicePrincipal.ObjectId -Id ([Guid]::Empty)
