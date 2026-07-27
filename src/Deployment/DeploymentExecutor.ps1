. "$PSScriptRoot\..\Models\DeploymentExecutionResult.ps1"
. "$PSScriptRoot\..\Models\ResolvedDeploymentStep.ps1"

function Invoke-DeploymentStep {

    param(
        [Parameter(Mandatory)]
        [ResolvedDeploymentStep]$ResolvedStep
    )

    $result =
        [DeploymentExecutionResult]::new()

    $result.ApplicationName =
        $ResolvedStep.Step.Name

    $result.Executable =
        $ResolvedStep.MachineExePath

    if (-not $ResolvedStep.MachineExeExists) {

        $result.Success = $false
        $result.ExitCode = -1

        return $result
    }

    $result.StartTime = Get-Date

    $process =
        Start-Process `
            -FilePath $ResolvedStep.MachineExePath `
            -WorkingDirectory $ResolvedStep.ApplicationPath `
            -Wait `
            -PassThru

    $result.EndTime = Get-Date

    $result.DurationSeconds =
        ($result.EndTime - $result.StartTime).TotalSeconds

    $result.ExitCode =
        $process.ExitCode

    $result.Success =
        ($process.ExitCode -eq 0)

    return $result
}