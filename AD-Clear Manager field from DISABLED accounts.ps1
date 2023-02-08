### For DISABLED User Accounts, clear the 'Manager' field.
### Manifested into existence by:  E. Fitch  2-Feb-2023

#Paramaters
    $LoggingPath = "E:\PowerShell_Resources\ScriptLogs\AD-OnPrem Clear Manager Field from DISBLED Accounts.txt"  #may need to change path, make universal.

#Start logging
    Start-Transcript -Append -Path $LoggingPath

#Get the AD users that are disabled AND have data in the Manager field.
    $AccountsToCleanUp = Get-ADUser -Filter {Enabled -eq $false} -Properties Enabled,Manager | `
        Where-Object ({$_.Manager -ne $null}) | `
        Select-Object Name,SamAccountName,Enabled,Manager
#Count the number of accounts to clean up and write it to the screen
    $Count = ($AccountsToCleanUp).count
Write-Host
Write-Host "DISABLED accounts that still have a manager:  $Count"
Write-Host


#############################################################
### The following removes the manager for each disabled user account
#############################################################
     
    foreach ($Account in $AccountsToCleanUp)
    {
    $Mgr = Get-ADUser -Identity $Account.SamAccountName -Properties Name,Manager | Select-Object Manager
    Write-Host "For Disabled account: $Account"
    Write-Host "    Removing manager: $Mgr"
    Write-Host "*******************************"
    Set-ADUser -Identity $Account.SamAccountName -Manager $null
    }


#One more time:  Get the AD users that are disabled AND have data in the Manager field.
    $AccountsToCleanUp = Get-ADUser -Filter {Enabled -eq $false} -Properties Enabled,Manager | `
        Where-Object ({$_.Manager -ne $null}) | `
        Select-Object Name,SamAccountName,Enabled,Manager
#One more Time:  Count the number of account to clean up
    $Count = ($AccountsToCleanUp).count
Write-Host
Write-Host "After clean-up, DISABLED accounts that still have a manager:  $Count"
Write-Host

#Stop logging
    Stop-Transcript