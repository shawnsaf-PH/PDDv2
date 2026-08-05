. "$PSScriptRoot\..\Models\DeploymentState.ps1"

function Save-DeploymentState {

    param(
        [Parameter(Mandatory)]
        [DeploymentState]$State,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $State |
        ConvertTo-Json |
        Set-Content `
            -Path $Path `
            -Encoding UTF8
}

function Read-DeploymentState {

    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    Get-Content `
        -Path $Path `
        -Raw |
        ConvertFrom-Json
}

function Update-DeploymentState {

    param(
        [Parameter(Mandatory)]
        [array]$Results,

        [Parameter(Mandatory)]
        [object]$Manifest,

        [Parameter(Mandatory)]
        [string]$SerialNumber,

        [Parameter(Mandatory)]
        [object]$Configuration
    )

    $state =
        [DeploymentState]::new()

    $state.SerialNumber =
        $SerialNumber

    $state.ManifestPath =
        "$SerialNumber.ini"

    $state.TotalSteps =
        $Manifest.Steps.Count

    $state.CompletedSteps =
        $Results.Count

    $state.LastCompletedStep =
        $Results.Count

    $state.PendingSteps =
        $Manifest.Steps.Count - $Results.Count

    $state.CurrentStep =
        [Math]::Min(
            $Results.Count + 1,
            $Manifest.Steps.Count
        )

    $state.RebootRequired =
        ($Results |
            Where-Object {
                $_.RebootRequired
            }).Count -gt 0

    $state.Timestamp =
        Get-Date

    $stateDirectory =
        Join-Path `
            $Configuration.LogDirectory `
            "State"

    if (-not (Test-Path $stateDirectory)) {

        New-Item `
            -Path $stateDirectory `
            -ItemType Directory `
            -Force | Out-Null
    }

    $statePath =
        Join-Path `
            $stateDirectory `
            "$SerialNumber.state.json"

    Save-DeploymentState `
        -State $state `
        -Path $statePath
}