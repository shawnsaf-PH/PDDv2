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

$resolved.PSObject.Properties.Name

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

            $machineParts =
                $Step.MachineExe.Split(' ', 2)

            $machineExe =
                $machineParts[0]

            if ($machineParts.Count -gt 1) {

                $resolved.MachineExeArguments =
                    $machineParts[1]
            }

            $resolved.MachineExePath =
                Join-Path `
                    $resolved.ApplicationPath `
                    $machineExe

            $resolved.MachineExeExists =
                Test-Path $resolved.MachineExePath
        }

        if (-not [string]::IsNullOrWhiteSpace($Step.UserExe)) {

            $userParts =
            $Step.UserExe.Split(' ', 2)

            $userExe =
            $userParts[0]

            if ($userParts.Count -gt 1) {

                $resolved.UserExeArguments =
                $userParts[1]
            }

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