<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   queryuser -server sydav01 

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
function queryuser
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $server='localhost'
    )

    Begin
    {
        write-host "Start querying users on $server" -ForegroundColor Cyan
    }
    Process
    {
        $quser = (quser /server:$server) -replace '\s{16}', ',' | ConvertFrom-Csv
        $quser 

        
    }
    End
    {
        
    }
}







