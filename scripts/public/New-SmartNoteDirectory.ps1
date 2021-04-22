function New-SmartNoteDirectory {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([string])]

    Param (
        [Parameter(Mandatory)]
        [string] $Path
    )

    if (-not $PSBoundParameters.ContainsKey('ErrorAction')) { [System.Management.Automation.ActionPreference] $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop }
    if (-not $PSBoundParameters.ContainsKey('InformationAction')) { [System.Management.Automation.ActionPreference] $InformationPreference = [System.Management.Automation.ActionPreference]::Continue }
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { [System.Management.Automation.ActionPreference] $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') } else { [bool] $Verbose = $true }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { [System.Management.Automation.ActionPreference] $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { [System.Management.Automation.ActionPreference] $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }

    if ($PSCmdlet.ShouldProcess($Path, 'Creates a new smart note directory')) {
        try {
            if (-not (Test-Path -Path $Path)) {
                $null = New-Item -Path $Path -ItemType 'Directory'
            }

            [string[]] $Subfolders = @('daily-notes', 'inbox', 'reference', 'slip-box')
            foreach ($Folder in $Subfolders) {
                [string] $FolderPath = Join-Path -Path $Path -ChildPath $Folder

                if (-not (Test-Path -Path $FolderPath)) {
                    $null = New-Item -Path $FolderPath -ItemType 'Directory'
                }
            }

            [string[]] $HelperFiles = @('.topics', '.keywords', '.tags')
            foreach ($File in $HelperFiles) {
                [string] $FilePath = Join-Path -Path $Path -ChildPath $File

                if (-not (Test-Path -Path $FilePath)) {
                    [System.IO.FileInfo] $HelperFile = New-Item -Path $FilePath -ItemType 'File' -Value '{}'
                    $HelperFile.Attributes = @($HelperFile.Attributes, [System.IO.FileAttributes]::Hidden)
                }
            }

            return (Get-Item -Path $Path).Path
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
