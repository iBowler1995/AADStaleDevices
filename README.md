# AADStaleDevices
This repository is for managing stale devices in AzureAD.

***Note: Any code you need to enter will be between a set of arrows -> Write-Host Like This! <-***

HOW TO UPDATE:

1. Open the AADStaleDevices folder
2. Right-click on AADStaleDevices.ps1 and click Edit
3. Line 52: Update the email of the account with appropriate permissions to
   execute the script (this is optional, you can run the script without -UseCreds. To skip, leave blank and hit 
   enter. Ignore red error text and continue to step 4)
4. Line 55: Update the email of the account that will be sending reports (This is required to send reports in
   email. Use AADStaleDevicesNoEmail.ps1 if you don't wish to use this feature)
5. Line 56: Update the email that will receive the reports
6. Line 57: Update the SMTP server (not required if the account sending the
   reports is Microsoft 365)
7. Line 58: Update the SMTP port (if your organization utilizes a different
   port)
8. Launch Powershell as an Administrator
9. Type -> cd "C:\Users\Public\Desktop\AADStaleDevices\ <- and hit Enter
10. Type -> .\ExportPassword.ps1 <- and hit Enter
11. Enter the password for an account with appropriate permissions to execute
   the script and hit Enter
12. Enter the password for the email account that will be sending reports

HOW TO EXECUTE:

AADStaleDevices.ps1
[-Threshold <INT>] REQUIRED: Specifies how far back you want to check in days
[-Verify] Report that returns devices older than specified Threshold in .\Exports\ and emails report
[-VerifyDisabled] Report that returns disabled devices older than specifed Threshold in .\Exports\ and emails report
[-DisableDevices] Disables devices older than specified Threshold and exports report in .\Exports\ and emails report
[-RemoveDevices] Deletes ONLY disabled devices that are older than specified Threshold and exports report in .\Exports\ and emails report
[-UseCreds] Uses saved credentials if you completed the HOW TO UPDATE steps; else prompts for credentials to execute script

Examples:
-> AADStaleDevices.ps1 -Threshold 120 -Verify <- This would generate a report of all devices older than 120 days and require you to enter a login

-> AADStaleDevices.ps1 -Threshold 120 -VerifyDisabled -UseCreds <- This would generate a report of all *disabled* devices older than 120
days and used saved credentials

-> AADStaleDevices.ps1 -Threshold 120 -DisableDevices -UseCreds <- This would disable all devices older than 120 days, using saved creds,
and generate a report afterwards

-> AADStaleDevices.ps1 -Threshold 120 -RemoveDevices -UseCreds <- This would delete all *disabled* devices older than 120 days, using saved 
creds, and generate a report afterwards
