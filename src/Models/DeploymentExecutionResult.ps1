class DeploymentExecutionResult {

    [string]$ApplicationName

    [bool]$Success

    [int]$ExitCode

    [string]$Executable

    [string]$Arguments
    
    [string]$FailureReason
    
    [datetime]$StartTime

    [datetime]$EndTime

    [double]$DurationSeconds

}