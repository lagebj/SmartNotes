function Get-NotesByTopic {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]

    Param (
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string[]] $Topic
    )

    if (-not $PSBoundParameters.ContainsKey('ErrorAction')) { [System.Management.Automation.ActionPreference] $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop }
    if (-not $PSBoundParameters.ContainsKey('InformationAction')) { [System.Management.Automation.ActionPreference] $InformationPreference = [System.Management.Automation.ActionPreference]::Continue }
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { [System.Management.Automation.ActionPreference] $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') } else { [bool] $Verbose = $true }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { [System.Management.Automation.ActionPreference] $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { [System.Management.Automation.ActionPreference] $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }

    if ($PSCmdlet.ShouldProcess($Path, 'Gets smart notes by topic')) {
        try {
            [pscustomobject] $Topics = Get-Content -Path (Join-Path -Path $Path -ChildPath '.topic') | ConvertFrom-Json

            [System.Collections.Generic.List[pscustomobject]] $TopicList = @()

            foreach ($Word in $Topic) {
                foreach ($Object in $Topics.$Word) {
                    [pscustomobject] $TopicObject = [pscustomobject] @{
                        Topic = $Word
                        NoteName = $Object.Name
                        FilePath = $Object.Path
                    }

                    $TopicList.Add($TopicObject)
                }
            }

            return $TopicList
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
