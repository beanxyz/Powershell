get-mailbox -OrganizationalUnit "OU=2.012 NSVH,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au" -resultsize unlimited | Get-MailboxStatistics | Where-Object {$_.itemcount -eq 0}

get-mailbox -ResultSize unlimited  | Get-MailboxStatistics | Where-Object {$_.itemcount -eq 0}


get-mailbox -OrganizationalUnit "OU=2.013 IT,OU=VetPartners,DC=on,DC=vetpartners,DC=com,DC=au" -resultsize unlimited | Get-MailboxStatistics | Where-Object {$_.itemcount -eq 0}

