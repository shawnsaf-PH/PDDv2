#-----------Imports------------
. "$PSScriptRoot\..\Configuration\PlatformConfigurationService.ps1"
. "$PSScriptRoot\..\Catalogs\CatalogService.ps1"
. "$PSScriptRoot\..\Models\ApplicationViewModel.ps1"
. "$PSScriptRoot\..\Manifests\ManifestService.ps1"
. "$PSScriptRoot\..\Manifests\ManifestWriter.ps1"
. "$PSScriptRoot\..\Profiles\ProfileService.ps1"

#-----------Functions------------
function Update-ApplicationList {

    param(
        [array]$Applications
    )

    $applicationList.ItemsSource = $null

    $applicationList.ItemsSource = @($Applications | Sort-Object Name)
}

function Get-FilteredApplications {

    $selectedDepartments = @()

    if ($basicCheckBox.IsChecked) {
        $selectedDepartments += "BASIC"
    }

    if ($optionCheckBox.IsChecked) {
        $selectedDepartments += "OPTION"
    }

    if ($siteCheckBox.IsChecked) {
        $selectedDepartments += "SITE"
    }

    if ($customCheckBox.IsChecked) {
        $selectedDepartments += "CUSTOM"
    }

    if ($prepCheckBox.IsChecked) {
        $selectedDepartments += "PREP"
    }

    if ($zeppelinCheckBox.IsChecked) {
        $selectedDepartments += "ZEPPELIN"
    }

    if ($globalSiteCheckBox.IsChecked) {
        $selectedDepartments += "GLOBALSITE"
    }

    $filteredApps = $script:AllApplications

    if ($selectedDepartments.Count -gt 0) {

        $filteredApps = $filteredApps |
            Where-Object {
                $_.Department -in $selectedDepartments
            }
    }

    if ($optionalCheckBox.IsChecked) {

        $filteredApps = $filteredApps |
            Where-Object {
                $_.Optional
            }
    }

    if ($showSelectedCheckBox.IsChecked) {

        $filteredApps =
            $filteredApps |
            Where-Object {
                $_.Selected
            }
    }

    return @($filteredApps)
}

function Update-FilteredApplicationList {

    $filteredApps = Get-FilteredApplications

    $searchText = $searchBox.Text

    if (-not [string]::IsNullOrWhiteSpace($searchText)) {

        $filteredApps = Find-Application -Applications $filteredApps -SearchText $searchText
    }

    Update-ApplicationList $filteredApps
}

function Get-SelectedApplications {

    return @(
        $script:AllApplications |
        Where-Object {
            $_.Selected
        }
    )
}

