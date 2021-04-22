function Get-NotesByKeyword {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]

    Param (
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string[]] $Keyword
    )

    if (-not $PSBoundParameters.ContainsKey('ErrorAction')) { [System.Management.Automation.ActionPreference] $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop }
    if (-not $PSBoundParameters.ContainsKey('InformationAction')) { [System.Management.Automation.ActionPreference] $InformationPreference = [System.Management.Automation.ActionPreference]::Continue }
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { [System.Management.Automation.ActionPreference] $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') } else { [bool] $Verbose = $true }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { [System.Management.Automation.ActionPreference] $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { [System.Management.Automation.ActionPreference] $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }

    if ($PSCmdlet.ShouldProcess($Path, 'Gets smart notes by keyword')) {
        try {
            [pscustomobject] $Keywords = Get-Content -Path (Join-Path -Path $Path -ChildPath '.keywords') | ConvertFrom-Json

            [System.Collections.Generic.List[pscustomobject]] $KeywordList = @()

            foreach ($Word in $Keyword) {
                foreach ($Object in $Keywords.$Word) {
                    [pscustomobject] $KeywordObject = [pscustomobject] @{
                        Keyword = $Word
                        NoteName = $Object.Name
                        FilePath = $Object.Path
                    }

                    $KeywordList.Add($KeywordObject)
                }
            }

            return $KeywordList
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
