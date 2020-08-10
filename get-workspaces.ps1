### Create a report of all workspaces in a specific AWS Region
### Download and install AWS Tools for Windows Powershell: https://aws.amazon.com/powershell/

### Want to add Directory Frienldy Name, Tags asscoiated with instance

$AWSAccessKey = ""
$AWSSecretKey = ""
$AWSSessionToken = ""

$reportPath = "d:\temp\aws-workspaces-report.csv"

# Region workspaces are provisioned in
$AWSRegion = "us-east-1"

### Do not edit below this line

# Create session with access keys
Set-AWSCredential -AccessKey $AWSAccessKey -SecretKey $AWSSecretKey -SessionToken $AWSSessionToken
Set-DefaultAWSRegion -Region $AWSRegion

$workspaces = Get-WKSWorkspace

$report = @()
foreach ($workspace in $workspaces) {
    $ConnectionStateCheckTimestamp = ""
    $LastKnownUserConnectionTimestamp = ""
    
    $connectionStatus = Get-WKSWorkspacesConnectionStatus -WorkspaceId "$($workspace.WorkspaceId)"
    $ConnectionStateCheckTimestamp = [System.TimeZone]::CurrentTimeZone.ToLocalTime($connectionStatus.ConnectionStateCheckTimestamp)
    $LastKnownUserConnectionTimestamp = [System.TimeZone]::CurrentTimeZone.ToLocalTime($connectionStatus.LastKnownUserConnectionTimestamp)
    
    if ($LastKnownUserConnectionTimestamp -eq "1/1/0001 12:00:00 AM") {
        $LastKnownUserConnectionTimestamp = "Information Unavailable"
    }

    $object = New-Object system.object
    $object | Add-Member -type NoteProperty -name WorkspaceId -Value $workspace.WorkspaceId
    $object | Add-Member -type NoteProperty -name UserName -Value $workspace.UserName
    $object | Add-Member -type NoteProperty -name ComputerName -Value $workspace.ComputerName
    $object | Add-Member -type NoteProperty -name IpAddress -Value $workspace.IpAddress
    $object | Add-Member -type NoteProperty -name WorkspaceState -Value $workspace.State
    $object | Add-Member -type NoteProperty -name UserConnectionState -Value $connectionStatus.ConnectionState
    $object | Add-Member -type NoteProperty -name ConnectionStateCheckTimestamp -Value $ConnectionStateCheckTimestamp
    $object | Add-Member -type NoteProperty -name LastKnownUserConnectionTimestamp -Value $LastKnownUserConnectionTimestamp
    $object | Add-Member -type NoteProperty -name ComputeType -Value $workspace.WorkspaceProperties.ComputeTypeName
    $object | Add-Member -type NoteProperty -name RootVolumeSizeGib -Value $workspace.WorkspaceProperties.RootVolumeSizeGib
    $object | Add-Member -type NoteProperty -name UserVolumeSizeGib -Value $workspace.WorkspaceProperties.UserVolumeSizeGib
    $object | Add-Member -type NoteProperty -name RunningMode -Value $workspace.WorkspaceProperties.RunningMode
    $object | Add-Member -type NoteProperty -name AutoStopTimeoutInMins -Value $workspace.WorkspaceProperties.RunningModeAutoStopTimeoutInMinutes
    $object | Add-Member -type NoteProperty -name RootVolumeEncryptionEnabled -Value $workspace.RootVolumeEncryptionEnabled
    $object | Add-Member -type NoteProperty -name UserVolumeEncryptionEnabled -Value $workspace.UserVolumeEncryptionEnabled
    $object | Add-Member -type NoteProperty -name VolumeEncryptionKey -Value $workspace.VolumeEncryptionKey
    $object | Add-Member -type NoteProperty -name SubnetId -Value $workspace.SubnetId
    $object | Add-Member -type NoteProperty -name BundleId -Value $workspace.BundleId
    $object | Add-Member -type NoteProperty -name DirectoryId -Value $workspace.DirectoryId
    $object | Add-Member -type NoteProperty -name ErrorCode -Value $workspace.ErrorCode
    $object | Add-Member -type NoteProperty -name ErrorMessage -Value $workspace.ErrorMessage
    $report += $object
}

$report | Export-Csv -NoTypeInformation -Path $reportPath