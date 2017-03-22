function Set-NTFSInheritance {
<#    
        .SYNOPSIS
        Enable or Disable the NTFS permissions inheritance.
        .DESCRIPTION
        Enable or Disable the NTFS permissions inheritance on files and/or folders.
        .EXAMPLE
        $Folders = Get-Childitem -Path 'e:\homedirs' | Where-Object {$_.Attributes -eq 'Directory'}
        $Folders | foreach {
            $_ | Set-NTFSInheritance -Enable
        }
        .NOTES
        Author   :  Jeff Wouters
        Date     :  8th of May 2014
#> 
    [cmdletbinding(defaultparametersetname='Enable')]
    param (
        [parameter(mandatory=$true,position=0,valuefrompipeline=$true,parametersetname='Enable')]
        [parameter(mandatory=$true,position=0,valuefrompipeline=$true,parametersetname='Disable')]
        $Path,
        [parameter(mandatory=$false,parametersetname='Enable')][switch]$Enable,
        [parameter(mandatory=$false,parametersetname='Disable')][switch]$Disable
    )
    begin {
    } process {
        $ACL = get-acl $_.FullName
        switch ($PSCmdlet.ParameterSetName) {
            'Enable' {
                $ACL.SetAccessRuleProtection($false,$false)
            }
            'Disable' {
                $ACL.SetAccessRuleProtection($true,$true)
            }
        }
        try {
            $ACL | Set-Acl -Passthru
        } catch {
            $_.Exception
        }
    } end {
    }
}