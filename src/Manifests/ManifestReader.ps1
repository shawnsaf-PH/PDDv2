. "$PSScriptRoot\..\Models\DeploymentManifest.ps1"
. "$PSScriptRoot\..\Models\DeploymentStep.ps1"

function Read-DeploymentManifest {

    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $manifest =
        [DeploymentManifest]::new()

    $currentStep = $null

    foreach ($line in Get-Content $Path) {

        $line = $line.Trim()

        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        if ($line -eq "[MAIN]") {
            continue
        }

        if ($line -match '^\[(\d+)\]$') {

            if ($null -ne $currentStep) {

                $manifest.Steps += $currentStep
            }

            $currentStep =
                [DeploymentStep]::new()

            $currentStep.StepNumber =
                [int]$Matches[1]

            continue
        }

        if ($null -eq $currentStep) {
            continue
        }

        $parts =
            $line.Split("=", 2)

        if ($parts.Count -ne 2) {
            continue
        }

        $name =
            $parts[0]

        $value =
            $parts[1]

        switch ($name) {

            "Name" {
                $currentStep.Name = $value
            }

            "Directory" {
                $currentStep.Directory = $value
            }

            "MachineEXE" {
                $currentStep.MachineExe = $value
            }

            "UserEXE" {
                $currentStep.UserExe = $value
            }

            "Reboot" {
                $currentStep.Reboot =
                    [System.Convert]::ToBoolean($value)
            }

            "Department" {
                $currentStep.Department = $value
            }
        }
    }

    if ($null -ne $currentStep) {

        $manifest.Steps += $currentStep
    }

    return $manifest
}