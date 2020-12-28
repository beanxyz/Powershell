


function Connect-Office365{


#$credential.Password | ConvertFrom-SecureString | set-content "c:\temp\password.txt"
    $session=Get-PSSession

    if( $session.ComputerName -eq 'outlook.office365.com' -and $session.State -eq 'opened'){

        Write-host 'PowerShell Exchange Online is connected'
    }
    else{
        $password = Get-Content "C:\temp\password.txt" | ConvertTo-SecureString 
        $credential = New-Object System.Management.Automation.PsCredential("xyli@vet.partners",$password)
        Connect-ExchangeOnline -Credential $credential -ShowProgress $true
        Connect-MsolService -Credential $credential
        Connect-AzureAD -Credential $credential

    }

}
#Get-PSSession | Remove-PSSession

Connect-Office365
#$clinics='Bexley Veterinary Hospital','Chatswood Vetfriends','Cremorne Veterinary Hospital','Epping Veterinary Clinic','Figtree Veterinary Clinic','Gladesville Veterinary Hospital','Matraville Veterinary Hospital','Parramatta veterinary hospital','Riverview Animal hospital','ryde veterinary clinic'
$clinics='Canberra Veterinary Hospital'#'Ascot Veterinary Surgery'
$master=import-excel 'C:\temp\Master list.xlsx' -WorksheetName 'Group and AD'

$result=@()
foreach($one in $clinics){
    foreach($line in $master){
    $name=$line.hospital
        if($one -eq $name){
        
            $result+=$line
        }
       
    
    }


}



$result


