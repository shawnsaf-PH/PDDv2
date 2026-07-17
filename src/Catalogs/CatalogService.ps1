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

function Get-AllCatalogApplications {

    param(
        [Parameter(Mandatory)]
        [string]$CatalogDirectory,

        [Parameter(Mandatory)]
        [string[]]$Catalogs
    )

    $applications = @()

    foreach ($catalog in $Catalogs) {

        $catalogPath = Join-Path `
            $CatalogDirectory `
            $catalog

        if (Test-Path $catalogPath) {

            $applications += Get-CatalogApplications -Path $catalogPath
        }
    }

    return $applications
}

function Get-DeployableApplications {

    param(
        [Parameter(Mandatory)]
        [array]$Applications
    )

    return $Applications |
        Where-Object {

            $application = $_

            -not (
                [string]::IsNullOrWhiteSpace($application.Department) -and
                [string]::IsNullOrWhiteSpace($application.Directory) -and
                [string]::IsNullOrWhiteSpace($application.MachineExe) -and
                [string]::IsNullOrWhiteSpace($application.UserExe)
            )
        }
}