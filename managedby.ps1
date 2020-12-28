invoke-command -ComputerName aws-svr-rds-05.on.vetpartners.com.au -ScriptBlock {Get-RDLicenseConfiguration}
Set-ADGroup -Identity "chase testing" -ManagedBy "geoff.rose","chase.lu"
Set-ADGroup -Identity "chase testing" -Clear msExchCoManagedByLink
Set-ADGroup -Identity "chase testing" -Clear managedby
set-adgroup -Identity "Chase testing" -Add @{msExchCoManagedByLink="CN=Gareth Rossiter,OU=2.013 IT,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"}


set-adgroup -Identity "Chase testing" -Add @{managedby="CN=Geoff Rose,OU=2.013 IT,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au";msExchCoManagedByLink="CN=Chase Lu,OU=2.013 IT,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au"}