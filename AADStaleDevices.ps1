<#	
	NOTES
	===========================================================================
	 Script Name: AADStaleDevices
	 Created on:   	11/4/2021
	 Created by:   	Levi Masse
	 Filename: AADStaleDevices.ps1
	===========================================================================
	.DESCRIPTION
		This script is designed to manage stale AzureAD Devices.
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
	[switch]$RemoveDevices,
	[Parameter(Mandatory = $false)]
	[switch]$UseCreds
	
	
)

#checks required modules
$AzureInstalled = Get-InstalledModule -Name "AzureAD"
if (!$AzureInstalled)
{
	Install-Module -Name AzureAD -Repository PSGallery -Force -AllowClobber
}
$ExcellInstalled = Get-InstalledModule -Name "ImportExcel"
if (!$ExcellInstalled) {
	Install-Module -Name ImportExcel -Repository PSGallery -Force -AllowClobber
}
#Variables for the script
$Date = ("{0:s}" -f (Get-Date)).Split("T")[0]
$Days = [datetime](get-date).AddDays(- $Threshold)
$SubjectDate = Get-Date -Format "MM-dd-yyyy"
#This should be the account with appropriate permission to execute this script
$UPN = "lmasse_sa238tg@verisma.com"
$SPWDExists = (Test-Path -Path .\SCred.txt -PathType Leaf)
If ($SPWDExists)
{
	$SPWD = Get-Content ".\SCred.txt" | ConvertTo-SecureString
	$ScriptCredential = New-Object -TypeName System.Management.Automation.PSCredential($UPN, $SPWD)
}
$From = "lmasse@verisma.com"
$To = "Infrastructure.Cloud@verisma.com"
$SMTPServer = "smtp.office365.com"
$SMTPPort = "587"
$EPWD = Get-Content ".\ECred.txt" | ConvertTo-SecureString
$ECred = New-Object -TypeName System.Management.Automation.PSCredential($From,$EPWD)

#Connects to AzureAD, with saved creds if the flag is called
If ($UseCreds)
{
	Connect-AzureAD -Credential $ScriptCredential -ErrorAction SilentlyContinue
}
else
{
	Connect-AzureAD -ErrorAction SilentlyContinue
}

If ($Verify)
{
	$vPath = ".\Exports\Stale Azure Devices_" + $Date + ".xlsx"
	$vSubject = "AAD Stale Device Verification: " + $SubjectDate + " Older than " + $Threshold + " Days"
	$GetStaleDevices = Get-AzureADDevice -All:$true | Where { $_.ApproximateLastLogonTimeStamp -le $Days } | select-object -Property AccountEnabled, DeviceId, DeviceOSVersion, DisplayName, ApproximateLastLogonTimestamp
	$GetStaleDevices | Export-Excel -workSheetName "Stale Devices" -path $vPath -ClearSheet -TableName "Stale AAD Devices" -AutoSize
	Send-MailMessage -From $From -To $To -Subject $vSubject -SmtpServer $SMTPServer -Port $SMTPPort -Credential $ECred -Attachments $vPath -UseSsl 
}
elseif ($VerifyDisabled)
{
	$vdPath = ".\Exports\Stale Disabled Azure Devices_" + $Date + ".xlsx"
	$vdSubject = "AAD Stale, Disabled Device Verification: " + $SubjectDate + " Older than " + $Threshold + " Days"
	$GetDisabledStaleDevices = Get-AzureADDevice -All:$true | where { ($_.ApproximateLastLogonTimeStamp -le $Days) -and ($_.AccountEnabled -eq $false) } | select-object -Property AccountEnabled, DeviceId, DeviceOSVersion, DisplayName, ApproximateLastLogonTimestamp
	$GetDisabledStaleDevices | Export-Excel -workSheetName "Stale Disabled Devices" -path $vdPath -ClearSheet -TableName "Stale Disabled AAD Devices" -AutoSize
	Send-MailMessage -From $From -To $To -Subject $vdSubject -SmtpServer $SMTPServer -Port $SMTPPort -Credential $ECred -Attachments $vdPath -UseSsl
}
elseif ($DisableDevices)
{
	$ddPath = ".\Exports\Azure Devices Disabled_" + $Date + ".xlsx"
	$ddSubject = "AAD Stale Devices Disabled: " + $SubjectDate + " Older than " + $Threshold + " Days"
	$DisableAADDevice = Get-AzureADDevice -All:$true | where { ($_.ApproximateLastLogonTimeStamp -le $Days) } | select-object -Property AccountEnabled, DeviceId, DeviceOSVersion, DisplayName, ApproximateLastLogonTimestamp
	$DisableAADDevice | Export-Excel -workSheetName "Devices Disabled" -path $ddPath -ClearSheet -TableName "AAD Devices Disabled" -AutoSize
	
	foreach ($StaleDevice in $DisableAADDevice)
	{
		Set-AzureADDevice -AccountEnabled $false
	}
	Send-MailMessage -From $From -To $To -Subject $ddSubject -SmtpServer $SMTPServer -Port $SMTPPort -Credential $ECred -Attachments $ddPath -UseSsl
}
elseif ($RemoveDevices)
{
	$rdPath = ".\Exports\Azure Devices Removed_" + $Date + ".xlsx"
	$rdSubject = "AAD Stale Devices Removed: " + $SubjectDate + " Older than " + $Threshold + " Days"
	$RemoveAADDeviceList = Get-AzureADDevice -All:$true | where { ($_.ApproximateLastLogonTimeStamp -le $Days) -and ($_.AccountEnabled -eq $false) } | select-object -Property AccountEnabled, DeviceId, DeviceOSVersion, DisplayName, ApproximateLastLogonTimestamp
	$RemoveAADDeviceList | Export-Excel -workSheetName "Stale Devices Removed" -Path $rdPath -ClearSheet -TableName "AAD Devices Removed" -AutoSize
	$RemoveAADDevice = Get-AzureADDevice -All:$true | where { ($_.ApproximateLastLogonTimeStamp -le $Days) -and ($_.AccountEnabled -eq $false) } | select-object -ExpandProperty ObjectID
	
	foreach ($DisabledDevice in $RemoveAADDevice)
	{
		Remove-AzureADDevice -ObjectID $DisabledDevice
	}
	Send-MailMessage -From $From -To $To -Subject $rdSubject -SmtpServer $SMTPServer -Port $SMTPPort -Credential $ECred -Attachments $rdPath -UseSsl
}

