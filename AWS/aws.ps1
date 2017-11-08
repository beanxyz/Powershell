#Install and import module
import-module AWSPowerShell
get-module AWSPowershell

#Create account from IAM, download user accesskey and secretkey
#Generate, list and delete profile
Set-AWSCredentials -AccessKey AKIAJADKXIQBE5SXVHRQ -SecretKey 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 -StoreAs myprofile
Get-AWSCredentials -ListProfiles
Clear-AWSCredentials -ProfileName myprofile

#Connect to aws 
Get-AWSRegion
Initialize-AWSDefaults -ProfileName myprofile -Region ap-southeast-2
Get-EC2Instance 
Get-DefaultAWSRegion


#How to find related command

Get-AWSCmdletName -ApiOperation UpdateRule
Get-AWSCmdletName DescribeInstances 
Get-AWSCmdletName –ApiOperation SecurityGroup -MatchWithRegex
Get-AWSCmdletName –ApiOperation EC2 -MatchWithRegex
Get-AWSCmdletName –ApiOperation SecurityGroup –MatchWithRegex –Service EC2
Get-Command -Module AWSPowerShell | measure
Get-Command -Module AWSPowerShell | Select-String region

Get-EC2Instance | Stop-EC2Instance
Get-EC2Instance | Start-EC2Instance


#EC2 commands
#Create Key Pair
get-command *ec2* -Module awspowershell | measure

$Keypair=New-EC2KeyPair -KeyName mykeypair
$Keypair | gm
$Keypair | fl
$Keypair.KeyMaterial | Out-File -Encoding ascii mykeypair.pem

get-ec2keypair

#Create Security Group and rule

New-EC2SecurityGroup -GroupName MyTestSecurityGroup -Description "EC2-Classic from PowerShell"
Get-EC2SecurityGroup -GroupName MyTestSecurityGroup 

$ip1=new-object Amazon.EC2.Model.IpPermission
$ip1.IpProtocol="tcp"
$ip1.FromPort=22
$ip1.ToPort="22"
$ip1.IpRange="0.0.0.0/0"
$ip2=New-Object Amazon.EC2.Model.IpPermission
$ip2.IpProtocol="tcp"
$ip2.FromPort=3389
$ip2.ToPort=3389
$ip2.IpRange.Add("0.0.0.0/0")

Grant-EC2SecurityGroupIngress -GroupName MyTestSecurityGroup -IpPermission @($ip1,$ip2)
Revoke-EC2SecurityGroupIngress -GroupName MyTestSecurityGroup -IpPermission @($ip1,$ip2)

#Find an Image
Get-EC2Image -ImageId ami-dc361ebf

Get-EC2Image -Owner amazon,self
$platform_values = New-Object 'collections.generic.list[string]'
$platform_values.add("windows")
$filter_platform = New-Object Amazon.EC2.Model.Filter -Property @{Name = "description"; Values = $platform_values}
Get-EC2Image -Owner amazon, self -Filter $filter_platform


Get-EC2ImageByName
Get-EC2ImageByName -Name *ami*

#Create EC2 instance

New-EC2Instance -ImageId ami-dc361ebf -MinCount 1 -MaxCount 1 -KeyName mykeypair -SecurityGroup MyTestSecurityGroup -InstanceType t2.micro
Get-EC2Instance -Filter (new-object Amazon.EC2.Model.Filter -Property @{Name="reservation-id";values="r-069ce2e012d6adf7e"}) | select -ExpandProperty instances

Remove-EC2Instance -InstanceId i-0bb1bc83486b933b1


#S3 
New-S3Bucket -BucketName yliscript -Region ap-southeast-2 
Get-S3Bucket
Remove-S3Bucket -BucketName yliscript

Write-S3BucketWebsite -BucketName yliscript -WebsiteConfiguration_IndexDocumentSuffix index.html -WebsiteConfiguration_ErrorDocument error.html

$index_html = @"
 <html>
  <body>
    <p>
     Hello, World!
   </p>
  </body>
</html>
"@
$index_html | Set-Content index.html

$error_html = @"
<html>
 <body>
 <p>
   This is an error page.
  </p>
 </body>
 </html>
"@

$error_html | Set-Content error.html

foreach ($f in "index.html", "error.html") {
 Write-S3Object -BucketName yliscript -File $f -Key $f -CannedACLName public-read
}

Get-S3BucketWebsite -BucketName yliscript

Remove-S3Bucket -BucketName yliscript -DeleteBucketContent


write-s3object yuanpicture -key myobject.txt -content "file content"

$x = @" 
line 1 
line 2 
line 3 
"@ 
 
