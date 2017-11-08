#创建高可用博客逻辑　　

#Prepare Network
#1.创建EC2-S3的Role

#IAM Role
$policy1=@"
{
  "Version": "2012-10-17",
  "Statement": [
   
      {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
    ]
}
"@
New-IAMRole -RoleName "EC2-S3" -AssumeRolePolicyDocument $policy1

$policy2 = @"
{
"Version": "2012-10-17",
"Statement": [
    {
    "Effect": "Allow",
    "Action": "s3:*",
    "Resource": "*"
    }
]
}
"@
  
 Write-IAMRolePolicy -PolicyDocument $policy2 -RoleName "EC2-S3" -PolicyName "allows3"

#2.创建VPC网络



#VPC
#Create new VPC 
New-EC2Vpc -CidrBlock 10.2.0.0/16



#3.创建两个子网，位于不同AZ


#Create subnet in the new VPC
$vpcid=get-ec2vpc | Where-Object {$_.Cidrblock -eq "10.2.0.0/16"} | select -ExpandProperty vpcid
New-EC2Subnet -CidrBlock 10.2.1.0/24 -VpcId $vpcid -AvailabilityZone ap-southeast-2a 
New-EC2Subnet -CidrBlock 10.2.2.0/24 -VpcId $vpcid -AvailabilityZone ap-southeast-2b

Edit-EC2SubnetAttribute -SubnetId subid1 -MapPublicIpOnLaunch $true
Edit-EC2SubnetAttribute -SubnetId sbuid2 -MapPublicIpOnLaunch $true

$subid1=Get-EC2Subnet | Where-Object{$_.CidrBlock -eq "10.2.1.0/24"} | select -ExpandProperty SubnetId
#Add a Name Tag to the Subnet
$tag=new-object Amazon.EC2.Model.Tag -Property @{key="Name";value="Sydney"}
New-EC2Tag -Resource $subid1 -Tag $tag


$subid2=Get-EC2Subnet | Where-Object{$_.CidrBlock -eq "10.2.2.0/24"} | select -ExpandProperty SubnetId
#Add a Name Tag to the Subnet
$tag2=new-object Amazon.EC2.Model.Tag -Property @{key="Name";value="Melbourne"}
New-EC2Tag -Resource $subid2 -Tag $tag2

Edit-EC2SubnetAttribute -SubnetId $subid1 -MapPublicIpOnLaunch $true
Edit-EC2SubnetAttribute -SubnetId $subid2 -MapPublicIpOnLaunch $true



#4.创建Internet网关

if((Get-EC2InternetGateway | Where-Object {$_.Attachments[0] -eq $null} | measure).count -eq 0){
    New-EC2InternetGateway 
}

$igwid=Get-EC2InternetGateway | Where-Object {$_.Attachments[0] -eq $null} | select -ExpandProperty internetGateWayId

$tagigw=new-object Amazon.EC2.Model.Tag -Property @{key="Name";value="AU"}
new-EC2tag -Resource $igwid -Tag $tagigw
Get-EC2InternetGateway $igwid|Add-EC2InternetGateway -VpcId $vpcid


#5.配置路由表


#RouteTable
#New-EC2RouteTable -VpcId $vpcid 
$routetable=Get-EC2RouteTable | Where-Object {$_.VpcId -eq $vpcid}
#Add new Route
New-EC2Route -DestinationCidrBlock "0.0.0.0/0" -GatewayId $igwid -RouteTableId $routetable.RouteTableId



#6.配置SecurityGroup和端口 SSH,HTTP，MySql


New-EC2SecurityGroup -GroupName WordPress -Description "WordPress Security Group" -VpcId $vpcid


$ip1=new-object Amazon.EC2.Model.IpPermission
$ip1.IpProtocol="tcp"
$ip1.FromPort=22
$ip1.ToPort="22"
$ip1.IpRange="0.0.0.0/0"
$ip2=New-Object Amazon.EC2.Model.IpPermission
$ip2.IpProtocol="tcp"
$ip2.FromPort=80
$ip2.ToPort=80
$ip2.IpRange.Add("0.0.0.0/0")


Get-EC2SecurityGroup | Where-Object {$_.GroupName -eq "WordPress"} | Grant-EC2SecurityGroupIngress -IpPermission @($ip1,$ip2) 


#MariaDB HA
#7.创建RDS MultipleZone

New-RDSDBInstance -AllocatedStorage 5 -DBInstanceIdentifier "wordpress" -MasterUsername "wordpress" -MasterUserPassword "wordpress" `
 -AutoMinorVersionUpgrade $true -CopyTagsToSnapshot $false -DBInstanceClass "db.t2.micro" `
 -DBName "wordpress" -Engine "mariadb" -MultiAZ $true
  


$rdssgid=(Get-RDSDBInstance -DBInstanceIdentifier "wordpress" | select -ExpandProperty vpcSecurityGroups).vpcsecuritygroupid



$status=Get-RDSDBInstance -DBInstanceIdentifier "wordpress" | select -ExpandProperty DBInstanceStatus


write-host "Initializing Mariad DB, Please wait..." -NoNewline

while ($status -ne "available"){

write-host "." -NoNewline
Start-Sleep -Seconds 1

$status=Get-RDSDBInstance -DBInstanceIdentifier "wordpress" | select -ExpandProperty DBInstanceStatus

}

write-host "RDS is Ready"

#Configure Security Group of DB

$ip3=New-Object Amazon.EC2.Model.IpPermission
$ip3.IpProtocol="tcp"
$ip3.FromPort=3306
$ip3.ToPort=3306
$ip3.IpRange.Add("0.0.0.0/0")

Get-EC2SecurityGroup | Where-Object{$_.GroupId -eq $rdssgid} | Grant-EC2SecurityGroupIngress -IpPermission @($ip3) 






#Create S3 Bucket and upload wordpress and Vhosts

New-S3Bucket -BucketName yuanliwordpress -Region ap-southeast-2
Get-S3Bucket -BucketName yuanliwordpress

$policy3=@"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AddPem",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::yuanliwordpress/*",
      "Principal": "*"
    }
  ]
}
"@

Write-S3BucketPolicy -BucketName yuanliwordpress -Policy $policy3

Get-S3BucketPolicy -BucketName yuanliwordpress


#12.配置S3和CloudFront

$origin = New-Object Amazon.CloudFront.Model.Origin
$origin.DomainName="yuanliwordpress.s3.amazonaws.com"
$origin.id="S3-yuanliwordpress"
$origin.S3OriginConfig = New-Object Amazon.CloudFront.Model.S3OriginConfig
$origin.S3OriginConfig.OriginAccessIdentity = ""
$cfd=New-CFDistribution `
      -DistributionConfig_Enabled $true `
      -DistributionConfig_Comment "Test distribution" `
      -Origins_Item $origin `
      -Origins_Quantity 1 `
      -DistributionConfig_CallerReference wordpresstest `
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
      -Aliases_Quantity 0

#$cfd= Get-CFDistribution -Id EA9RMV0SA0XV1

#准备WordPress配置文件和 VHost文件

#下载WordPress 保存在对应的目录

$adddress=(Get-RDSDBInstance | Where-Object {$_.DBName -eq "wordpress"} | select -ExpandProperty Endpoint).address
$content=get-content C:\Users\yli\Downloads\wordpress-4.5.3\wordpress\wp-config-sample.php
$content.Replace("define('DB_NAME', 'database_name_here')","define('DB_NAME', 'wordpress')").`
Replace("define('DB_USER', 'username_here')","define('DB_USER', 'wordpress')").`
Replace("define('DB_PASSWORD', 'password_here')","define('DB_PASSWORD', 'wordpress')").`
Replace("define('DB_HOST', 'localhost')","define('DB_HOST', '$adddress')") |
set-content C:\Users\yli\Downloads\wordpress-4.5.3\wordpress\wp-config.php


gc C:\Users\yli\Downloads\wordpress-4.5.3\wordpress\wp-config.php


$vhost=@"
<VirtualHost *:80>
       
        ServerName blog.beanxyz.com
		ServerAdmin webmaster@localhost
        DocumentRoot /var/www/wordpress


        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        RewriteEngine on
		Rewritecond %{HTTP_HOST} !^$
		RewriteRule ^/wp-content/uploads(.*)$ http://$($cfd.domainname)/uploads$1 [R=302]
</VirtualHost>
"@




$vhost | Set-Content C:\Users\yli\Downloads\wordpress-4.5.3\wordpress.conf




Write-S3Object -BucketName yuanliwordpress -Folder C:\Users\yli\Downloads\wordpress-4.5.3\wordpress -KeyPrefix wordpress -Recurse
Write-S3Object -BucketName yuanliwordpress -Key wordpress_vhosts -File C:\users\yli\Downloads\wordpress-4.5.3\wordpress.conf


Get-S3Object -BucketName yuanliwordpress

#Create AMI Image
#8.创建EC2实例

#绑定Role

New-IAMInstanceProfile -InstanceProfileName "WordPress" 
Add-IAMRoleToInstanceProfile -RoleName EC2-S3 -InstanceProfileName "WordPress"


$groupid=Get-EC2SecurityGroup | Where-Object {$_.GroupName -eq "WordPress"} | select -ExpandProperty groupid


#配置LAMP和WordPress

$userdata=@"
#!/bin/bash
apt-get update
apt-get upgrade -y
apt-get install -y mysql-client libmysqlclient15-dev apache2 apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libapache2-mod-php5 php5 php5-common php5-curl php5-dev php5-gd php5-idn php-pear php5-imagick php5-mcrypt php5-mysql php5-ps php5-pspell php5-recode php5-xsl python-pip && pip install awscli
aws s3 cp --recursive s3://yuanliwordpress/wordpress /var/www/wordpress/
chown -R www-data.www-data wordpress
chmod 755 /var/www/wordpress/
aws s3 cp s3://yuanliwordpress/wordpress_vhosts /etc/apache2/sites-available/wordpress.conf
cd /etc/apache2/sites-avaiable
a2ensite wordpress.conf
service apache2 restart
chmod 777 /var/www/wordpress/wp-contents
echo "*/1 * * * * root aws s3 sync /var/www/wordpress/wp-content/uploads s3://yuanliwordpress/uploads" >> /etc/crontab
a2enmod rewrite
service apache2 restart
"@

$b=[System.Text.Encoding]::UTF8.GetBytes($userdata)
$a=[System.Convert]::ToBase64String($b)

$instance=New-EC2Instance -ImageId ami-6c14310f -InstanceType t2.micro -KeyName aws -SubnetId $subnet1 -SecurityGroupId $groupid -MinCount 1 -MaxCount 1 -InstanceProfile_Name "WordPress" -UserData $a

$instanceid=($instance| select -expand instances).instanceid

write-host "Initilizing EC2 Instance, Please wait ..." -ForegroundColor Cyan -NoNewline



$state=$false
while($state -eq $false){

  $name= (Get-EC2Instance -InstanceId $instanceid | select -ExpandProperty instances | select -ExpandProperty state).name

  if($name.Value -eq "running"){
  $state=$true
  }else{
  
  start-sleep -Seconds 2
  write-host "..." -ForegroundColor Cyan -NoNewline
  }


}


$publicip=Get-EC2Instance -InstanceId $instanceid | select -ExpandProperty instances | select -ExpandProperty publicipaddress


#更新DNS记录
write-host "Updating DNS Record.." -ForegroundColor Cyan

$domain=Get-R53HostedZonesByName -DNSName beanxyz.com
$hostid=$domain.id.Split("/")[2]
$recordsets=Get-R53ResourceRecordSet -HostedZoneId $domain.id.Split("/")[2] 
$currentip=$recordsets | select -ExpandProperty resourceRecordSets | where-object {$_.name -eq "blog.beanxyz.com."} | select -ExpandProperty ResourceRecords | select -ExpandProperty value
$type=$recordsets | select -ExpandProperty resourceRecordSets | where-object {$_.name -eq "blog.beanxyz.com."} | select -ExpandProperty Type | select -ExpandProperty value


$change1 = New-Object Amazon.Route53.Model.Change
$change1.Action = "DELETE"
$change1.ResourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
$change1.ResourceRecordSet.Name = "blog.beanxyz.com"
$change1.ResourceRecordSet.Type = $type
$change1.ResourceRecordSet.TTL = 300
$change1.ResourceRecordSet.ResourceRecords.Add(@{Value=$currentip})

$change3 = New-Object Amazon.Route53.Model.Change
$change3.Action = "CREATE"
$change3.ResourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
$change3.ResourceRecordSet.Name = "blog.beanxyz.com"
$change3.ResourceRecordSet.Type = "A"
$change3.ResourceRecordSet.TTL = 300
$change3.ResourceRecordSet.ResourceRecords.Add(@{Value=$publicip})

$params = @{
    HostedZoneId=$hostid
	ChangeBatch_Comment="Replace a record of blog.beanxyz.com from $currentip to $publicip"
	ChangeBatch_Change=$change1,$change3
}

Edit-R53ResourceRecordSet @params 

$tagec2=new-object Amazon.EC2.Model.Tag -Property @{key="Name";value="wordpress"}
New-EC2Tag -Resource $instanceid -Tag $tagec2



write-host "The WordPress blog is ready. Please login to blog.beanxyz.com to finish the inital setup" -ForegroundColor Cyan

start-process http://blog.beanxyz.com





#13.S3同步到WordPress，然后设置crontab，rewrite替换本地地址 





#aws s3 sync /var/www/wordpress/wp-content/uploads s3://yuanliwordpress/uploads

#vi /etc/crontab
#*/1 * * * * root aws s3 sync /var/www/wordpress/wp-content/uploads s3://yuanliwordpress/uploads

#RewriteEngine on
#Rewritecond %{HTTP_HOST} !^$
#RewriteRule ^/wp-content/uploads(.*)$ http://dqn349d5c7jpy.cloudfront.net/uploads$1 [R=302]
#sudo a2enmod rewrite
#service apache2 restart


#14.配置AMI镜像


New-EC2Image -Description TemplateWordPress -Name TemplateWordPress -InstanceId $instanceid
Get-EC2Image -Owner self | Unregister-EC2Image -PassThru



#Create ELB and Auto Scaling
#15.配置ELB

#Create ELB
$HTTPListener = New-Object -TypeName ‘Amazon.ElasticLoadBalancing.Model.Listener’
$HTTPListener.Protocol = ‘http’
$HTTPListener.InstancePort = 80
$HTTPListener.LoadBalancerPort = 80
$groupid=(Get-EC2SecurityGroup| where-object {$_.GroupName -eq "wordpress"}).GroupId
$subnet1=(Get-EC2Subnet | Where-Object {$_.CidrBlock -eq "10.2.1.0/24"}).SubnetId
$subnet2=(Get-EC2Subnet | Where-Object {$_.CidrBlock -eq "10.2.2.0/24"}).SubnetId
$elb=New-ELBLoadBalancer -LoadBalancerName "MyLoadBalance" -Listener $HTTPListener -SecurityGroup $groupid -Subnet @($subnet1,$subnet2) 
#$elb=Get-ELBLoadBalancer
#Register-ELBInstanceWithLoadBalancer -LoadBalancerName "MyLoadBalance" -Instance @($instance2Id)


#更新DNS到LoadBalancer上

write-host "Updating DNS Record.." -ForegroundColor Cyan

$domain=Get-R53HostedZonesByName -DNSName beanxyz.com
$hostid=$domain.id.Split("/")[2]
$recordsets=Get-R53ResourceRecordSet -HostedZoneId $domain.id.Split("/")[2] 
$currentip=$recordsets | select -ExpandProperty resourceRecordSets | where-object {$_.name -eq "blog.beanxyz.com."} | select -ExpandProperty ResourceRecords | select -ExpandProperty value


$change1 = New-Object Amazon.Route53.Model.Change
$change1.Action = "DELETE"
$change1.ResourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
$change1.ResourceRecordSet.Name = "blog.beanxyz.com"
$change1.ResourceRecordSet.Type = "A"
$change1.ResourceRecordSet.TTL = 300
$change1.ResourceRecordSet.ResourceRecords.Add(@{Value=$currentip})

$change3 = New-Object Amazon.Route53.Model.Change
$change3.Action = "CREATE"
$change3.ResourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
$change3.ResourceRecordSet.Name = "blog.beanxyz.com"
$change3.ResourceRecordSet.Type = "CNAME"
$change3.ResourceRecordSet.TTL = 300
$change3.ResourceRecordSet.ResourceRecords.Add(@{Value=$elb})

$params = @{
    HostedZoneId=$hostid
	ChangeBatch_Comment="Replace a record of blog.beanxyz.com from $currentip to $newname"
	ChangeBatch_Change=$change1,$change3
}

Edit-R53ResourceRecordSet @params 




#16.配置 Launch Configuration- UserData（Bootstrap）

$arn=(Get-IAMInstanceProfileForRole -RoleName EC2-S3).Arn


New-ASLaunchConfiguration -ImageId (Get-EC2Image -Owner self).imageid -LaunchConfigurationName "My-launchconfigurationfile" -InstanceType "t2.micro" -SecurityGroup $groupid -UserData $a -KeyName aws -IamInstanceProfile $arn

New-ASAutoScalingGroup -AutoScalingGroupName "my-asg" -LaunchConfigurationName "My-launchconfigurationfile" -MinSize 1 -MaxSize 3 -LoadBalancerName "MyLoadBalance" `
-VPCZoneIdentifier $subnet1
Write-ASScalingPolicy -AutoScalingGroupName my-asg -AdjustmentType "ChangeInCapacity" -PolicyName "myScaleInPolicy" -ScalingAdjustment 1 

#Remove-ASAutoScalingGroup -AutoScalingGroupName "my-asg"

$stepadjustment=New-Object Amazon.AutoScaling.Model.StepAdjustment 
$stepadjustment.MetricIntervalLowerBound=20
$stepadjustment.ScalingAdjustment=-1
Write-ASScalingPolicy -AutoScalingGroupName my-asg -AdjustmentType "ChangeInCapacity" -PolicyName "myScaleInPolicy1" -PolicyType "StepScaling" -StepAdjustment $stepadjustment
Write-CWMetricAlarm -ActionsEnabled $true -Alarmname "testonly" -AlarmAction {arn:aws:autoscaling:ap-southeast-2:503646143282:scalingPolicy:fba2d6ec-1566-459a-a3d5-bb800e88f7ad:autoScalingGroupName/my-asg:policyName/myScaleInPolicy1} -Namespace "AWS/EC2" -Period 300 -Statistic "Average" -MetricName "CPUUtlilization" `
-ComparisonOperator "LessThanOrEqualToThreshold" -Threshold 60 -EvaluationPeriod 1

#17.配置 Auto Scaling Group
#18.配置DNS 域名指向ELB的地址

$stepadjustment=New-Object Amazon.AutoScaling.Model.StepAdjustment 
$stepadjustment.MetricIntervalLowerBound=20
$stepadjustment.ScalingAdjustment=-1
Write-ASScalingPolicy -AutoScalingGroupName my-asg -AdjustmentType "ChangeInCapacity" -PolicyName "myScaleInPolicy1" -PolicyType "StepScaling" -StepAdjustment $stepadjustment
Write-CWMetricAlarm -ActionsEnabled $true -Alarmname "testonly" -AlarmAction {arn:aws:autoscaling:ap-southeast-2:503646143282:scalingPolicy:4cb293a4-1e6f-4d3e-8c02-2baec06ee663:autoScalingGroupName/my-asg:policyName/myScaleInPolicy1
} -Namespace "AWS/EC2" -Period 300 -Statistic "Average" -MetricName "CPUUtlilization" `
-ComparisonOperator "LessThanOrEqualToThreshold" -Threshold 60 -EvaluationPeriod 1