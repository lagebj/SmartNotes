function ConvertToSmartNote {
    [CmdletBinding()]
    [OutputType([SmartNote])]

    Param (
        [Parameter(Mandatory, Position = 0)]
        [string] $Path
    )

    try {
        [regex] $MetadataRegex = [regex]::new('(?i)(\w+)(?::)(.*)')
        [string] $Name = Split-Path -Path $Path -LeafBase
        [string[]] $Content = Get-Content -Path $Path

        [int] $i = 0
        do {
            if ($Content[$i] -match '[-]{3,}') {
                [int] $MetadataSplitLineNumber = $i
            } else {
                $i++
            }
        } until (($MetadataSplitLineNumber) -or ($i -gt $Content.Count))

        if ($MetadataSplitLineNumber) {
            [System.Collections.Generic.Dictionary[string, string]] $Metadata = @{}

            for ($i = 0; $i -le $MetadataSplitLineNumber; $i++) {
                if (-not ($Content[$i] -eq [string]::Empty)) {
                    [System.Text.RegularExpressions.Match] $RegexMatch = $MetadataRegex.Match($Content[$i])
                    $Metadata.Add($RegexMatch.Groups[1].Value.Trim(), $RegexMatch.Groups[2].Value.Trim())
                }
            }

            [string[]] $ContentBody = $Content[($MetadataSplitLineNumber + 1)..$Content.Count]
        } else {
            [string[]] $ContentBody = $Content
        }

        [SmartNote] $SmartNote = [SmartNote]::new($Name, $Path, 'Permanent')

        if ($Metadata) {
            switch ($Metadata.Keys) {
                'Author' { $SmartNote.$PSItem = $Metadata[$PSItem] }
                'Topic' { $SmartNote.$PSItem = $Metadata[$PSItem] }
                'Keywords' { $SmartNote.$PSItem = $Metadata[$PSItem] }
                'URL' { $SmartNote.$PSItem = $Metadata[$PSItem] }
                'Links' { $SmartNote.$PSItem = $Metadata[$PSItem] }
                'Tags' { $SmartNote.$PSItem = $Metadata[$PSItem] }
            }
        }

        $SmartNote.Content = ($ContentBody | Out-String)

        return $SmartNote
    } catch {
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }
}
