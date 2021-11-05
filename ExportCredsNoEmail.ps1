Read-Host -Prompt "Enter Script Password" -AsSecureString | ConvertFrom-SecureString | Out-File ".\Scred.txt"