write-s3object yuanpicture -key myobject.txt -content $x
get-s3object yuanpicture
Read-S3Object yuanpicture -key myobject.txt -file test.txt

set-s3acl yuanpicture -Key myobject.txt -PublicReadOnly

Get-S3Object yuanpicture -Key myobject.txt 

$url="https://s3-ap-southeast-2.amazonaws.com/yuanpicture/myobject.txt"

start-process -FilePath $url

Read-S3Object -BucketName yuanpicture -Key myobject.txt -File test.txt



#VPC
#Create new VPC 

New-EC2Vpc -CidrBlock 10.2.0.0/16 

#Create subnet in the new VPC
$vpcid=get-ec2vpc | Where-Object {$_.Cidrblock -eq "10.2.0.0/16"} | select -ExpandProperty vpcid
New-EC2Subnet -CidrBlock 10.2.1.0/24 -VpcId $vpcid


$subid=Get-EC2Subnet | Where-Object{$_.CidrBlock -eq "10.2.1.0/24"} | select -ExpandProperty SubnetId

#Add a Name Tag to the Subnet
$tag=new-object Amazon.EC2.Model.Tag -Property @{key="Name";value="Sydney"}
New-EC2Tag -Resource $subid -Tag $tag
Get-EC2Subnet 


#delete subnet and VPC
#Remove-EC2Subnet -SubnetId 
#Remove-EC2Vpc -VpcId vpc-0bd5fd6e 
http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Route_Tables.html#route-tables-api-cli

#Create Internet Gateway, if there is no free IGW, create a new one and attach to VPC
if((Get-EC2InternetGateway | Where-Object {$_.Attachments[0] -eq $null} | measure).count -eq 0){
    New-EC2InternetGateway 
}
$igwid=Get-EC2InternetGateway | Where-Object {$_.Attachments[0] -eq $null} | select -ExpandProperty internetGateWayId

new-EC2tag -Resource $igwid -Tag $tag
Get-EC2InternetGateway $igwid|Add-EC2InternetGateway -VpcId $vpcid
Dismount-EC2InternetGateway -InternetGatewayId igw-08d9476d -VpcId $vpcid

#RouteTable

New-EC2RouteTable -VpcId $vpcid 
$routetable=Get-EC2RouteTable | Where-Object {$_.VpcId -eq $vpcid}

#Add new Route
New-EC2Route -DestinationCidrBlock "0.0.0.0/0" -GatewayId $igwid -RouteTableId $routetable.RouteTableId 

Get-EC2Subnet -SubnetId $subid | gm

Register-EC2RouteTable -RouteTableId $routetable.RouteTableId -SubnetId $subid

 
#ELB

#Images

$instnaces=Get-EC2Instance
foreach ($i in $instnaces){

    if($i.instances.tags.value -eq “Linux”){
        $instanceId=$i.instances.instanceid
    
    }
}



New-EC2Image -Description TemplateTest -Name Template -InstanceId $instanceId
Get-EC2Image -Owner self | Unregister-EC2Image -PassThru


#Create ELB
$HTTPListener = New-Object -TypeName ‘Amazon.ElasticLoadBalancing.Model.Listener’
$HTTPListener.Protocol = ‘http’
$HTTPListener.InstancePort = 80
$HTTPListener.LoadBalancerPort = 80

$groupid=(Get-EC2SecurityGroup| where-object {$_.GroupName -eq "NewSG"}).GroupId


$subnet1=(Get-EC2Subnet | Where-Object {$_.CidrBlock -eq "10.2.1.0/24"}).SubnetId
$subnet2=(Get-EC2Subnet | Where-Object {$_.CidrBlock -eq "10.2.2.0/24"}).SubnetId

New-ELBLoadBalancer -LoadBalancerName "MyLoadBalance" -Listener $HTTPListener -SecurityGroup $groupid -Subnet @($subnet1,$subnet2) 


$instnaces=Get-EC2Instance
foreach ($i in $instnaces){

    if($i.instances.tags.value -eq “test”){
        $instance2Id=$i.instances.instanceid
    
    }
}



Register-ELBInstanceWithLoadBalancer -LoadBalancerName "MyLoadBalance" -Instance @($instance2Id) 


#Create Auto Scaling Policy and Group

Get-ASAutoScalingGroup



New-ASLaunchConfiguration -ImageId (Get-EC2Image -Owner self).imageid -LaunchConfigurationName "My-launchconfigurationfile" -InstanceType "t2.micro" -SecurityGroup $groupid

