class DeploymentExecutionResult {

    [string]$ApplicationName

    [bool]$Success

    [int]$ExitCode

    [string]$Executable

    [datetime]$StartTime

    [datetime]$EndTime

    [double]$DurationSeconds
}