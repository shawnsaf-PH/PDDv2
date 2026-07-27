. "$PSScriptRoot\..\Models\ResolvedDeploymentStep.ps1"
. "$PSScriptRoot\..\Models\DeploymentStep.ps1"

function Resolve-DeploymentStep {

    param(
        [Parameter(Mandatory)]
        [Object]$Step,

        [Parameter(Mandatory)]
        [PlatformConfiguration]$Configuration
    )

    $resolved =
        [ResolvedDeploymentStep]::new()

    $resolved.Step =
        $Step

    foreach ($toolbox in $Configuration.Toolboxes.Values) {

        $applicationPath =
            Join-Path `
                $toolbox `
                $Step.Directory

        if (Test-Path $applicationPath) {

            $resolved.ApplicationPath =
                $applicationPath

            $resolved.ApplicationPathExists =
                $true

            break
        }
    }

    if ($resolved.ApplicationPathExists) {

        if (-not [string]::IsNullOrWhiteSpace($Step.MachineExe)) {

            $machineExe =
                ($Step.MachineExe.Split(' ')[0])

            $resolved.MachineExePath =
                Join-Path `
                    $resolved.ApplicationPath `
                    $machineExe

            $resolved.MachineExeExists =
                Test-Path $resolved.MachineExePath
        }

        if (-not [string]::IsNullOrWhiteSpace($Step.UserExe)) {

            $userExe =
                ($Step.UserExe.Split(' ')[0])

            $resolved.UserExePath =
                Join-Path `
                    $resolved.ApplicationPath `
                    $userExe

            $resolved.UserExeExists =
                Test-Path $resolved.UserExePath
        }
    }

    return $resolved
}