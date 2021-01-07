$buckets=Get-S3Bucket


$Expiration = [Amazon.S3.Model.LifecycleRuleExpiration]::new()

$Expiration.Days="100"


$LifecycleRule = [Amazon.S3.Model.LifecycleRule]::new()

$LifecycleRule.Expiration=$Expiration


$LifecycleRule.Prefix = $null
$LifecycleRule.Status = 'Enabled'
$LifecycleRule.id="Delete Rule"





foreach($bucket in $buckets){

    $bucketname=$bucket.bucketname
    $bucketendpoint=Get-S3BucketLocation -BucketName $bucketname
    $bucketname
    $endpointurl="https://s3.$bucketendpoint.amazonaws.com"
    $endpointurl
    Write-S3LifecycleConfiguration -Configuration_Rule $LifecycleRule -BucketName $bucketname -EndpointUrl "https://s3.ap-south-1.amazonaws.com" -Verbose

}
