Read-Host -Prompt "Enter Sender Email Password" -AsSecureString | ConvertFrom-SecureString | Out-File ".\Ecred.txt"
