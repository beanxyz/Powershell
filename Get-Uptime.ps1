function Get-Uptime{
<#
.Synopsis
   Get machine uptime from remtoe machine
.DESCRIPTION
   Get machine from remtoe machine
.EXAMPLE
   Get-Uptime sydav01,sydit01
   This will get the up time of server sydav01 and sydit01
.INPUTS
   String name of server names
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   This is a test function
.COMPONENT
   The component this cmdlet belongs to Yuan Li
.ROLE
   The role this cmdlet belongs to Yuan Li
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>



    Param
    (
        # Param1 help description
        [Parameter(
                   ValueFromPipelineByPropertyName=$true,  
                   Position=1)
                   ][string[]]$ComputerNames=$env:COMPUTERNAME

   
    )

#

$pp=$null
$pp=[ordered]@{'Computername'=$null;'StartTime'=$null;'Uptime(Days)'=$null;'Status'=$null;'MightNeedPatched'=$null}
$obj=New-Object -TypeName psobject -property $pp


$result=@()




foreach ($b in $ComputerNames){


if (Test-Connection $b -Count 1 -Quiet){


$os=Get-CimInstance -ComputerName $b -ClassName win32_operatingsystem 


$objtemp=$obj |select *
$objtemp.Computername=$b

$objtemp.starttime=$os.LastBootUpTime

if($os.LastBootUpTime -ne $null){

$objtemp.status="Online"

}
else
{
$objtemp.status="Error"
}


$objtemp.'Uptime(Days)'=($os.LocalDateTime-$os.LastBootUpTime).Days

if ($objtemp.'Uptime(Days)' -gt 30)
{
$objtemp.MightNeedPatched=$True
}
else
{$objtemp.MightNeedPatched=$False}


$result+=$objtemp

}
else{
$warning= "Server "+$b+" is Offline!"
$warning | Write-Warning

$objtemp=$obj |select *
$objtemp.Computername=$b
$objtemp.status="Offline"

$result+=$objtemp



}

}


$result | sort Status | ft
}

$names=get-adcomputer -Filter {operatingsystem -like "*2012*"} 
Get-Uptime -ComputerNames $names.name