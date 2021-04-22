foreach ($Folder in @('classes', 'scripts\private', 'scripts\public')) {
    [string] $Root = Join-Path -Path $PSScriptRoot -ChildPath $Folder
    if (Test-Path -Path $Root) {
        Get-ChildItem -Path $Root -Filter '*.ps1' -Recurse | Where-Object Name -NotLike '*.Tests.ps1' | ForEach-Object {. $_.FullName}
    }
}

Export-ModuleMember -Function (Get-ChildItem -Path ('{0}\scripts\public\*.ps1' -f $PSScriptRoot)).BaseName