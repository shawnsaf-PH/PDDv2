. "$PSScriptRoot\DeploymentResolver.ps1"
. "$PSScriptRoot\DeploymentExecutor.ps1"
. "$PSScriptRoot\DeploymentLogger.ps1"
. "$PSScriptRoot\..\Models\DeploymentExecutionResult.ps1"
. "$PSScriptRoot\DeploymentStateService.ps1"
. "$PSScriptRoot\..\Models\DeploymentState.ps1"

function Invoke-DeploymentManifest {

    param(

        [Parameter(Mandatory)]
        [object]$Manifest,

        [Parameter(Mandatory)]
        [object]$Configuration,

        [string]$SerialNumber,

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
            
            $result.RebootRequired = $false

            $result.ExitCode = -1

            $result.Executable =
                "Application Path Not Found"

            $result.FailureReason =
                "Application path not found"

            $results += $result

            Update-DeploymentState `
                -Results $results `
                -Manifest $Manifest `
                -SerialNumber $SerialNumber `
                -Configuration $Configuration

            if ($result.RebootRequired) {

                Write-Host ""
                Write-Host "Reboot required."
                Write-Host "Stopping deployment."

                return $results
            }

            Write-DeploymentLog `
                -Result $result `
                -Configuration $Configuration `
                -SerialNumber $SerialNumber


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

            $result.RebootRequired = $false

            $result.ExitCode =
                -2

            $result.Executable =
                $resolved.MachineExePath

            $result.Arguments =
                $resolved.MachineExeArguments

            $result.FailureReason =
                "Machine executable not found"

            $results += $result

            Update-DeploymentState `
                -Results $results `
                -Manifest $Manifest `
                -SerialNumber $SerialNumber `
                -Configuration $Configuration

            if ($result.RebootRequired) {

                Write-Host ""
                Write-Host "Reboot required."
                Write-Host "Stopping deployment."

                return $results
            }

            Write-DeploymentLog `
                -Result $result `
                -Configuration $Configuration `
                -SerialNumber $SerialNumber

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

            $results += $result

            Update-DeploymentState `
                -Results $results `
                -Manifest $Manifest `
                -SerialNumber $SerialNumber `
                -Configuration $Configuration

            if ($result.RebootRequired) {

                Write-Host ""
                Write-Host "Reboot required."
                Write-Host "Stopping deployment."

                return $results
            }

            Write-DeploymentLog `
                -Result $result `
                -Configuration $Configuration `
                -SerialNumber $SerialNumber
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

            $result.RebootRequired = $false

            $result.ExitCode =
                -999

            $result.Executable =
                $resolved.MachineExePath

            $result.Arguments =
                $resolved.MachineExeArguments

            $result.FailureReason =
                $_.Exception.Message

            $results += $result

            Update-DeploymentState `
                -Results $results `
                -Manifest $Manifest `
                -SerialNumber $SerialNumber `
                -Configuration $Configuration

            if ($result.RebootRequired) {

                Write-Host ""
                Write-Host "Reboot required."
                Write-Host "Stopping deployment."

                return $results
            }

            Write-DeploymentLog `
                -Result $result `
                -Configuration $Configuration `
                -SerialNumber $SerialNumber

            continue
        }
    }
    
    return $results
}