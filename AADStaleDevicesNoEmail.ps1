<#	
	NOTES
	===========================================================================
	 Script Name: 	AADStaleDevices
	 Version:	1.2
	 Created on:   	11/4/2021
	 Updated on: 	1/27/2022
	 Created by:   	iBowler1995
	 Filename: 	AADStaleDevices.ps1
	===========================================================================
	.DESCRIPTION
	This script is designed to manage stale AzureAD Devices.

	Things to change to work for your environment:

	Line 70-73: Fill out your certificate information or use another method to connect to Graph. See https://bit.ly/3G6kpeV for more information
	===========================================================================
	.PARAMETER Threshold
	This specifies how many days back you want to look
	.PARAMETER Verify
	This will only report how many devices are beyond the threshold you set and email the report
	.PARAMETER VerifyDisabled
	This will only report how many disabled devices are beyond the threshold you set and email the report
	.PARAMETER DisableDevices
	This will disable all devices beyond the threshold you set and email a before and after report
	.PARAMETER RemoveDevices
	This will remove all *disabled* devices beyond the threshold you set and email a before and after report. Does NOT remove devices beyond threshold that are still enabled
	===========================================================================
	IMPORTANT:
	===========================================================================
	This script is provided 'as is' without any warranty. Any issues stemming 
	from use is on the user.

	You should not delete a device immediately after disabling it, as there is
	no recovering a deleted device. Recommended practice is to disable for a
	certain amount of time and then delete.
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory = $true)]
	[Int]$Threshold,
	[Parameter(Mandatory = $false)]
	[switch]$Verify,
	[Parameter(Mandatory = $false)]
	[switch]$VerifyDisabled,
	[Parameter(Mandatory = $false)]
	[switch]$DisableDevices,
	[Parameter(Mandatory = $false)]
	[switch]$RemoveDevices		
)

#checks required modules
if (-Not(Get-Module -ListAvailable -Name "Microsoft.Graph.Identity.DirectoryManagement")) {

	Install-Module -Name "Microsoft.Graph.Identity.DirectoryManagement" -Repository PSGallery -Force -AllowClobber

}
if (-Not(Get-Module -ListAvailable -Name "ImportExcel")) {

	Install-Module -Name "ImportExcel" -Repository PSGallery -Force -AllowClobber

}
#Variables for the script
$Date = ("{0:s}" -f (Get-Date)).Split("T")[0]
$Days = [datetime](get-date).AddDays(- $Threshold)
$SubjectDate = Get-Date -Format "MM-dd-yyyy"

#Connects to MS Graph
Write-Host "Connecting to MS Graph. . ." -f Yellow
$AppID = ''
$TenantID = ''
$Certificate = ''
Connect-MgGraph -ClientID $AppID -TenantID $TenantID -CertificateThumbprint $Certificate

#################################################

function Get-AADDevice {

	<#
		.DESCRIPTION
		Gets an Azure AD device
		.PARAMETER Name
		This parameter is used to target a device by name.
		.PARAMETER Id
		This parameter is used to target a device by Id.
		.EXAMPLE
		Get-AzureADDevice <--- This will return all AzureAD devices
		Get-AzureADDevice -Name Desktop-SJ87X <--- This will return the named device
		Get-AzureADDevice -Id {object id} <--- This will return the device based on object id
	#>

    [CmdletBinding()]
    param(
    [Parameter()]
    [String]$Name,
	[parameter()]
	[String]$ID
    )

	#Ensuring the needed modules are installed
    if (-Not(Get-Module -ListAvailable -Name "Microsoft.Graph.Identity.DirectoryManagement")) {

        Install-Module -Name "Microsoft.Graph.Identity.DirectoryManagement" -Repository PSGallery -Force -AllowClobber

    }

    If (($Name -eq $Null -or $Name -eq "") -and ($ID -eq $null -or $ID -eq "")) {

        try {

			#Listing all AADDevices if neither name nor ID is specified
			Get-MgDevice -All

    	}
        catch{

			$e = $_Exception
			$Line = $_.InvocationInfo.ScriptLineNumber
        	Write-Host "An error occurred at line $($Line):" -f Red
        	Write-Host "$_" -f Red

    	}

    }
    elseif ($ID -ne $Null -and $ID -ne "") {

        try {

			#Listing AADDevice based on Id
	        Get-MgDevice -All | where {$_.Id -eq $Id}

    	}
    	catch{

        	$e = $_Exception
			$Line = $_.InvocationInfo.ScriptLineNumber
        	Write-Host "An error occurred at line $($Line):" -f Red
        	Write-Host "$_" -f Red

	    }

    }
	elseif ($Name -ne $Null -and $Name -ne ""){

		try {

			#Listing AADDevice based on displayName
        	Get-MgDevice -All | where {$_.displayName -eq $Name}

		}
		catch{

			$e = $_Exception
			$Line = $_.InvocationInfo.ScriptLineNumber
        	Write-Host "An error occurred at line $($Line):" -f Red
        	Write-Host "$_" -f Red

		}

	}

}

