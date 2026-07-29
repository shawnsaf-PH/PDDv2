class DeploymentExecutionResult {

    [string]$ApplicationName

    [bool]$Success

    [int]$ExitCode

    [string]$Executable

    [string]$Arguments

    [string]$FailureReason

    [bool]$RebootRequired

    [datetime]$StartTime

    [datetime]$EndTime

    [double]$DurationSeconds
}