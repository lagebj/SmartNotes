function ConvertTo-PermanentNote {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([void])]

    Param (
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [ValidateSet('Literature', 'Fleeting')]
        [string] $NoteType,

        [Parameter()]
        [string] $FromString,

        [Parameter()]
        [string] $Topic,

        [Parameter()]
        [string[]] $Keywords,

        [Parameter()]
        [string[]] $Links,

        [Parameter()]
        [string[]] $Tags
    )

    if (-not $PSBoundParameters.ContainsKey('ErrorAction')) { [System.Management.Automation.ActionPreference] $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop }
    if (-not $PSBoundParameters.ContainsKey('InformationAction')) { [System.Management.Automation.ActionPreference] $InformationPreference = [System.Management.Automation.ActionPreference]::Continue }
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { [System.Management.Automation.ActionPreference] $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') } else { [bool] $Verbose = $true }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { [System.Management.Automation.ActionPreference] $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { [System.Management.Automation.ActionPreference] $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }

    if ($PSCmdlet.ShouldProcess($Path, ('Converts note {0} to permanent note') -f $Name)) {
        try {
            [System.IO.FileInfo] $Note = Get-ChildItem -Path $Path -Filter ('{0}.md' -f $Name) -File -Recurse
            [SmartNote] $SmartNote = ConvertToSmartNote $Note.FullName

            switch ($PSBoundParameters.Keys) {
                'Topic' { $SmartNote.$PSItem = $PSBoundParameters[$PSItem] }
                'Keywords' { $SmartNote.$PSItem = $PSBoundParameters[$PSItem] }
                'Links' { $SmartNote.$PSItem = $PSBoundParameters[$PSItem] }
                'Tags' { $SmartNote.$PSItem = $PSBoundParameters[$PSItem] }
            }

            if ($PSBoundParameters.ContainsKey('FromString')) {
                [string] $SelectedContent = [regex]::new(('(?i){0}') -f $FromString).Match($SmartNote.Content).Groups[0].Value

                if ($SelectedContent) {
                    [string] $SmartNote.Name = $SelectedContent
                    $SmartNote.Content = $SelectedContent
                }
            }

            New-SmartNote -Name $SmartNote.Name -Path $Path -NoteType $NoteType -Topic $SmartNote.Topic -Keywords $SmartNote.Keywords -Links $SmartNote.Links -Tags $SmartNote.Tags -Content $SmartNote.Content -Permanent

            $Note | Remove-Item -Force
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
