function Write-DeploymentManifest {

    param(
        [Parameter(Mandatory)]
        $Manifest,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $lines = @()

    $lines += "[MAIN]"
    $lines += "InstallMachinePart=TRUE"
    $lines += "InstallUserPart=TRUE"
    $lines += "Steps=$($Manifest.Steps.Count)"
    $lines += ""

    foreach ($step in $Manifest.Steps) {

        $lines += "[$($step.StepNumber)]"
        $lines += "Name=$($step.Name)"
        $lines += "MachineEXE=$($step.MachineExe)"
        $lines += "UserEXE=$($step.UserExe)"
        $lines += "Reboot=$($step.Reboot)"
        $lines += ""
    }

    Set-Content `
        -Path $Path `
        -Value $lines `
        -Encoding UTF8
}