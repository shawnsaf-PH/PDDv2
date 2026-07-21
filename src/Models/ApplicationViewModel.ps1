class ApplicationViewModel {

    [bool]$Selected

    [string]$Name

    [string]$Department

    [bool]$Optional

    [string]$Directory

    [string]$MachineExe

    [string]$UserExe

    [bool]$Reboot

    ApplicationViewModel() {

        $this.Selected = $false
    }
}