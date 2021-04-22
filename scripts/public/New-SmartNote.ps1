function New-SmartNote {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [OutputType([void])]

    Param (
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [ValidateSet('Fleeting', 'Literature')]
        [string] $NoteType,

        [Parameter()]
        [string] $Author,

        [Parameter()]
        [string] $Topic,

        [Parameter()]
        [string[]] $Keywords,

        [Parameter()]
        [string[]] $URL,

        [Parameter()]
        [string[]] $Links,

        [Parameter()]
        [string[]] $Tags,

        [Parameter()]
        [string] $Content,

        [Parameter()]
        [switch] $Permanent
    )

    if (-not $PSBoundParameters.ContainsKey('ErrorAction')) { [System.Management.Automation.ActionPreference] $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop }
    if (-not $PSBoundParameters.ContainsKey('InformationAction')) { [System.Management.Automation.ActionPreference] $InformationPreference = [System.Management.Automation.ActionPreference]::Continue }
    if (-not $PSBoundParameters.ContainsKey('Verbose')) { [System.Management.Automation.ActionPreference] $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') } else { [bool] $Verbose = $true }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { [System.Management.Automation.ActionPreference] $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { [System.Management.Automation.ActionPreference] $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }

    if ($PSCmdlet.ShouldProcess($Path, 'Creates a new smart note')) {
        try {
            [SmartNote] $SmartNote = [SmartNote]::new($Name, $Path, $NoteType)

            switch ($PSBoundParameters.Keys) {
                'Author' { $SmartNote.$PSItem = $PSBoundParameters[$PSItem] }
                'Topic' { $SmartNote.$PSItem = $PSBoundParameters[$PSItem] }
                'Keywords' { $SmartNote.$PSItem = $PSBoundParameters[$PSItem] }
                'URL' { $SmartNote.$PSItem = $PSBoundParameters[$PSItem] }
                'Links' { $SmartNote.$PSItem = $PSBoundParameters[$PSItem] }
                'Tags' { $SmartNote.$PSItem = $PSBoundParameters[$PSItem] }
                'Content' { $SmartNote.$PSItem = $PSBoundParameters[$PSItem] }
            }

            if (-not ($PSBoundParameters.ContainsKey('Permanent'))) {
                if ($SmartNote.NoteType -eq 'Fleeting') {
                    [string] $NotePath = Join-Path -Path $Path -ChildPath 'daily-notes' -AdditionalChildPath ('{0}.md' -f $SmartNote.Name)

                    $null = New-Item -Path $NotePath -ItemType 'File' -Value $SmartNote.Content
                } elseif ($SmartNote.NoteType -eq 'Literature') {
                    [string] $NotePath = Join-Path -Path $Path -ChildPath 'inbox' -AdditionalChildPath ('{0}.md' -f $SmartNote.Name)

                    $SmartNote.Content = @'
Author: {0}
URL: {1}
Links: {2}
Tags: {3}
---
{4}
'@ -f $SmartNote.Author, ($SmartNote.URL -join ', '), ($SmartNote.Links -join ', '), ($SmartNote.Tags -join ', '), $SmartNote.Content

                    $null = New-Item -Path $NotePath -ItemType 'File' -Value $SmartNote.Content
                }
            } else {
                if ($SmartNote.NoteType -eq 'Fleeting') {
                    [string] $NotePath = Join-Path -Path $Path -ChildPath 'slip-box' -AdditionalChildPath ('{0}.md' -f $SmartNote.Name)
                } elseif ($SmartNote.NoteType -eq 'Literature') {
                    [string] $NotePath = Join-Path -Path $Path -ChildPath 'reference' -AdditionalChildPath ('{0}.md' -f $SmartNote.Name)
                }

                [pscustomobject] $ExistingTopics = Get-Content -Path (Join-Path -Path $Path -ChildPath '.topics') | ConvertFrom-Json
                foreach ($Topic in $SmartNote.Topic) {
                    if ($ExistingTopics.$Topic) {
                        [System.Collections.Generic.List[pscustomobject]] $TopicObjects = @()

                        foreach ($Object in $ExistingTopics.$Topic) {
                            $TopicObjects.Add($Object)
                        }

                        if (-not ($ExistingTopics.$Topic.Name -contains $SmartNote.Name)) {
                            $TopicObjects.Add(@{Name = $SmartNote.Name; Path = $NotePath})
                        }

                        $ExistingTopics.$Topic = $TopicObjects
                    } else {
                        $ExistingTopics | Add-Member -MemberType 'NoteProperty' -Name $Topic -Value @(@{Name = $SmartNote.Name; Path = $NotePath})
                    }
                }
                $ExistingTopics | ConvertTo-Json -Depth 10 | Set-Content -Path (Join-Path -Path $Path -ChildPath '.topics')

                [pscustomobject] $ExistingKeywords = Get-Content -Path (Join-Path -Path $Path -ChildPath '.keywords') | ConvertFrom-Json
                foreach ($Keyword in $SmartNote.Keywords) {
                    if ($ExistingKeywords.$Keyword) {
                        [System.Collections.Generic.List[pscustomobject]] $KeywordObjects = @()

                        foreach ($Object in $ExistingKeywords.$Keyword) {
                            $KeywordObjects.Add($Object)
                        }

                        if (-not ($ExistingKeywords.$Keyword.Name -contains $SmartNote.Name)) {
                            $KeywordObjects.Add(@{Name = $SmartNote.Name; Path = $NotePath})
                        }

                        $ExistingKeywords.$Keyword = $KeywordObjects
                    } else {
                        $ExistingKeywords | Add-Member -MemberType 'NoteProperty' -Name $Keyword -Value @(@{Name = $SmartNote.Name; Path = $NotePath})
                    }
                }
                $ExistingKeywords | ConvertTo-Json -Depth 10 | Set-Content -Path (Join-Path -Path $Path -ChildPath '.keywords')

                [pscustomobject] $ExistingTags = Get-Content -Path (Join-Path -Path $Path -ChildPath '.tags') | ConvertFrom-Json
                foreach ($Tag in $SmartNote.Tags) {
                    if ($ExistingTags.$Tag) {
                        [System.Collections.Generic.List[pscustomobject]] $TagObjects = @()

                        foreach ($Object in $ExistingTags.$Tag) {
                            $TagObjects.Add($Object)
                        }

                        if (-not ($ExistingTags.$Tags.Name -contains $SmartNote.Name)) {
                            $TagObjects.Add(@{Name = $SmartNote.Name; Path = $NotePath})
                        }

                        $ExistingTags.$Tag = $TagObjects

                    } else {
                        $ExistingTags | Add-Member -MemberType 'NoteProperty' -Name $Tag -Value @(@{Name = $SmartNote.Name; Path = $NotePath})
                    }
                }
                $ExistingTags | ConvertTo-Json -Depth 10 | Set-Content -Path (Join-Path -Path $Path -ChildPath '.tags')

                if ($SmartNote.Links) {
                    [System.IO.FileInfo[]] $LinkedFiles = Get-ChildItem -Path $Path -Filter '*.md' -File -Recurse | Where-Object -FilterScript {$SmartNote.Links -contains $_.BaseName}
                    [string[]] $LinkedFilesLinks = foreach ($LinkedFile in $LinkedFiles) {
                        '[{0}]({1})' -f $LinkedFile.BaseName, ('{0}' -f (($LinkedFile.FullName.Split([System.IO.Path]::DirectorySeparatorChar)[-2..-1] -join '/') -replace '\s', '%20'))
                    }
                }

                $SmartNote.Content = @'
Topic: {0}
Keywords: {1}
Links: {2}
Tags: {3}
---
{4}
'@ -f $SmartNote.Topic, ($SmartNote.Keywords -join ', '), ($LinkedFilesLinks -join ', '), ($SmartNote.Tags -join ', '), $SmartNote.Content

                $SmartNote.NoteType = 'Permanent'

                $null = New-Item -Path $NotePath -ItemType 'File' -Value $SmartNote.Content
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}
