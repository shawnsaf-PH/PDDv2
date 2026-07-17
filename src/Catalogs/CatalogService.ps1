. "$PSScriptRoot\CatalogParser.ps1"

function Get-CatalogApplications {

    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    return Read-CatalogFile -Path $Path
}