#################################################

function Disable-AADDevice {

	<#
		.DESCRIPTION
		This function will disable an Azure AD Device.
		.PARAMETER ID
		This parameter is required and specifies the target device by object ID
		.EXAMPLE
		Disable-AzureADDevice -ID {object ID} <--- This will disable an Azure AD Device based on object ID
		Disable-AzureADDevice -ID DESKTOP-H8JX95 <--- This will disable the Azure AD Device based on PC name
	#>

	[CmdletBinding()]
    param(
	[parameter()]
	[String]$ID,
	[Parameter()]
	[String]$Name
    )

	#Ensuring the needed modules are installed
    if (-Not(Get-Module -ListAvailable -Name "Microsoft.Graph.Identity.DirectoryManagement")) {

        Install-Module -Name "Microsoft.Graph.Identity.DirectoryManagement" -Repository PSGallery -Force -AllowClobber

    }


	If ($ID -ne $Null -and $ID -ne ""){

		Try {
		#Getting device based on Id
		$Target = Get-MgDevice -All | where {$_.Id -eq $ID}
		Update-MgDevice -deviceId $Target.Id -AccountEnabled:$False
		}
		Catch {

			$e = $_Exception
			$Line = $_.InvocationInfo.ScriptLineNumber
			Write-Host "An error occurred at line $($Line):" -f Red
			Write-Host "$_" -f Red

		}

	}
	elseif ($Name -ne $Null -and $Name -ne ""){

		Try {
		#Getting device based on displayName
		$Target = Get-MgDevice -All | where {$_.displayName -eq $Name}
		Update-MgDevice -deviceId $Target.Id -AccountEnabled:$False
		}
		Catch {

			$e = $_Exception
			$Line = $_.InvocationInfo.ScriptLineNumber
			Write-Host "An error occurred at line $($Line):" -f Red
			Write-Host "$_" -f Red

		}

	}

}

#################################################

function Remove-AADDevice {

	<#
		.DESCRIPTION
		This function will remove an Azure AD Device.
		.PARAMETER ID
		This parameter is required and specifies the target device by object ID
		.EXAMPLE
		Remove-AzureADDevice -ID {object ID} <--- This will remove an Azure AD Device based on object ID
	#>

	[CmdletBinding()]
    param(
	[parameter()]
	[String]$ID,
	[parameter()]
	[String]$Name
    )

	#Ensuring the needed modules are installed
    if (-Not(Get-Module -ListAvailable -Name "Microsoft.Graph.Identity.DirectoryManagement")) {

        Install-Module -Name "Microsoft.Graph.Identity.DirectoryManagement" -Repository PSGallery -Force -AllowClobber

    }


	If ($ID -ne $Null -and $ID -ne ""){

		Try {

			#Obtaining device based on ID
			$Target = Get-MgDevice -All | where {$_.Id -eq $ID}
			Remove-MgDevice -deviceId $Target.Id

		}
		Catch {

			$e = $_Exception
			$Line = $_.InvocationInfo.ScriptLineNumber
			Write-Host "An error occurred at line $($Line):" -f Red
			Write-Host "$_" -f Red

		}

	}
	elseif ($Name -ne $null -and $Name -ne ""){

		Try {

			#Obtaining device based on displayName/PC Name
			$Target = Get-MgDevice -All | where {$_.displayName -eq $DisplayName}
			Remove-MgDevice -deviceId $Target.Id

		}
		Catch {

			$e = $_Exception
			$Line = $_.InvocationInfo.ScriptLineNumber
			Write-Host "An error occurred at line $($Line):" -f Red
			Write-Host "$_" -f Red

		}

		}

}

