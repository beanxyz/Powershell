#enable NTFS inheritance permission function

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


function ChangePermission {
[cmdletbinding(defaultparametersetname='Enable')]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $path,
        [Parameter(Mandatory=$true)]
        [string]
        $group
    )

   #Step 1: take over ownership

    takeown.exe  /f $path /r /d Y


    #Step 2:  enable inheritance for all subfolders

    $Folders = Get-Childitem -Path $path -Recurse
    $Folders | foreach {
        $_ | Set-NTFSInheritance -Enable
    }

    #Step3:   setup NTFS Modify permission from the parent folder
    $perm2=':(OI)(CI)(M)'
    write-host $path -ForegroundColor Cyan

    icacls $path /grant "$($group)$perm2"




}


$parent="\\syd02\Creative TRACK\CLIENT FOLDERS\WESTPAC"

Get-ChildItem  $parent | foreach {

$_.fullname

ChangePermission -path $_.FullName -group "Sydney Track Creative" 

}


