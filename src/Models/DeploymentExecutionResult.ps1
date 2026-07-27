class DeploymentExecutionResult {

    [string]$ApplicationName

    [bool]$Success

    [int]$ExitCode

    [string]$Executable

    [string]$Arguments
    
    [datetime]$StartTime

    [datetime]$EndTime

    [double]$DurationSeconds

}