New-ASAutoScalingGroup -AutoScalingGroupName "my-asg" -LaunchConfigurationName "My-launchconfigurationfile" -MinSize 1 -MaxSize 3 -LoadBalancerName "MyLoadBalance" -AvailabilityZone @("ap-southeast-2c") `
-VPCZoneIdentifier $subnet1





$stepadjustment=New-Object Amazon.AutoScaling.Model.StepAdjustment 
$stepadjustment.MetricIntervalLowerBound=20
$stepadjustment.ScalingAdjustment=-1


Write-ASScalingPolicy -AutoScalingGroupName my-asg -AdjustmentType "ChangeInCapacity" -PolicyName "myScaleInPolicy1" -PolicyType "StepScaling" -StepAdjustment $stepadjustment

Write-CWMetricAlarm -ActionsEnabled $true -Alarmname "testonly" -AlarmAction {arn:aws:autoscaling:ap-southeast-2:503646143282:scalingPolicy:ab3c2240-7128-4250-be8b-2e1671fd66ef:autoScalingGroupName/my-asg:policyName/myScaleInPolicy1} -Namespace "AWS/EC2" -Period 300 -Statistic "Average" -MetricName "CPUUtlilization" `
-ComparisonOperator "LessThanOrEqualToThreshold" -Threshold 60 -EvaluationPeriod 1




http://docs.aws.amazon.com/sdkfornet/v3/apidocs/index.html?page=AutoScaling/TAutoScalingStepAdjustment.html&tocid=Amazon_AutoScaling_Model_StepAdjustment


Remove-ASAutoScalingGroup -AutoScalingGroupName "my-asg" 


#IAM

Get-IAMGroup -GroupName admins | select -ExpandProperty users

New-IAMGroup  -GroupName "powerUsers" 

New-IAMUser -UserName "myNewUser" 

Add-IAMUserToGroup -UserName myNewUser -GroupName powerUsers 

 $policyDoc = @"
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"NotAction": "iam:*",
"Resource": "*"
}
]
}
"@

Write-IAMUserPolicy -UserName myNewUser -PolicyName "PowerUserAccess-myNewUser" -PolicyDocument $policyDoc 
get-iamuserpolicy -UserName mynewuser -PolicyName "PowerUserAccess-myNewUser"

New-IAMLoginProfile -UserName myNewUser -Password "&!123!&"

New-IAMAccessKey -UserName myNewUser 

#Policy element 
http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements.html#Version

#IAM Role

$policy=@"
{
  "Version": "2012-10-17",
  "Statement": [
  
      {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": ["sts:AssumeRole"]
    }
    ]

}
"@

new-iamrole -RoleName "newec2-s3" -AssumeRolePolicyDocument $policy



 $policy2 = @"
{
"Version": "2012-10-17",
"Statement": [
    {
    "Effect": "Allow",
    "NotAction": "s3:*",
    "Resource": "*"
    }
]
}
"@
 
 Write-IAMRolePolicy -PolicyDocument $policy2 -RoleName "newec2-s3" -PolicyName "allows3"

 # Create a MariaDB

 New-RDSDBInstance -AllocatedStorage 5 -DBInstanceIdentifier "testdb1" -MasterUsername "beanxyz" -MasterUserPassword "Password" `
 -AutoMinorVersionUpgrade $true -AvailabilityZone "ap-southeast-2c" -CopyTagsToSnapshot $false -DBInstanceClass "db.t2.small" `
 -DBName "testdb1" -Engine "mariadb" 


 Get-RDSDBInstance
 Remove-RDSDBInstance -DBInstanceIdentifier "testdb1" -SkipFinalSnapshot $true


 get-ec2instance | select -ExpandProperty instances 

 $cidrblock= (Get-EC2SecurityGroup -GroupName default |get-ec2vpc).CidrBlock


$ip1=new-object Amazon.EC2.Model.IpPermission
$ip1.IpProtocol="TCP"
$ip1.FromPort="3306"
$ip1.ToPort="3306"
$ip1.IpRange=$cidrblock


Grant-EC2SecurityGroupIngress -GroupName default -IpPermission @($ip1)


#Create CDN 

Write-S3Object -BucketName yuanpicture -Key "1.jpg" -File "C:\Users\yli\OneDrive\Pictures\2010-09-28 001\1.jpg"
set-s3acl -BucketName yuanpicture -Key "1.jpg" -PublicReadOnly
get-s3object -BucketName yuanpicture -Key 1.jpg


Get-CFDistributions | select -ExpandProperty items
Get-CFDistributionConfig -Id E1NAMOSAWJLM1L