function Load-ProfileSelection {

    param(
        [string]$ProfileName
    )

    $profilePath =
        Join-Path `
            $config.ProfileDirectory `
            "$ProfileName.ini"

    $selectedApplicationNames =
        Read-Profile `
            -ProfilePath $profilePath

    Select-ProfileApplications `
        -Applications $script:AllApplications `
        -SelectedApplicationNames $selectedApplicationNames

    Update-FilteredApplicationList
}

#-----------Main Window Logic------------
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName Microsoft.VisualBasic

[xml]$xaml = Get-Content "$PSScriptRoot\MainWindow.xaml" -Raw

$reader = New-Object System.Xml.XmlNodeReader $xaml

$window = [Windows.Markup.XamlReader]::Load($reader)

$applicationList =
    $window.FindName("ApplicationList")
    $searchBox = $window.FindName("SearchBox")
    $profileComboBox = $window.FindName("ProfileComboBox")
    $basicCheckBox = $window.FindName("BasicCheckBox")
    $optionCheckBox = $window.FindName("OptionCheckBox")
    $optionalCheckBox = $window.FindName("OptionalCheckBox")
    $showSelectedCheckBox = $window.FindName("ShowSelectedCheckBox")
    $siteCheckBox = $window.FindName("SiteCheckBox")
    $customCheckBox = $window.FindName("CustomCheckBox")
    $prepCheckBox = $window.FindName("PrepCheckBox")
    $zeppelinCheckBox = $window.FindName("ZeppelinCheckBox")
    $globalSiteCheckBox = $window.FindName("GlobalSiteCheckBox")
    $optionalCheckBox = $window.FindName("OptionalCheckBox")
    $generateButton = $window.FindName("GenerateButton")
    $saveButton = $window.FindName("SaveButton")
    $saveAsButton = $window.FindName("SaveAsButton")
    $closeButton = $window.FindName("CloseButton")

$script:CurrentManifest = $null

$config = Get-PlatformConfiguration

$profiles =
    Get-Profiles `
        -ProfileDirectory $config.ProfileDirectory

$profileComboBox.ItemsSource =
    $profiles

$profileComboBox.SelectedItem =
    "Default"

$apps = Get-AllCatalogApplications -CatalogDirectory $config.IniFilesDirectory -Catalogs $config.Catalogs

$deployableApps =
    Get-DeployableApplications -Applications $apps
    $script:AllApplications =
    foreach ($app in $deployableApps) {

        $viewModel = [ApplicationViewModel]::new()

        $viewModel.Name = $app.Name
        $viewModel.Department = $app.Department
        $viewModel.Optional = $app.Optional
        $viewModel.Directory = $app.Directory
        $viewModel.MachineExe = $app.MachineExe
        $viewModel.UserExe = $app.UserExe
        $viewModel.Reboot = $app.Reboot
        $viewModel
    }

Load-ProfileSelection -ProfileName "Default"

Update-ApplicationList $script:AllApplications

$filterHandler = {

    Update-FilteredApplicationList
}

$basicCheckBox.Add_Click($filterHandler)
$optionCheckBox.Add_Click($filterHandler)
$siteCheckBox.Add_Click($filterHandler)
$customCheckBox.Add_Click($filterHandler)
$prepCheckBox.Add_Click($filterHandler)
$zeppelinCheckBox.Add_Click($filterHandler)
$globalSiteCheckBox.Add_Click($filterHandler)
$optionalCheckBox.Add_Click($filterHandler)
$showSelectedCheckBox.Add_Click($filterHandler)
$searchBox.Add_TextChanged({

    Update-FilteredApplicationList
})

$generateButton.Add_Click({

    $selectedApps =
        Get-SelectedApplications

    if ($selectedApps.Count -eq 0) {

        [System.Windows.MessageBox]::Show(
            "No applications selected.",
            "Generate"
        )

        return
    }

    $manifest = New-DeploymentManifest -Applications $selectedApps
    $script:CurrentManifest = $manifest

    [System.Windows.MessageBox]::Show(
        "Manifest generated successfully.`n`nSteps: $($manifest.Steps.Count)",
        "Generate"
    )
})

$saveButton.Add_Click({

    if ($null -eq $profileComboBox.SelectedItem) {

        [System.Windows.MessageBox]::Show(
            "No profile selected.",
            "Save"
        )

        return
    }

    $profilePath =
        Join-Path `
            $config.ProfileDirectory `
            "$($profileComboBox.SelectedItem).ini"

    Write-Profile `
        -ProfilePath $profilePath `
        -Applications $script:AllApplications

    [System.Windows.MessageBox]::Show(
        "Profile saved.`n`n$profilePath",
        "Save"
    )
})

$saveAsButton.Add_Click({

    $profileName =
        [Microsoft.VisualBasic.Interaction]::InputBox(
            "Enter profile name:",
            "Save As",
            ""
        )

    if ([string]::IsNullOrWhiteSpace($profileName)) {
        return
    }

    $profilePath =
        New-Profile `
            -ProfileDirectory $config.ProfileDirectory `
            -ProfileName $profileName `
            -Applications $script:AllApplications

    $profiles =
        Get-Profiles `
            -ProfileDirectory $config.ProfileDirectory

    $profileComboBox.ItemsSource =
        $profiles

    $profileComboBox.SelectedItem =
        $profileName

    [System.Windows.MessageBox]::Show(
        "Profile created.`n`n$profilePath",
        "Save As"
    )
})

$closeButton.Add_Click({

    $window.Close()
})


$profileComboBox.Add_SelectionChanged({

    if ($null -eq $profileComboBox.SelectedItem) {
        return
    }

    Load-ProfileSelection `
        -ProfileName $profileComboBox.SelectedItem
})

Update-FilteredApplicationList

$window.ShowDialog()