If ($Verify)
{
	$vPath = ".\Exports\Stale Azure Devices_" + $Date + ".xlsx"
	$GetStaleDevices = Get-AADDevice | Where { $_.approximateLastSignInDateTime -le $Days -and ($_.OperatingSystem -eq "Windows")} | select-object -Property AccountEnabled, Id, DeviceId, OperatingSystem, operatingSystemVersion, DisplayName, approximateLastSignInDateTime
	$GetStaleDevices | Export-Excel -workSheetName "Stale Devices" -path $vPath -ClearSheet -TableName "Stale AAD Devices" -AutoSize
}
elseif ($VerifyDisabled)
{
	$vdPath = ".\Exports\Stale Disabled Azure Devices_" + $Date + ".xlsx"
	$GetDisabledStaleDevices = Get-AADDevice | where { ($_.approximateLastSignInDateTime -le $Days) -and ($_.AccountEnabled -eq $false) -and ($_.OperatingSystem -eq "Windows")} | select-object -Property AccountEnabled, Id, DeviceId, OperatingSystem, operatingSystemVersion, DisplayName, approximateLastSignInDateTime
	$GetDisabledStaleDevices | Export-Excel -workSheetName "Stale Disabled Devices" -path $vdPath -ClearSheet -TableName "Stale Disabled AAD Devices" -AutoSize
}
elseif ($DisableDevices)
{
	$ddBeforePath = ".\Exports\Azure Devices to be Disabled_" + $Date + ".xlsx"
	$ddafterPath = ".\Exports\Azure Devices Disabled_" + $Date + ".xlsx"
	$DisableAADDeviceList = Get-AADDevice | where { ($_.approximateLastSignInDateTime -le $Days) -and ($_.OperatingSystem -eq "Windows") } | select-object -Property AccountEnabled, Id, DeviceId, OperatingSystem, operatingSystemVersion, DisplayName, approximateLastSignInDateTime
	$DisableAADDeviceList | Export-Excel -workSheetName "Devices to be Disabled" -path $ddBeforePath -ClearSheet -TableName "AAD Devices to be Disabled" -AutoSize

	foreach ($StaleDevice in $DisableAADDeviceList)
	{
		Disable-AADDevice -ID $($StaleDevice.Id)
	}

	$DisableVerification = Get-AADDevice | where { ($_.approximateLastSignInDateTime -le $Days) -and ($_.OperatingSystem -eq "Windows") } | select-object -Property AccountEnabled, Id, DeviceId, OperatingSystem, operatingSystemVersion, DisplayName, approximateLastSignInDateTime 
	$DisableVerification | Export-Excel -workSheetName "Devices Disabled" -path $ddAfterPath -ClearSheet -TableName "AAD Devices Disabled" -AutoSize
}
elseif ($RemoveDevices)
{
	$rdBeforePath = ".\Exports\Azure Devices to be Removed_" + $Date + ".xlsx"
	$rdAfterPath = ".\Exports\Azure Devices Removed_" + $Date + ".xlsx"
	$RemoveAADDeviceList = Get-AADDevice | where { ($_.approximateLastSignInDateTime -le $Days) -and ($_.AccountEnabled -eq $false) -and ($_.OperatingSystem -eq "Windows")} | select-object -Property AccountEnabled, Id, DeviceId, OperatingSystem, operatingSystemVersion, DisplayName, approximateLastSignInDateTime
	$RemoveAADDeviceList | Export-Excel -workSheetName "Stale Devices to be Removed" -Path $rdBeforePath -ClearSheet -TableName "AAD Devices to be Removed" -AutoSize
	
	foreach ($DisabledDevice in $RemoveAADDeviceList)
	{
		Remove-AADDevice -ID $($DisabledDevice.Id)
	}
	$RemovedAADDevices = Get-AADDevice | where { ($_.approximateLastSignInDateTime -le $Days) -and ($_.AccountEnabled -eq $false) }
	$RemovedAADDevices | Export-Excel -workSheetName "Stale Devices Removed" -Path $rdAfterPath -ClearSheet -TableName "AAD Devices Removed" -AutoSize
}

