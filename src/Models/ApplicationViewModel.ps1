class ApplicationViewModel {

    [bool]$Selected

    [string]$Name

    [string]$Department

    [bool]$Optional

    ApplicationViewModel() {

        $this.Selected = $false
    }
}