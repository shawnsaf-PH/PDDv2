. "$PSScriptRoot\DeploymentResolver.ps1"
. "$PSScriptRoot\DeploymentExecutor.ps1"
. "$PSScriptRoot\DeploymentLogger.ps1"

function Invoke-DeploymentManifest {

    param(
        [Parameter(Mandatory)]
        [object]$Manifest,

        [Parameter(Mandatory)]
        [object]$Configuration
    )

    $results = @()

    foreach ($step in $Manifest.Steps) {

        Write-Host ""
        Write-Host "Executing:" $step.Name

        $resolved =
            Resolve-DeploymentStep `
                -Step $step `
                -Configuration $Configuration

        if (-not $resolved.ApplicationPathExists) {

            Write-Warning "Application path not found: $($step.Name)"
            continue
        }

        if (-not $resolved.MachineExeExists) {

            Write-Warning "Machine executable not found: $($step.Name)"
            continue
        }

        try {

            $result =
                Invoke-DeploymentStep `
                    -ResolvedStep $resolved

            Write-DeploymentLog `
                -Result $result `
                -Configuration $Configuration

            $results += $result
        }
        catch {

            Write-Warning $_

            continue
        }
    }

    return $results
}