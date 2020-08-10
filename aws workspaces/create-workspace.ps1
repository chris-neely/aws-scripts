### Create workspaces based off of a CSV file of users
### Download and install AWS Tools for Windows Powershell: https://aws.amazon.com/powershell/
### The CSV file should have a column that contains the sAMAccountName for each user - No header column is required

###  PLEASE READ LINE 24 AND PROVIDE THE CORRECT IMAGE NAME!!!!!!

$AWSAccessKey = ""
$AWSSecretKey = ""
$AWSSessionToken = ""

# Region to provision workspaces in
$AWSRegion = "us-east-1"

# Path to CSV File
$CSVPath = "d:\temp\create-Workspace.csv"

# Path to Error Log File
$errorLog = "d:\temp\workspace-creation-log.txt"

# Workspace Settings
$BundleId = "wsb-000000000" # Copy and Paste from AWS Console - Default is PTEN_WIN10_1803_STANDARD
$DirectoryId = "d-0000000000" # Copy and Paste from AWS Console - Default is PTEN-MFA
$ImageName = "WIN10_1803_V1.0"  # Copy and paste the image name assigned to the bundle in the AWS console.  Ex. WIN10_1803_V1.0
$RunningMode = "ALWAYS_ON" # Set running mode - ALWAYS_ON or AUTO_STOP
$RootEncryption = "$false" # Root Volume Encryption - $true or $false
$UserEncryption = "$false" # User Volume Encryption - $true or $false
$EncryptionKey = "alias/aws/workspaces"

# Create session with access keys
Set-AWSCredential -AccessKey $AWSAccessKey -SecretKey $AWSSecretKey -SessionToken $AWSSessionToken
Set-DefaultAWSRegion -Region $AWSRegion

$userlist = Import-Csv -Path $CSVpath -Header UserName

# Loop through CSV file and create workspace for each user
foreach ($user in $userlist) {
    
    # Submit request to create workspace
    $request = New-WKSWorkspace -Workspace @{
        "BundleId" = "$($BundleId)";
        "DirectoryId" = "$($DirectoryId)";
        "UserName" = "$($user.UserName)";
        "RootVolumeEncryptionEnabled" = $RootEncryption;
        "UserVolumeEncryptionEnabled" = $UserEncryption;
        "VolumeEncryptionKey" = "$EncryptionKey";
        "WorkspaceProperties" = @{
            "RunningMode" = "$RunningMode"
        };
        "Tags" = @( @{key="ImageVersion";value="$($ImageName)"}, `
            @{key="ProvisionDate";value="$(get-date -format o)"} )
    }

    # Output request details or errors
    Write-Output "------------------------------------" | Tee-Object -FilePath $errorLog -Append
    Write-Output "UserName : $($user.UserName)" | Tee-Object -FilePath $errorLog -Append
    if ($request.ResponseMetadata) {
        Write-Output "RequestId : $($request.ResponseMetadata.RequestId)" | Tee-Object -FilePath $errorLog -Append
        if ($request.ResponseMetadata.Metadata.count -ne 0) {
            Write-Output "Metadata : $($request.ResponseMetadata.Metadata)" | Tee-Object -FilePath $errorLog -Append
        }
    }
    if ($request.FailedRequests) {
        Write-Output "ErrorCode : $($request.FailedRequests.ErrorCode)" | Tee-Object -FilePath $errorLog -Append
        Write-Output "ErrorMessage : $($request.FailedRequests.ErrorMessage)" | Tee-Object -FilePath $errorLog -Append
    }
    if ($request.PendingRequests) {
        Write-Output "Pending Request Details :" | Tee-Object -FilePath $errorLog -Append
        Write-Output $request.PendingRequests | FL | Tee-Object -FilePath $errorLog -Append
    }
}