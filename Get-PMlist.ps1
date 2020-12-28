function Get-DistributionGroupMemberRecursive
{
<#
.SYNOPSIS
    This script will list all the members (recursively) of a DistributionGroup
.EXAMPLE
    Get-DistributionGroupMemberRecursive -Group TestDG  -Verbose
.NOTES
    Francois-Xavier Cat
    www.lazywinadmin.com
    @lazywinadm
#>
    [CmdletBinding()]
    PARAM ($Group)
    BEGIN
    {
        TRY
        {
            # Retrieve Group information
            Write-Verbose -Message "[BEGIN] Retrieving members of $Group"
            $GroupMembers = Get-DistributionGroupMember -Identity $Group -ErrorAction Stop -ErrorVariable ErrorBeginGetDistribMembers |
            Select-object -Property Name, PrimarySMTPAddress, firstname, lastname, @{ Label = "Group"; Expression = { $Group } }, RecipientType

        }
        CATCH
        {
            Write-Warning -Message "[BEGIN] Something wrong happened"
            if ($ErrorBeginGetDistribMembers) { Write-Warning -Message "[BEGIN] Issue while retrieving members of $Group" }
            Write-Warning -Message $Error[0].Exception.Message
        }
    }
    PROCESS
    {
        FOREACH ($Member in $GroupMembers)
        {
            TRY
            {
                Write-verbose "[PROCESS] Member: $($member.name)"

                SWITCH ($Member.RecipientType)
                {
                    "MailUniversalDistributionGroup" {
                        # Member's type is Distribution Group, we need to find members of this object
                          $group=$Member.name
                        Get-DistributionGroupMemberRecursive -Group $($Member.name) 
                        #|
                        #    Select-Object -Property Name, PrimarySMTPAddress, @{ Label = "Group"; Expression = { $member.name } },RecipientType
                        Write-Verbose -Message "[PROCESS] $($Member.name)"
                      
                        
                       # Write-Host $group -ForegroundColor Yellow
                    }
                    "UserMailbox" {
                        # Member's type is User, let's just output the data
                       $gg=get-group $group; $dn=$gg.distinguishedname;
                      
                       $area=Get-Group -Filter "Members -eq '$dn'" 

                       foreach($one in $area){
                       
                        if($one.DisplayName -like "*practice*"){
                            
                           $areaname=$one.DisplayName
                           break  
                        
                        }
                       }


                       #$areaname
                       

                       $dn2=get-group $areaname | select -ExpandProperty distinguishedname

                       #$dn2
                       $country=get-group -filter "Members -eq '$dn2'"

                       #foreach($one in $country){
                       
                        #if($one.DisplayName -like "*Practice*"){
                            
                           $countryname=$country[0].displayname
                         #  break
 
                        #}
                       #}


                       #$countryname

                       $dn3=get-group $countryname | select -ExpandProperty distinguishedname
                       $top=get-group -Filter "Members -eq '$dn3'"
                       $topname=$top[0].displayname



                        $Member | Select-object -Property Name, firstName, lastname, PrimarySMTPAddress, @{ Label = "Clinic group"; Expression = { $group } }, @{ label="Area group";e={ $areaname }}, @{l='Country Group';e={$countryname}},@{n='Top Group';e={$topname}}
                    }
                }
            }
            CATCH
            {
                Write-Warning -Message "[PROCESS] Something wrong happened"
                Write-Warning -Message $Error[0].Exception.Message
            }
        }
    }
    END
    {
        Write-Verbose -message "[END] Done"
    }
}


#Connect to Office365

$session=Get-PSSession

if($session.ComputerName -like "outlook.office365*"){
    Write-Host "Outlook.Office365.com session is connected" -ForegroundColor Cyan
}
else{
    #MFA Authentication#
    #Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch "_none_"}|select -First 1)
    #$EXOSession = New-ExoPSSession
    #Import-PSSession $EXOSession

    #


    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session
    Connect-MsolService

}


Get-DistributionGroupMemberRecursive -Group "Practice Managers - all" | tee -Variable result



$result

#$result=Import-Excel C:\temp\pmnewlist.xlsx


$r2=@()

$contents=import-csv 'C:\temp\master list.csv'


foreach($line in $result){

$area=$line.'area group'



$newarea=$area.Split('-')[2].trim()



$clinc=$line.'clinic group'
$newclinic=$clinc.Split('-')[0].trim()


$country=$line.'country group'
$newcountry=$country.Split('-')[1].trim()


$flag=0

foreach($one in $contents){
    $shortname=$one.shortname.Trim()
    $realname=$one.realname.Trim()
    $code=$one.'dimension code'
   
    if($shortname -eq $newclinic){
        $newclinic=$realname
        $flag=1

        break
    }

}




$temp=[pscustomobject]@{Country=$newcountry;Area=$newarea;Clinic=$newclinic;Firstname=$line.FirstName;MiddleName="";Lastname=$line.LastName; Name=$line.Name; Email=$line.PrimarySmtpAddress; Position="";Title="";Nickname=""; StartDate=""; Username=$line.PrimarySmtpAddress; Code=$code}

$r2+=$temp

}

$r2 | Out-GridView

$r2 | Export-Excel 'C:\temp\PMUserlist.xlsx'