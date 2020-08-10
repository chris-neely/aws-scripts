$csvPath = "d:\temp\ec2-instances-NAME.csv"
$AWSAccessKey = ""
$AWSSecretKey = ""
$AWSSessionToken = ""
$AWSRegion = "us-east-1"

Set-AWSCredential -AccessKey $AWSAccessKey -SecretKey $AWSSecretKey -SessionToken $AWSSessionToken
Set-DefaultAWSRegion -Region $AWSRegion

$instances = @()
$tempInstances = (Get-EC2Instance).Instances

foreach ($tempInstance in $tempInstances) {
    #Create tempObj
    $tempObj = New-Object PSObject

    #Add predefined info from get-ec2instance command to the tempObj
    $tempObj | Add-Member -MemberType NoteProperty -Name "Instance-ID" -Value $tempInstance.InstanceId
    $tempObj | Add-Member -MemberType NoteProperty -Name "Instance-Type" -Value $tempInstance.InstanceType
    $tempObj | Add-Member -MemberType NoteProperty -Name "Core-Count" -Value $tempInstance.CpuOptions.CoreCount
    $tempObj | Add-Member -MemberType NoteProperty -Name "Threads-Per-Core" -Value $tempInstance.CpuOptions.ThreadsPerCore
    $tempObj | Add-Member -MemberType NoteProperty -Name "Key-Name" -Value $tempInstance.KeyName
    $tempObj | Add-Member -MemberType NoteProperty -Name "Platform" -Value $tempInstance.Platform
    $tempObj | Add-Member -MemberType NoteProperty -Name "Private-IP" -Value $tempInstance.PrivateIpAddress
    $tempObj | Add-Member -MemberType NoteProperty -Name "Public-IP" -Value $tempInstance.PublicIpAddress
    $tempObj | Add-Member -MemberType NoteProperty -Name "Security-Groups" -Value ($tempInstance.SecurityGroups.GroupName -join ',')
    $tempObj | Add-Member -MemberType NoteProperty -Name "Subnet-ID" -Value $tempInstance.SubnetId
    $tempObj | Add-Member -MemberType NoteProperty -Name "State" -Value $tempInstance.State.Name
    $tempObj | Add-Member -MemberType NoteProperty -Name "VPC-ID" -Value $tempInstance.VpcId

    #Loop through tags and add each key and value to the tempObj
    $instanceTags = $tempInstance.Tags | Sort-Object key
    foreach ($instanceTag in $instanceTags) {
        
        #Assign tags we want to include in the CSV file
        $tempObj | Add-Member -MemberType NoteProperty -Name $instanceTag.Key -Value $instanceTag.Value
        
    }

    #Append tempObj to our array of instances
    $instances += $tempObj
}

# Add tags to output here or they may not be included in the report if some tags are blank for some instances
$instances | Sort-Object Name | select Name, Instance-ID, Instance-Type, Core-Count, Threads-Per-Core, Key-Name, Platform, OS, Domain, Private-IP, Public-IP, Subnet-ID, State, VPC-ID, Environment, Notes, Security-Groups | Export-Csv -NoTypeInformation -Path $csvPath