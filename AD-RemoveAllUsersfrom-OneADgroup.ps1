#################################
### This removes ALL members from ONE Active Directory Group.  The user is prompted to enter the AD group name.
### Created By: Eric Fitch   8-Feb-2023
################################

#Start logging
    $ScriptName = "AD-RemoveAllUsersfrom-OneADgroup"    #Update this to match the script name!!
    $Timestamp = Get-Date -Format "yyyy-MMM-dd--HH.MM.s"
    $FileName = $ScriptName + "-" + $Timestamp + ".txt"
    $LoggingPath = "C:\Temp\ScriptLogs\" + $FileName
    Start-Transcript -Path $LoggingPath

#Variables - Get Input from User.
    $ADGroup = Read-Host  "Please enter the name of the group, like this:  SG_groupName   --->>"

#Get a count of the group members before taking action.
    $ADGroupMembers = Get-ADGroupMember -Identity $ADGroup
    Write-Host "**BEFORE taking action, the group's membership count =" $ADGroupMembers.Count

#For the Log, record the AD group members before taking any action.
    Write-Host "**The group originally contained these members:"
    foreach ($Member in $ADGroupMembers) {
        $Name = Get-ADUser -Identity $Member -Properties SamAccountName | Select-Object SamAccountName
        Write-Host $Name.SamAccountName
        }

#The magic happens here.  Remove ALL members from the group.
    Remove-ADGroupMember -Identity $ADGroup -Members (Get-ADGroupMember -Identity $ADGroup) -Confirm

#Get a count of the group members after taking action.
    $ADGroupMembers = Get-ADGroupMember -Identity $ADGroup
    Write-Host "**AFTER taking action, the group's membership count =" $ADGroupMembers.Count

#Stop logging
    Stop-Transcript

##########################################
### The End.  Cert Signature below.
##########################################