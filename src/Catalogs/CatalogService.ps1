. "$PSScriptRoot\CatalogParser.ps1"

function Get-CatalogApplications {

    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    return Read-CatalogFile -Path $Path
}

function Get-ApplicationsByDepartment {

    param(
        [Parameter(Mandatory)]
        [array]$Applications,

        [Parameter(Mandatory)]
        [string]$Department
    )

    return $Applications |
        Where-Object {
            $_.Department -eq $Department
        }
}

function Get-OptionalApplications {

    param(
        [Parameter(Mandatory)]
        [array]$Applications
    )

    return $Applications |
        Where-Object {
            $_.Optional
        }
}

function Find-Application {

    param(
        [Parameter(Mandatory)]
        [array]$Applications,

        [Parameter(Mandatory)]
        [string]$SearchText
    )

    return $Applications |
        Where-Object {
            $_.Name -like "*$SearchText*"
        }
}