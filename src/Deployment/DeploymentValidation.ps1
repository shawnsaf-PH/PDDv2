. "$PSScriptRoot\..\Models\ValidationResult.ps1"
. "$PSScriptRoot\DeploymentResolver.ps1"

function Test-DeploymentManifest {

    param(
        [Parameter(Mandatory)]
        [DeploymentManifest]$Manifest,

        [Parameter(Mandatory)]
        [PlatformConfiguration]$Configuration
    )

    $results = @()

    foreach ($step in $Manifest.Steps) {

        $resolved =
            Resolve-DeploymentStep `
                -Step $step `
                -Configuration $Configuration

        $result =
            [ValidationResult]::new()

        $result.ApplicationName =
            $step.Name

        if (-not $resolved.ApplicationPathExists) {

            $result.Valid = $false
            $result.Message = "Application directory not found"
        }
        elseif (-not $resolved.MachineExeExists -and
                -not [string]::IsNullOrWhiteSpace($step.MachineExe)) {

            $result.Valid = $false
            $result.Message = "Machine executable not found"
        }
        else {

            $result.Valid = $true
            $result.Message = "OK"
        }

        $results += $result
    }

    return $results
}