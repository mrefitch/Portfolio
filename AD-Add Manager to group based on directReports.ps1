###########################
### NAME:  ADDS-Add Manager to group based on directReports.ps1
### This script adds users with directReports (Managers) to group(s), based on the location of the direct reports.
### i.e.  If a manager has a direct report in Canada, the manager will be add to the Canada group.
### These groups then give the managers access to Country-specific HR SharePoint sites, so the managers can read HR items relevant to their direct reports.
###########################

#Variables - Region Groups that managers can be added to:
    $AUgroup = "SG_SP_HR_Managers_with_Staff_in_AU"
    $CAgroup = "SG_SP_HR_Managers_with_Staff_in_CA"
    $EUgroup = "SG_SP_HR_Managers_with_Staff_in_EU"
    $SRIgroup = "SG_SP_HR_Managers_with_Staff_in_SRI"
    $USgroup = "SG_SP_HR_Managers_with_Staff_in_US"
    $AllGroups = @($AUgroup,$CAgroup,$EUgroup,$SRIgroup,$USgroup)

#Check #1:  Empty Manager field.  Check if any active internal users (staff) do not have a Manager defined.
#All Internal users (staff) should have a manager (except for Jake M.)
    $OUname = "OU=Internal,OU=InEight Users,DC=harddollar,DC=local"
    $NoManager = Get-ADUser -Filter {Enabled -eq $true} -SearchBase $OUname -Properties Enabled,Manager | `
    Where-Object ({$_.Manager -eq $null}) | `
    Select-Object Name,SamAccountName,Enabled,Manager
    Write-Warning "The following internal users (staff) do NOT have a manager defined. (You can ignore Jake Macholtz.)"
    $NoManager

#Check #2:  Disabled users that still have a Manager.  If used, the offboarding script clears the manager field. 
#Offboarded staff should not have a manager defined.
    #Get the AD users that are disabled AND have data in the Manager field.
    $AccountsToCleanUp = Get-ADUser -Filter {Enabled -eq $false} -Properties Enabled,Manager | `
        Where-Object ({$_.Manager -ne $null}) | `
        Select-Object Name,SamAccountName,Enabled,Manager
    #Count the number of accounts to clean up and write it to the screen
    $Count = ($AccountsToCleanUp).count
    if ($Count -eq 0){Write-warning "DISABLED accounts that still have a manager:  $Count"}
    else {Write-Warning "The following DISABLED accounts still have a Manager: " $AccountsToCleanUp}

### Get active AD users who have direct reports = Managers
    $Managers = Get-ADUser -Filter {Enabled -eq $true} -Properties SamAccountName,Name,DirectReports -SearchBase "OU=Internal,OU=InEight Users,DC=harddollar,DC=local" | `
    Select SamAccountName,Name,DirectReports | `
    Where-Object ({$_.DirectReports -ne $null})


########  Testing:  A short array of managers used to test this script. #######
   # $TestManagers = @('Roger.Tillmon', 'Kevin.Waite', 'Matthew.Hess') | `
   # Get-ADUser -Properties SamAccountName,Name,DirectReports | `
   #     Select SamAccountName,Name,DirectReports
##########################################

#### The Magic happens here.  
#### Add managers to the region groups if manager has a direct report in that region.
foreach ($Boss in $Managers) {                    #### Change $Managers to  $TestManagers to test this section with the test array.
    foreach ($Minion in $boss.DirectReports) {
        If ($Minion -like "*Australia*") {Add-ADGroupMember -Identity $AUgroup -Members $boss.SamAccountName}
        elseif ($Minion -like "*Canada*") {Add-ADGroupMember -Identity $CAgroup -Members $boss.SamAccountName}
        elseif ($Minion -like "*Europe*") {Add-ADGroupMember -Identity $EUgroup -Members $boss.SamAccountName}
        elseif ($Minion -like "*Lanka*") {Add-ADGroupMember -Identity $SRIgroup -Members $boss.SamAccountName}
        elseif ($Minion -like "*United*") {Add-ADGroupMember -Identity $USgroup -Members $boss.SamAccountName}
        Else {Write-Warning "$Minion Does not reside in a known Internal Region OU!!"}
    }
}
## You may need to REFRESH to OUs in AD DS to see the group memberships updated by this script.

################ Need to work on this section......  ##############################################
#######  The following is not complete and does not work....
####### Goal:  Remove any managers who no longer have a direct report in a region group.
   # $GroupMembers = Get-ADGroupMember -Identity $AUgroup
   # foreach ($Person in $GroupMembers) {
   #     $ManagerToCheck = Get-ADUser -Identity $Person.SamAccountName -Properties SamAccountName,Name,DirectReports | `
   #     Select SamAccountName,Name,DirectReports}
    #        foreach ($Report in $ManagerToCheck.DirectReports) {
    #        If ($ManagerToCheck.DirectReports -like "*Australia*") {$AUvalue = 1
            
            #{Remove-ADGroupMember -Identity $AUgroup -Members $Person.SamAccountName}
        #Else {Write-Host "Cleanup complete for $AUgroup"
        #}
 #   }