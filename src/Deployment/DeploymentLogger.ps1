function Write-DeploymentLog {

    param(
        [Parameter(Mandatory)]
        [object]$Result,

        [Parameter(Mandatory)]
        [object]$Configuration,

        [Parameter(Mandatory)]
        [string]$SerialNumber
    )

$machineLogDirectory =
    Join-Path `
        $Configuration.LogDirectory `
        $SerialNumber

if (-not (Test-Path $machineLogDirectory)) {

    New-Item `
        -Path $machineLogDirectory `
        -ItemType Directory `
        -Force | Out-Null
}

$logPath =
    Join-Path `
        $machineLogDirectory `
        "$SerialNumber.log"

    $lines = @()

    $lines += "------------------------------------------------------------"
    $lines += "Timestamp : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $lines += "Application : $($Result.ApplicationName)"
    $lines += "Executable : $($Result.Executable)"
    $lines += "Arguments : $($Result.Arguments)"
    $lines += "Exit Code : $($Result.ExitCode)"
    $lines += "Success : $($Result.Success)"
    $lines += "Duration : $($Result.DurationSeconds.ToString('N2')) seconds"
    $lines += ""

    Add-Content `
        -Path $logPath `
        -Value $lines
}