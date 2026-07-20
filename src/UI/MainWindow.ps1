#-----------Functions------------

function Update-ApplicationList {

    param(
        [array]$Applications
    )

    $applicationList.ItemsSource = $null

    $applicationList.ItemsSource =
        @($Applications | Sort-Object Name)

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

        #Write-Host "Remaining Apps:" $filteredApps.Count
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

. "$PSScriptRoot\..\Configuration\PlatformConfigurationService.ps1"
. "$PSScriptRoot\..\Catalogs\CatalogService.ps1"
. "$PSScriptRoot\..\Models\ApplicationViewModel.ps1"

write-host "Loading MainWindow.ps1"
Add-Type -AssemblyName PresentationFramework

[xml]$xaml =
Get-Content `
    "$PSScriptRoot\MainWindow.xaml" -Raw

$reader =
    New-Object System.Xml.XmlNodeReader $xaml

$window =
    [Windows.Markup.XamlReader]::Load($reader)

$applicationList =
    $window.FindName("ApplicationList")
    $searchBox = $window.FindName("SearchBox")

$basicCheckBox =
    $window.FindName("BasicCheckBox")

$optionCheckBox =
    $window.FindName("OptionCheckBox")

$siteCheckBox =
    $window.FindName("SiteCheckBox")

$customCheckBox =
    $window.FindName("CustomCheckBox")

$prepCheckBox =
    $window.FindName("PrepCheckBox")

$zeppelinCheckBox =
    $window.FindName("ZeppelinCheckBox")

$globalSiteCheckBox =
    $window.FindName("GlobalSiteCheckBox")

$optionalCheckBox = $window.FindName("OptionalCheckBox")

<#$applicationCountLabel =
    $window.FindName("ApplicationCountLabel")

$selectedCountLabel =
    $window.FindName("SelectedCountLabel")
#>
$config = Get-PlatformConfiguration

$apps = Get-AllCatalogApplications `
    -CatalogDirectory $config.IniFilesDirectory -Catalogs $config.Catalogs

write-host "Found $($apps.Count) applications in catalogs: $($config.Catalogs -join ', ')"

$deployableApps =
    Get-DeployableApplications -Applications $apps
    $script:AllApplications =
    foreach ($app in $deployableApps) {

        $viewModel = [ApplicationViewModel]::new()

        $viewModel.Name = $app.Name
        $viewModel.Department = $app.Department
        $viewModel.Optional = $app.Optional

        $viewModel
    }

    Write-Host ""
    Write-Host "Total Applications:" $script:AllApplications.Count

    Write-Host "Optional Applications:" (
        $script:AllApplications |
        Where-Object { $_.Optional }
    ).Count

Update-ApplicationList $script:AllApplications

$filterHandler = {

    Update-FilterdApplicationList
}

$basicCheckBox.Add_Click($filterHandler)
$optionCheckBox.Add_Click($filterHandler)
$siteCheckBox.Add_Click($filterHandler)
$customCheckBox.Add_Click($filterHandler)
$prepCheckBox.Add_Click($filterHandler)
$zeppelinCheckBox.Add_Click($filterHandler)
$globalSiteCheckBox.Add_Click($filterHandler)
$optionalCheckBox.Add_Click($filterHandler)

$searchBox.Add_TextChanged({

    Update-FilteredApplicationList
})

Update-FilteredApplicationList

$window.ShowDialog()