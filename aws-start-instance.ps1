#Use the EC2Start credentials
#This will get all the instances and their names and IDs and put in table
$instances = Get-EC2Instance `
             | %{$_.runninginstance}`
             | select-object InstanceID,@{Name='TagValues'; Expression={($_.Tag |%{ $_.Value }) -join ','}}


#Start the instance in question
Start-EC2Instance -InstanceId "i-" 