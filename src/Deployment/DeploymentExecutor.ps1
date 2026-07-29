. "$PSScriptRoot\..\Models\DeploymentExecutionResult.ps1"
. "$PSScriptRoot\..\Models\ResolvedDeploymentStep.ps1"

function Invoke-DeploymentStep {

    param(
        [Parameter(Mandatory)]
        [Object]$ResolvedStep
    )

    $result =
        [DeploymentExecutionResult]::new()

    $result.ApplicationName =
        $ResolvedStep.Step.Name

    $result.Executable =
        $ResolvedStep.MachineExePath

    $result.Arguments = $ResolvedStep.MachineExeArguments

    if (-not $ResolvedStep.MachineExeExists) {

        $result.Success = $false
        $result.ExitCode = -1

        return $result
    }

    $result.StartTime = Get-Date

    if ([String]::IsNullOrWhiteSpace($ResolvedStep.MachineExeArguments)) {

        $process =
            Start-Process `
                -FilePath $ResolvedStep.MachineExePath `
                -WorkingDirectory $ResolvedStep.ApplicationPath `
                -Wait `
                -PassThru
    }
    else {

        Write-Host "Starting Process..."

        $process =
            Start-Process `
                -FilePath $ResolvedStep.MachineExePath `
                -ArgumentList $ResolvedStep.MachineExeArguments `
                -WorkingDirectory $ResolvedStep.ApplicationPath `
                -Wait `
                -PassThru

        Write-Host "Process Returned"
        Write-Host "Exit Code:" $process.ExitCode
    }

    $result.EndTime = Get-Date

    $result.DurationSeconds =
        ($result.EndTime - $result.StartTime).TotalSeconds

    $result.ExitCode =
        $process.ExitCode

    $result.Success =
        ($process.ExitCode -eq 0)

    $result.RebootRequired =
        $ResolvedStep.Step.Reboot

    $result.RebootRequired =
        $ResolvedStep.Step.Reboot

    return $result
}