function Get-DistributionGroupMemberRecursive {
    <#
.SYNOPSIS
    This script will list all the members (recursively) of a DistributionGroup
.EXAMPLE
    Get-DistributionGroupMemberRecursive -Group TestDG  -Verbose
.NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadmin
#>
    [CmdletBinding()]
    PARAM ($Group)
    BEGIN {
        TRY {
            # Retrieve Group information
            Write-Verbose -Message "[BEGIN] Retrieving members of $Group"
            $GroupMembers = Get-DistributionGroupMember -Identity $Group -ErrorAction Stop -ErrorVariable ErrorBeginGetDistribMembers |
                Select-Object -Property Name, firstname, lastname, windowsliveid, @{ Label = "Group"; Expression = { $Group } }, RecipientType

        }
        CATCH {
            if ($ErrorBeginGetDistribMembers) { Write-Warning -Message "[BEGIN] Issue while retrieving members of $Group" }
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    PROCESS {
        FOREACH ($Member in $GroupMembers) {
            TRY {
                Write-Verbose -Message "[PROCESS] Member: $($member.name)"

                SWITCH ($Member.RecipientType) {
                    "MailUniversalDistributionGroup" {
                        # Member's type is Distribution Group, we need to find members of this object
                        Get-DistributionGroupMemberRecursive -Group $($Member.name) |
                            Select-Object -Property Name, firstname, lastname,windowsliveid, @{ Label = "Group"; Expression = { $($Member.name) } }, RecipientType
                        Write-Verbose -Message "[PROCESS] $($Member.name)"
                    }
                    "UserMailbox" {
                        # Member's type is User, let's just output the data
                        $Member | Select-Object -Property Name, firstname, lastname, windowsliveid, @{ Label = "Group"; Expression = { $Group } }
                    }
                    "userMailUser" {
                    
                        $Member | Select-Object -Property Name, firstname, lastname, windowsliveid, @{ Label = "Group"; Expression = { $Group } }
                    }
                }
            }
            CATCH {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
    END {
        Write-Verbose -message "[END] Done"
    }
}

Function Get-RecursiveAzureAdGroupMemberUsers{
[cmdletbinding()]
param(
   [parameter(Mandatory=$True,ValueFromPipeline=$true)]
   $AzureGroup
)
    Begin{
        If(-not(Get-AzureADCurrentSessionInfo)){Connect-AzureAD}
    }
    Process {
        Write-Verbose -Message "Enumerating $($AzureGroup.DisplayName)"
        $Members = Get-AzureADGroupMember -ObjectId $AzureGroup.ObjectId -All $true
        
        $UserMembers = $Members | Where-Object{$_.ObjectType -eq 'User'}
        If($Members | Where-Object{$_.ObjectType -eq 'Group'}){
            $UserMembers += $Members | Where-Object{$_.ObjectType -eq 'Group'} | ForEach-Object{ Get-RecursiveAzureAdGroupMemberUsers -AzureGroup $_}
        }
    }
    end {
        Return $UserMembers
    }
}



foreach($line in $result){
    #$line
    $clinicName=$line.hospital.trim()
    
    $clinicName
    $path0='C:\temp\yuantest\Employee Uploader-blank.xlsx'
    $path="C:\temp\yuantest\Employee Uploader-$clinicName.xlsx"


    $teamgroup=$line.TeamGroupName
    $hdgroup=$line.HDGroupName
    $nursegroup=$line.NurseGroupName
    $vetgroup=$line.VetsGroupName
    $pmgroup=$line.PmGroupName



    Copy-Item $path0 $path

    
    $areas=Import-Excel $path0 -WorksheetName 'Areas and Locations'

    #$users=Import-Excel 'C:\Temp\Coast Animal Health\Coast Animal Health - Email Choice.xlsx' -WorksheetName 'Coast Animal Health'


    foreach($area in $areas){
        #$name=$area.'Location Name'.trim()
        
           if($area.Country -eq ''){continue}

            if($Clinicname -eq ($area.'location Name'.trim())){
                write-host "updating now"
            
                $countryname=$area.'country'
                $areaname=$area.'area'
                $locationame=$area.'location name'
            

    
                 $hdmembers=Get-DistributionGroupMember -Identity $hdgroup | select *

                  foreach($member in $hdmembers){
                
                   $r=[pscustomobject]@{'Country Name'=$countryname;'Area Name'=$areaname;'Location Name'=$locationame;'First Name'=$member.firstname;'Middle name'='';'Last Name'=$member.lastname;'Email Address'=$member.windowsliveid;'Position (Fulltime, Part-time, Casual)'='';'Title'='';'Nickname'='';'Start Date (DD/MM/YYYY)'='';'username'=$member.windowsliveid;'Password'=''}

                   $r | Export-Excel $path -WorksheetName 'Practice Mgr Hospital Dtr (GM)' -Append
                
                }

                   $pmmembers=Get-DistributionGroupMember -Identity $pmgroup | select *

                  foreach($member in $pmmembers){
                
                   $r=[pscustomobject]@{'Country Name'=$countryname;'Area Name'=$areaname;'Location Name'=$locationame;'First Name'=$member.firstname;'Middle name'='';'Last Name'=$member.lastname;'Email Address'=$member.windowsliveid;'Position (Fulltime, Part-time, Casual)'='';'Title'='';'Nickname'='';'Start Date (DD/MM/YYYY)'='';'username'=$member.windowsliveid;'Password'=''}

                   $r | Export-Excel $path -WorksheetName 'Practice Mgr Hospital Dtr (GM)' -Append
                
                }

                $temp=@()
                $temp+=$pmmembers.WindowsLiveID
                $temp+=$hdmembers.WindowsLiveID


                
                $vetmembers=Get-DistributionGroupMember -Identity $vetgroup | select *
               
                foreach($member in $vetmembers){

                $email=$member.WindowsLiveID
                if($temp -notcontains $email){
                
                   $r=[pscustomobject]@{'Country Name'=$countryname;'Area Name'=$areaname;'Location Name'=$locationame;'First Name'=$member.firstname;'Middle name'='';'Last Name'=$member.lastname;'Email Address'=$member.windowsliveid;'Position (Fulltime, Part-time, Casual)'='';'Title'='';'Nickname'='';'Start Date (DD/MM/YYYY)'='';'username'=$member.windowsliveid;'Password'=''}

                   $r | Export-Excel $path -WorksheetName 'Veterinarian (Emp 3)' -Append
                }
                }


                $temp2=@()
                $temp2+=$temp
                $temp2+=$vetmembers

                 $nursemembers=Get-DistributionGroupMember -Identity $nursegroup | select *

                foreach($member in $nursemembers){

                $email=$member.WindowsLiveID
                if($temp2 -notcontains $email){
                
                   $r=[pscustomobject]@{'Country Name'=$countryname;'Area Name'=$areaname;'Location Name'=$locationame;'First Name'=$member.firstname;'Middle name'='';'Last Name'=$member.lastname;'Email Address'=$member.windowsliveid;'Position (Fulltime, Part-time, Casual)'='';'Title'='';'Nickname'='';'Start Date (DD/MM/YYYY)'='';'username'=$member.windowsliveid;'Password'=''}

                   $r | Export-Excel $path -WorksheetName 'Veterinary Nurse (Emp 2)' -Append
                }
                }




                  #$teammembers=Get-DistributionGroupMemberRecursive -Group $teamgroup  | select *

                  

                  $teammembers=Get-AzureADGroup -SearchString $teamgroup | get-RecursiveAzureAdGroupMemberUsers
                 
                   $teammembers
                  $all=@()
                  $all+=$pmmembers.windowsliveid
                  $all+=$hdmembers.windowsliveid
                  $all+=$vetmembers.windowsliveid
                  $all+=$nursemembers.windowsliveid

                 





                  foreach($member in $teammembers){
                  
                  $email=$member.UserPrincipalName
                  if($all -notcontains $email){

                  $firstname=$member.displayname.split("")[0]
                  $lastname=$member.displayname.split("")[1]
                
                   $r=[pscustomobject]@{'Country Name'=$countryname;'Area Name'=$areaname;'Location Name'=$locationame;'First Name'=$firstname;'Middle name'='';'Last Name'=$lastname;'Email Address'=$email;'Position (Fulltime, Part-time, Casual)'='';'Title'='';'Nickname'='';'Start Date (DD/MM/YYYY)'='';'username'=$email;'Password'=''}
                   #$r
                   $r | Export-Excel $path -WorksheetName 'Vet Clinic Team Member (Emp 1)' -Append
                }
                }



    
        }

    




}

}
