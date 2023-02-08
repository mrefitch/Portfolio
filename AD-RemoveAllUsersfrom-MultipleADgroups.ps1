#################################
### This removes ALL members from MULTIPLE Active Directory Groups.
### Created By: Eric Fitch    8-Feb-2023
################################

#Variables - The AD group names.
    $Group1 = "SG_SP_HR_Managers_with_Staff_in_AU"
    $Group2 = "SG_SP_HR_Managers_with_Staff_in_CA"
    $Group3  = "SG_SP_HR_Managers_with_Staff_in_EU"
    $Group4  = "SG_SP_HR_Managers_with_Staff_in_SRI"
    $Group5  = "SG_SP_HR_Managers_with_Staff_in_US"
    $AllGroups = @($Group1,$Group2,$Group3,$Group4,$Group5)

#Get a count of each group's members before taking action.
foreach ($Group in $AllGroups) {
    $GroupMembers = Get-ADGroupMember -Identity $Group
    Write-Host "BEFORE taking action on $Group, the group's membership =" $GroupMembers.Count
    }

#The magic happens here.  Remove ALL members from ALL of the groups.
foreach ($Group in $AllGroups) {
    Remove-ADGroupMember -Identity $Group -Members (Get-ADGroupMember -Identity $Group) -Confirm
    }

#Get a count of each group's members after taking action.
foreach ($Group in $AllGroups) {
    $GroupMembers = Get-ADGroupMember -Identity $Group
    Write-Host "AFTER taking action on $Group, the group's membership =" $GroupMembers.Count
    }

##########################################
### The End.  Cert Signature below.
##########################################