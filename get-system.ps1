# get cmd prompt as nt system in current session:

function Get-System{

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ServiceUIPath = "C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\ServiceUI.exe",

        [Parameter()]
        [string]$TaskName = "SystemCMD",

        [Parameter()]
        [string]$SessionID = (get-process -PID $pid).sessionid 
                
    )

    <#
    .SYNOPSIS
        Uses Microsoft's signed binary ServiceUI.exe to run commands as NT SYSTEM via a scheduled task. 

    .DESCRIPTION
        This cmdlet will create a scheduled task which will utilize ServiceUI.exe from Microsoft Deployment Toolkit (MDT) to run a command as NT System.
        You can provide any command you want to run, but defaults to cmd.exe. 

    .PARAMETER $ServiceUIPath
        The path where ServiceUI.exe can be found. Defaults to "C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\ServiceUI.exe".

    .PARAMETER $TaskName
        The name of the scheduled task to create. Defaults to "SystemCMD".

    .EXAMPLE
        Get-System
        Creates and runs scheduled task to pop cmd.exe as system.


#>

    Write-Host "Checking for ServiceUI.exe at $serviceUIpath..."

    if (!(Test-Path -Path $ServiceUIPath)){
        Write-Host "ServiceUI.exe not found at $ServiceUIPath"
        return
    } 

    Write-Host "ServiceUI.exe found at $ServiceUIPATH..."

        
    Write-Host "Using session $sessionID..."        


    Write-Host "Creating ScheduledTask $TaskName as SYSTEM which will run $Command in session $sessionID ..."

    $cmd = "c:\windows\system32\cmd.exe"

    $argument = "-session:$sessionID $cmd"

    $tasktrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 3am

    $taskaction = New-ScheduledTaskAction -Execute $ServiceUIPath -Argument "$argument"

    Register-ScheduledTask -User SYSTEM -TaskName $TaskName -Action $taskaction -Trigger $tasktrigger | out-null

    if (!(get-scheduledtask $TaskName -ea 0)){
        write-host "Failed to create ScheduledTask $TaskName as SYSTEM. Please run this script is run as administrator."
        return
    }

    Write-Host "Running scheduledtask $TaskName as SYSTEM..."

    #Run the task
    Start-ScheduledTask -TaskName $TaskName

    #Cleaning up
    Write-Host "Cleaning up...."

    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false

    if (get-scheduledtask $TaskName -ea 0){
        write-host "Failed to remove ScheduledTask $TaskName. You will need to remove it manually."
        return
    }

}

# plain old commands as system

function Run-NtSystemCommand{

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string] $ServiceUIPath = "C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\ServiceUI.exe",
        [Parameter(Mandatory = $False)]
        [string] $TaskName = "SystemCMD",
        [Parameter(Mandatory = $true)]
        [string] $Command        
    )

    <#
    .SYNOPSIS
        Uses a scheduled task to run a comand as NT System.

    .DESCRIPTION
        This cmdlet will run a command as NT System via a scheduled task.

    .PARAMETER $TaskName
        The name of the scheduled task to create. Defaults to "SystemCMD".

    .PARAMETER $Command
        The command to run.

    .EXAMPLE
        Run-NtSystemCommand -Command "net user testuser password123 /add"
        Creates and runs scheduled task to create new user as system.


#>
    


    Write-Host "Creating ScheduledTask $TaskName as SYSTEM which will run $Command..."

    $targetPath = "C:\windows\system32\cmd.exe"

    $argument = "/c $command"

    $tasktrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 3am

    $taskaction = New-ScheduledTaskAction -Execute $TargetPath -Argument "$argument"

    Register-ScheduledTask -User SYSTEM -TaskName $TaskName -Action $taskaction -Trigger $tasktrigger | out-null

    if (!(get-scheduledtask $TaskName -ea 0)){
        write-host "Failed to create ScheduledTask $TaskName as SYSTEM. Please run this script is run as administrator."
        return
    }

    Write-Host "Running scheduledtask $TaskName as SYSTEM..."

    #Run the task
    Start-ScheduledTask -TaskName $TaskName

    #Cleaning up
    Write-Host "Cleaning up...."

    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false

    if (get-scheduledtask $TaskName -ea 0){
        write-host "Failed to remove ScheduledTask $TaskName. You will need to remove it manually."
        return
    }

}