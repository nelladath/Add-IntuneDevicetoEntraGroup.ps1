
##########################################################################

#Add-IntuneDevicetoEntraGroup.ps1
#Author : Sujin Nelladath
#LinkedIn : https://www.linkedin.com/in/sujin-nelladath-8911968a/

############################################################################

#Connect to Microsoft Graph
Connect-Graph -Scopes "GroupMember.ReadWrite.All", "Device.ReadWrite.All" 


# Define Microsoft Graph API endpoint
$GraphBaseURL = "https://graph.microsoft.com/v1.0"

# Function to get Group ID by name
function Get-GroupID {
    param ($GroupName)
    $GroupURL = "$GraphBaseURL/groups?`$filter=displayName eq '$GroupName'"
    $Group = Invoke-MgGraphRequest -Uri $GroupURL -Method GET 
    return $Group.value[0].id
    
}

# Function to get Device ID by name
function Get-DeviceID {
    param ($DeviceName)
    $DeviceURL = "$GraphBaseURL/devices?`$filter=displayName eq '$DeviceName'"
    $Device = Invoke-MgGraphRequest -Uri $DeviceURL -Method GET
    return $Device.value[0].id
}

# Prompt user for Group Name
$GroupName = Read-Host "Enter Intune group name"
$GroupName = $GroupName.Trim()
$GroupID = Get-GroupID -GroupName $GroupName

if (!$GroupID) 
    {
        Write-Host "Group not found. Exiting."; 
        exit   
    }

# Prompt user for Device Name
$DeviceName = Read-Host "Enter device name"
$DeviceID = Get-DeviceID -DeviceName $DeviceName
if (!$DeviceID)
    { 
        Write-Host "Device not found. Exiting.";
        exit 
    }

# Add Device to Group
$AddMemberURL = "$GraphBaseURL/groups/$GroupID/members/`$ref"
$Body = @{ "@odata.id" = "$GraphBaseURL/directoryObjects/$DeviceID" } | ConvertTo-Json
Invoke-MgGraphRequest -Uri $AddMemberURL  -Method POST -Body $Body

Write-Host "Device $DeviceName successfully added to group $GroupName"

