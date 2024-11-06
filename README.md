# get-system

This provides some functions to get nt system shell or run commands as nt system.

You'll need ServiceUI.exe which you can find here https://www.microsoft.com/en-us/download/details.aspx?id=54259

it's also included here for convenience.

Import-Module ./get-system.ps1

Get-System

Run-NtSystemCommand -Command $commands