Write-S3Object -BucketName yuanpicture -Folder "C:\temp\reports " -KeyPrefix "report" -Recurse

$origin = New-Object Amazon.CloudFront.Model.Origin
$origin.DomainName="yuanpicture.s3.amazonaws.com"
$origin.id="S3-yuanpicture"
$origin.S3OriginConfig = New-Object Amazon.CloudFront.Model.S3OriginConfig
$origin.S3OriginConfig.OriginAccessIdentity = ""
New-CFDistribution `
      -DistributionConfig_Enabled $true `
      -DistributionConfig_Comment "Test distribution" `
      -Origins_Item $origin `
      -Origins_Quantity 1 `
      -DistributionConfig_CallerReference Client1 `
      -DefaultCacheBehavior_TargetOriginId $origin.Id `
      -ForwardedValues_QueryString $true `
      -Cookies_Forward all `
      -WhitelistedNames_Quantity 0 `
      -TrustedSigners_Enabled $false `
      -TrustedSigners_Quantity 0 `
      -DefaultCacheBehavior_ViewerProtocolPolicy allow-all `
      -DefaultCacheBehavior_MinTTL 1000 `
      -DistributionConfig_PriceClass "PriceClass_All" `
      -CacheBehaviors_Quantity 0 `
      -Aliases_Quantity 1 `
      -Aliases_Item "test.beanxyz.com"



#Remove-CFDistribution -Id E15FE0UTDS9AQ6 -IfMatch 


Get-CFDistribution -Id E1NAMOSAWJLM1L | Remove-CFDistribution -IfMatch 1468457736663




Update-CFDistribution `
      -id E15FE0UTDS9AQ6 `
      `
      -DistributionConfig_Enabled $true `
      -DistributionConfig_Comment "Test distribution" `
      -Origins_Item $origin `
      -Origins_Quantity 1 `
      -DistributionConfig_CallerReference Client1 `
      -DefaultCacheBehavior_TargetOriginId $origin.Id `
      -ForwardedValues_QueryString $true `
      -Cookies_Forward all `
      -WhitelistedNames_Quantity 0 `
      -TrustedSigners_Enabled $false `
      -TrustedSigners_Quantity 0 `
      -DefaultCacheBehavior_ViewerProtocolPolicy allow-all `
      -DefaultCacheBehavior_MinTTL 1000 `
      -DistributionConfig_PriceClass "PriceClass_All" `
      -IfMatch
    




apt-get install -y mysql-client libmysqlclient15-dev apache2 apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libapache2-mod-php5 php5 php5-common php5-curl php5-dev php5-gd php5-idn php-pear python-pip && pip install awscli

aws s3 cp --recursive s3://yliwordpress/wordpress /var/www/wordpress/
aws s3 cp s3://yliwordpress/wordpress_vhosts /etc/apache2/sites-enabled/

aws s3 cp --recursive /var/www/wordpress s3://yliwordpress/wordpress



#Get RDS Endpoint
$adddress=(Get-RDSDBInstance | Where-Object {$_.DBName -eq "wordpress"} | select -ExpandProperty Endpoint).address



$content=get-content C:\Users\yli\Downloads\wordpress-4.5.3\wordpress\wp-config-sample.php
$content.Replace("define('DB_NAME', 'database_name_here')","define('DB_NAME', 'wordpress')").Replace("define('DB_USER', 'username_here')","define('DB_USER', 'wordpress')").Replace("define('DB_PASSWORD', 'password_here')","define('DB_PASSWORD', 'wordpress')").Replace("define('DB_HOST', 'localhost')","define('DB_HOST', '$adddress')") |set-content C:\Users\yli\Downloads\wordpress-4.5.3\wordpress\wp-config.php



#创建高可用博客逻辑　　

#Prepare Network
1.创建EC2-S3的Role
2.创建VPC网络
3.创建两个子网，位于不同AZ
4.创建Internet网关
5.配置路由表
6.配置SecurityGroup和端口 SSH,HTTP，ICMP


#MariaDB HA
7.创建RDS MultipleZone


#Create AMI Image
8.创建EC2实例
9.安装LAMP，WordPress
10.配置Vhost文档，wp-content.conf文档，保存在S3中
11.拷贝对应的文档，重启apache服务
12.配置S3和CloudFront
13.S3同步到WordPress，然后设置crontab，rewrite替换本地地址 
14.配置AMI镜像

#Create ELB and Auto Scaling
15.配置ELB
16.配置 Launch Configuration- UserData（Bootstrap）
17.配置 Auto Scaling Group
18.配置DNS 域名指向ELB的地址





