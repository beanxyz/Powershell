<#
.Synopsis
   This is a function to create SG in AWS and populate some predefined rules
.DESCRIPTION
   Long description
.EXAMPLE
   Create-SG -$sgname 'test1' -iprange '192.168.1.0/24'
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Create-SG
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
        $SGname='sample',

        # Param2 help description
        [string]
        $IPrange='10.0.0.0/16'

    )

    Begin
    {
    }
    Process
    {

     
        $groupid=$NULL

        While ($groupid -eq $NULL){

    

            if($groupid -eq $null){
    
                $NewGroup = @{
                    GroupName   = $SGname
                    Description = "Security Group to allow RDP access to Vet RDS"
                    VpcId             = 'vpc-fc6bec98'
                    Force             = $true
                }
                New-EC2SecurityGroup @NewGroup 

                $groupid=Get-EC2SecurityGroup | Where-Object {$_.Groupname -eq $SGname } | select -ExpandProperty groupid

                $nameTag = New-Object Amazon.EC2.Model.Tag
                $nameTag.Key = "Name"
                $nameTag.Value = $SGname
                New-EC2Tag -Resource $groupid -Tag $nameTag
        
         
            }

        }



        #Allow 3389 for OpenVPN SG

        $ug = New-Object Amazon.EC2.Model.UserIdGroupPair
        $ug.GroupId = "sg-20803a59"
        $ug.UserId = "386115804199"

        Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermission @{
            IpProtocol="tcp"; FromPort="3389"; ToPort="3389"; UserIdGroupPairs=$ug
  
        } 



        #Allow all Traffic from SG Connection Broker


        $ug = New-Object Amazon.EC2.Model.UserIdGroupPair
        $ug.GroupId = "sg-bf463bd8"
        $ug.UserId = "386115804199"

        Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermission @{
            IpProtocol="-1"; FromPort="0"; ToPort="65535";UserIdGroupPairs=$ug
  
        }

        #Allow all Traffic from SG Domain Contorller

        $ug = New-Object Amazon.EC2.Model.UserIdGroupPair
        $ug.GroupId = "sg-fda3ce9a"
        $ug.UserId = "386115804199"

        Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermission @{
            IpProtocol="-1"; FromPort="0"; ToPort="65535";UserIdGroupPairs=$ug
  
        }

        #Allow all Traffic from IT

        Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermission @{
            IpProtocol="-1"; FromPort="0"; ToPort="65535";IpRanges='10.1.2.0/24'
  
        }

        #Allow all traffic from PRTG

        Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermission @{
            IpProtocol="-1"; FromPort="0"; ToPort="65535";IpRanges='172.16.61.30/32'
  
        }

        #Allow all traffic from Vet IP range
        Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermission @{
            IpProtocol="-1"; FromPort="0"; ToPort="65535";IpRanges=$IPrange
  
        }


        #Allow port 4040 from all over the world
        Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermission @{
            IpProtocol="tcp"; FromPort="4040"; ToPort="4040";IpRanges='0.0.0.0/24'
  
        }

          #Allow port 3389 from site access server
        Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermission @{
            IpProtocol="tcp"; FromPort="3389"; ToPort="3389";IpRanges='172.16.1.139/32'
  
        }


    }
    End
    {
    }
}


<#
Create-SG -SGname 'Guildford' -IPrange '10.2.4.0/24'
Create-SG -SGname 'Balgownie' -IPrange '10.2.22.0/24'
Create-SG -SGname 'MountainCreek' -IPrange '10.4.8.0/24'
Create-SG -SGname 'Lincoln' -IPrange '10.5.8.0/24'
Create-SG -SGname 'Figtree' -IPrange '10.2.7.0/24'
Create-SG -SGname 'CoastAnimalHealth' -IPrange '10.2.26.0/24'
Create-SG -SGname 'JamesStreet' -IPrange '10.4.1.0/24'
Create-SG -SGname 'Ourimbah' -IPrange '10.2.17.0/24'
Create-SG -SGname 'BayfairPapamoa' -IPrange '10.64.5.0/24'
Create-SG -SGname 'BayfairPapamoa' -IPrange '10.64.6.0/24'
Create-SG -SGname 'Salisbury' -IPrange '10.4.5.0/24'

#>


create-sg -SGname 'test1111' -IPrange '10.234.232.0/24'