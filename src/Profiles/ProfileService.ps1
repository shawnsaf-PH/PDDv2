function Get-Profiles {

    param(
        [string]$ProfileDirectory
    )

    Get-ChildItem `
        -Path $ProfileDirectory `
        -Filter "*.ini" `
        -File | Select-Object -ExpandProperty BaseName
}

function Read-Profile {

    param(
        [Parameter(Mandatory)]
        [string]$ProfilePath
    )

    $selectedApplications = @()

    $inMainSection = $false

    Get-Content $ProfilePath | ForEach-Object {

        $line = $_.Trim()

        if ([string]::IsNullOrWhiteSpace($line)) {
            return
        }

        if ($line.StartsWith(";")) {
            return
        }

        if ($line -eq "[MAIN]") {

            $inMainSection = $true
            return
        }

        if ($line.StartsWith("[")) {

            $inMainSection = $false
            return
        }

        if ($inMainSection) {

            $parts = $line.Split("=", 2)

            if ($parts.Count -eq 2) {

                if ($parts[1].ToUpper() -eq "TRUE") {

                    $selectedApplications += $parts[0]
                }
            }
        }
    }

    return $selectedApplications
}

function Select-ProfileApplications {

    param(
        [Parameter(Mandatory)]
        [array]$Applications,

        [Parameter(Mandatory)]
        [array]$SelectedApplicationNames
    )

    foreach ($application in $Applications) {

if ($application.Name -in $SelectedApplicationNames) {

    $application.Selected = $true
    } else {
            $application.Selected = $false
        }
    }
}