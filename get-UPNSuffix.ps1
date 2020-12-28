if (-not (Get-Module ActiveDirectory)){            
  Import-Module ActiveDirectory            
}            
            
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()            
$domaindn = ($domain.GetDirectoryEntry()).distinguishedName            
            
$upnDN = "cn=Partitions,cn=Configuration,$domaindn"            
            
"`nMicrosoft"            
Get-ADObject -Identity $upnDN -Properties upnsuffixes | select -ExpandProperty upnsuffixes | sort           
            
