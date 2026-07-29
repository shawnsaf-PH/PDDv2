function Write-DeploymentLog {

    param(
        [Parameter(Mandatory)]
        [object]$Result,

        [Parameter(Mandatory)]
        [object]$Configuration,

        [Parameter(Mandatory)]
        [string]$SerialNumber
    )

    $logPath =
        Join-Path `
            $Configuration.LogDirectory `
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