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
