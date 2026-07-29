. "$PSScriptRoot\DeploymentResolver.ps1"
. "$PSScriptRoot\DeploymentExecutor.ps1"
. "$PSScriptRoot\DeploymentLogger.ps1"
. "$PSScriptRoot\..\Models\DeploymentExecutionResult.ps1"

function Invoke-DeploymentManifest {

    param(
        [Parameter(Mandatory)]
        [object]$Manifest,

        [Parameter(Mandatory)]
        [object]$Configuration,

        [Parameter(Mandatory)]
        [object]$ProgressWindow
    )

    $results = @()

    $failedApplications = @()

    foreach ($step in $Manifest.Steps) {

        $resolved =
            Resolve-DeploymentStep `
                -Step $step `
                -Configuration $Configuration

        if (-not $resolved.ApplicationPathExists) {

            $failedApplications +=
                "$($step.Name) - Application path not found"

            $result =
                [DeploymentExecutionResult]::new()

            $result.ApplicationName =
                $step.Name

            $result.Success = $false

            $result.ExitCode = -1

            $result.Executable =
                "Application Path Not Found"

            $result.FailureReason =
                "Application path not found"

            $results += $result

            Write-DeploymentLog `
                -Result $result `
                -Configuration $Configuration

            continue
        }

        if (-not $resolved.MachineExeExists) {

            $failedApplications +=
                "$($step.Name) - Machine executable not found"

            $result =
                [DeploymentExecutionResult]::new()

            $result.ApplicationName =
                $step.Name

            $result.Success =
                $false

            $result.ExitCode =
                -2

            $result.Executable =
                $resolved.MachineExePath

            $result.Arguments =
                $resolved.MachineExeArguments

            $result.FailureReason =
                "Machine executable not found"

            $results +=
                $result

            Write-DeploymentLog `
                -Result $result `
                -Configuration $Configuration

            continue
        }

        try {

            if ($null -ne $ProgressWindow) {

                $currentTextBlock =
                    $ProgressWindow.FindName(
                        "CurrentApplicationTextBlock"
                    )

                $progressTextBlock =
                    $ProgressWindow.FindName(
                        "ProgressTextBlock"
                    )

                $currentTextBlock.Text =
                    $step.Name

                $progressTextBlock.Text =
                    "$($results.Count + 1) of $($Manifest.Steps.Count)"

                $ProgressWindow.Dispatcher.Invoke(
                    [Action]{}
                )
            }

            Write-Host ""
            Write-Host "Executing:" $step.Name

            $result =
                Invoke-DeploymentStep `
                    -ResolvedStep $resolved

            Write-DeploymentLog `
                -Result $result `
                -Configuration $Configuration

            $results += $result
        }
        catch {

            $failedApplications +=
                "$($step.Name) - $($_.Exception.Message)"

            $result =
                [DeploymentExecutionResult]::new()

            $result.ApplicationName =
                $step.Name

            $result.Success =
                $false

            $result.ExitCode =
                -999

            $result.Executable =
                $resolved.MachineExePath

            $result.Arguments =
                $resolved.MachineExeArguments

            $result.FailureReason =
                $_.Exception.Message

            $results +=
                $result

            Write-DeploymentLog `
                -Result $result `
                -Configuration $Configuration

            continue
        }
    }
    
    return $results
}