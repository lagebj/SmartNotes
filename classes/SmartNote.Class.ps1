class SmartNote {
    hidden [string] $Path

    [string] $Name

    [ValidateSet('Fleeting', 'Literature', 'Permanent')]
    [string] $NoteType

    [string] $Author

    [string] $Topic

    [string[]] $Keywords

    [string[]] $URL

    [string[]] $Links

    [string[]] $Tags

    [string] $Content

    SmartNote ($Name, $Path, $NoteType) {
        $this.Name = $Name
        $this.Path = $Path
        $this.NoteType = $NoteType
    }
}