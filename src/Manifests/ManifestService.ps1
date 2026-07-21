. "$PSScriptRoot\..\Models\DeploymentManifest.ps1"
. "$PSScriptRoot\..\Models\DeploymentStep.ps1"

function New-DeploymentManifest {

    param(
        [Parameter(Mandatory)]
        [array]$Applications
    )

    $manifest =
        [DeploymentManifest]::new()

    $stepNumber = 1

    foreach ($application in $Applications) {

        $step = [DeploymentStep]::new()

        $step.StepNumber = $stepNumber
        $step.Name = $application.Name
        $step.Directory = $application.Directory
        $step.MachineExe = $application.MachineExe
        $step.UserExe = $application.UserExe
        $step.Reboot = $application.Reboot

        $manifest.Steps += $step

        $stepNumber++
    }

    return $manifest
}