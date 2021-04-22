#Requires -Modules psake

Invoke-PSake -buildFile ('{0}\SmartNotes.Build.ps1' -f $PSScriptRoot) -taskList Publish
