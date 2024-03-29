***Note: Any code you need to enter will be between a set of arrows.***

HOW TO UPDATE:

1. Open the AADStaleDevices folder
2. Right-click on AADStaleDevices.ps1 and click Edit
3. Line 52: Update the email of the account with appropriate permissions to
   execute the script
8. Launch Powershell as an Administrator
9. Type -> cd "C:\Users\Public\Desktop\AADStaleDevices\ <- and hit Enter
10. Type -> .\ExportPasswordNoEmail.ps1 <- and hit Enter
11. Enter the password for an account with appropriate permissions to execute
   the script and hit Enter


HOW TO EXECUTE:

AADStaleDevices.ps1
[-Threshold <INT>] REQUIRED: Specifies how far back you want to check in days
[-Verify] Report that returns devices older than specified Threshold in .\Exports\
[-VerifyDisabled] Report that returns disabled devices older than specifed Threshold in .\Exports\
[-DisableDevices] Disables devices older than specified Threshold and exports report in .\Exports\
[-RemoveDevices] Deletes ONLY disabled devices that are older than specified Threshold and exports report in .\Exports\
[-UseCreds] Uses saved credentials if you completed the HOW TO UPDATE steps; else prompts for credentials to execute script

USE AS A SCHEDULED TASK:

***Note: You'll want to create a task for disabling and a second task for deleting. You must use -UseCreds flag for these tasks.***

1. Open Task Scheduler
2. Click "New task" on the right-hand side
3. Name the task, under securtiy options check "run whether logged in or not" and "run under highest privileges" and set OS as Windows 10
4. On Triggers tab, add the schedule you want to run this script. Ex., Every second Monday of the month at noon to disable devices
5. On Actions tab type Powershell for the program to launch, under arguments type:
   -> ExecutionPolicy Bypass -Command "<Path to script>AADStaleDevices.ps1 -Threshold <your threshold> -DisableDevices -UseCreds" <-

Examples:
-> AADStaleDevices.ps1 -Threshold 120 -Verify <- This would generate a report of all devices older than 120 days and require you to enter a login

-> AADStaleDevices.ps1 -Threshold 120 -VerifyDisabled -UseCreds <- This would generate a report of all *disabled* devices older than 120
days and used saved credentials

-> AADStaleDevices.ps1 -Threshold 120 -DisableDevices -UseCreds <- This would disable all devices older than 120 days, using saved creds,
and generate a report afterwards

-> AADStaleDevices.ps1 -Threshold 120 -RemoveDevices -UseCreds <- This would delete all *disabled* devices older than 120 days, using saved 
creds, and generate a report afterwards
