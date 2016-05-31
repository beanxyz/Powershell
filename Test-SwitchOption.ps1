function Get-Bios {

<#
.Synopsis
   Get-Bios Test
.DESCRIPTION
   Long description
.EXAMPLE
   "localhost","sydit01" | get-bios
.EXAMPLE
    get-bios -computername "localhost","sydittest","notexist" -verbose -error
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>



[CmdletBinding()]
param( 
 [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                     ValueFromPipeline=$true,
                   Position=0)]
                   [string[]]
        $Computername,

        # Param2 help description
        [string]
        $log="c:\temp\logtest.txt",
        [switch]$error
        
        )


begin{}


process{

try{
    write-verbose "Quering $_ Now"
    Invoke-Command -ComputerName $Computername -ScriptBlock {Get-WmiObject -Class win32_bios} -ErrorAction Stop -ErrorVariable ee

}catch{
    $msg="Failed getting system information from $_. $($_.Exception.Message)"
            Write-Error $msg 

    if($error){
  
    $ee | out-file $log
    }

}

}


end{

}





}