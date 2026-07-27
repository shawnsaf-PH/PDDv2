class ResolvedDeploymentStep {

    [Object]$Step

    [string]$ApplicationPath

    [string]$MachineExePath

    [string]$UserExePath

    [string]$MachineExeArguments

    [string]$UserExeArguments
    
    [bool]$ApplicationPathExists

    [bool]$MachineExeExists

    [bool]$UserExeExists

}