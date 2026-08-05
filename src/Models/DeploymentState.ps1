class DeploymentState {

    [string]$SerialNumber

    [string]$ManifestPath

    [int]$TotalSteps

    [int]$CompletedSteps

    [int]$LastCompletedStep

    [int]$CurrentStep

    [int]$PendingSteps

    [bool]$RebootRequired

    [datetime]$Timestamp
}