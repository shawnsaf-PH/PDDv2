class ApplicationDefinition {

    [string]$Name

    [bool]$Optional

    [string]$Directory

    [string]$MachineExe

    [string]$UserExe

    [string]$Department

    [bool]$Reboot

    ApplicationDefinition() {
        $this.Optional = $false
        $this.Reboot = $false
    }
}
