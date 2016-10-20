<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
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
function Get-DeliveryInfo
{
    [CmdletBinding()]
   
    Param
    (
        # Param1 help description
        
        [string]
        $user,
        [string]$path="c:\users\yli\Documents\records\xlsx\*.xlsx",
        [string]$address="*"
     )

     begin{}

     process{
     
     
     $result=Get-ChildItem $path -Recurse | Import-Excel|Where-Object {($_.姓名 -like "*$user*") -and ($_.地址 -like "*$address*")}
     
     
     
     }

     end{
     
     $result 
     }

}