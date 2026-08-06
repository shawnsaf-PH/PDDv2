#-----------Imports------------
. "$PSScriptRoot\..\Configuration\PlatformConfigurationService.ps1"
. "$PSScriptRoot\..\Catalogs\CatalogService.ps1"
. "$PSScriptRoot\..\Models\ApplicationViewModel.ps1"
. "$PSScriptRoot\..\Manifests\ManifestReader.ps1"
. "$PSScriptRoot\..\Manifests\ManifestService.ps1"
. "$PSScriptRoot\..\Manifests\ManifestWriter.ps1"
. "$PSScriptRoot\..\Profiles\ProfileService.ps1"
. "$PSScriptRoot\..\Deployment\DeploymentValidation.ps1"
. "$PSScriptRoot\..\Deployment\ManifestExecutor.ps1"
. "$PSScriptRoot\DeploymentProgressWindow.ps1"
. "$PSScriptRoot\DeploymentSummaryWindow.ps1"
. "$PSScriptRoot\..\Deployment\DeploymentStateService.ps1"

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

    if ($chassisPatchesCheckBox.IsChecked) {
        $selectedDepartments += "CHASSISPATCHES"
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

function Set-ProfileSelection {

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

function Show-DeploymentSummary {

    param(

        [array]$ExecutionResults,

        [string]$SerialNumber
    )

    $successfulCount =
        ($ExecutionResults |
            Where-Object {
                $_.Success
            }).Count

    $failedResults =
        $ExecutionResults |
        Where-Object {
            -not $_.Success
        }

    $failedCount =
        $failedResults.Count

    $rebootRequired =
        ($ExecutionResults |
            Where-Object {
                $_.RebootRequired
            }).Count -gt 0

    $totalCount =
        $ExecutionResults.Count

    $summaryWindow =
        New-DeploymentSummaryWindow

    $summaryHeaderTextBlock =
        $summaryWindow.FindName(
            "SummaryHeaderTextBlock"
        )

    $summaryTextBox =
        $summaryWindow.FindName(
            "SummaryTextBox"
        )

    $openLogButton =
        $summaryWindow.FindName(
            "OpenLogButton"
        )

    $closeButton =
        $summaryWindow.FindName(
            "CloseButton"
        )

    $summaryHeaderTextBlock.Text =
        "Deployment Complete"

    $failureList =
        $failedResults |
        ForEach-Object {

@"
$($_.ApplicationName)
Reason: $($_.FailureReason)
"@
        }

    $summary =
@"
Total Applications : $totalCount

Successful         : $successfulCount

Failed             : $failedCount

Reboot Required    : $rebootRequired

Failed Applications:

$($failureList -join "`r`n`r`n")
"@

    if ($rebootRequired) {

        $summary += @"

*** SYSTEM REBOOT REQUIRED ***

"@
    }

    $summaryTextBox.Text =
        $summary

    $logDirectory =
        Join-Path `
            $config.LogDirectory `
            $SerialNumber

    $logPath =
        Join-Path `
            $logDirectory `
            "$SerialNumber.log"

    $closeButton.Add_Click({

        $summaryWindow.Close()
    })

    $openLogButton.Add_Click({

        if (Test-Path $logPath) {

            Invoke-Item $logPath
        }
    })

    $summaryWindow.ShowDialog() | Out-Null
}
function Test-ResumeDeployment {

    param(
        [string]$SerialNumber
    )

    $stateDirectory =
        Join-Path `
        $config.LogDirectory `
        "State"
    
    $statePath =
        Join-Path `
            $stateDirectory `
            "$SerialNumber.state.json"

    if (-not (Test-Path $statePath)) {

        return
    }

    $state =
        Read-DeploymentState `
            -Path $statePath

    $script:ResumeState =
        $state

    $message =
@"
Previous Deployment Detected

Serial Number : $($state.SerialNumber)

Completed Steps : $($state.CompletedSteps)

Pending Steps : $($state.PendingSteps)

Resume Deployment?
"@

    $result =
        [System.Windows.MessageBox]::Show(
            $message,
            "Resume Deployment",
            [System.Windows.MessageBoxButton]::YesNo,
            [System.Windows.MessageBoxImage]::Question
        )

    if ($result -ne [System.Windows.MessageBoxResult]::Yes) {

        return
    }

    $manifestPath =
        Join-Path `
            $config.ConfigDirectory `
            $state.ManifestPath

    if (-not (Test-Path $manifestPath)) {

        [System.Windows.MessageBox]::Show(
            "Manifest not found.`n`n$manifestPath",
            "Resume Deployment"
        )

        return
    }

    $manifest =
        Read-DeploymentManifest `
            -Path $manifestPath

    $manifest.Steps =
        @(
            $manifest.Steps |
            Where-Object {
                $_.StepNumber -gt $state.LastCompletedStep
            }
        )

    [System.Windows.MessageBox]::Show(
        "Resuming deployment at Step $($state.LastCompletedStep + 1).",
        "Resume Deployment"
    )

    $progressWindow =
        New-DeploymentProgressWindow

    $progressWindow.Show()

    $executionResults = 
        Invoke-DeploymentManifest `
                -Manifest $manifest `
                -Configuration $config `
                -SerialNumber $SerialNumber `
                -ProgressWindow $progressWindow

    $progressWindow.Close()

    $allExecutionResults =
        @()

    if ($null -ne $state.ExecutionResults) {

        $allExecutionResults +=
            $state.ExecutionResults
    }

    $allExecutionResults +=
        $executionResults

    $failedResults =
        $executionResults |
        Where-Object {
            -not $_.Success
        }

    if ($failedResults.Count -eq 0) {

        Remove-DeploymentState `
            -SerialNumber $SerialNumber `
            -Configuration $config
    }

    Show-DeploymentSummary `
        -ExecutionResults $allExecutionResults `
        -SerialNumber $SerialNumber
}

#-----------Main Window Logic------------
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName Microsoft.VisualBasic

[xml]$xaml = Get-Content "$PSScriptRoot\MainWindow.xaml" -Raw

$reader = New-Object System.Xml.XmlNodeReader $xaml

$window = [Windows.Markup.XamlReader]::Load($reader)

$script:MainWindow = $window

$iconPath =
    Join-Path `
        $PSScriptRoot `
        "Images\PDDv2_PackageGear.ico"

if (Test-Path $iconPath) {

    $window.Icon =
        [System.Windows.Media.Imaging.BitmapFrame]::Create(
            [System.Uri]::new($iconPath)
        )
}

$applicationList =
    $window.FindName("ApplicationList")
    $applicationList.AddHandler(
    [System.Windows.Controls.CheckBox]::ClickEvent,
    [System.Windows.RoutedEventHandler]{

        param($sender, $eventArgs)

        $checkBox =
            $eventArgs.OriginalSource

        if ($checkBox -isnot [System.Windows.Controls.CheckBox]) {
            return
        }

        $application =
            $checkBox.DataContext

        if ($null -eq $application) {
            return
        }

        $application.Selected =
            [bool]$checkBox.IsChecked
    }
)
    $searchBox = $window.FindName("SearchBox")
    $profileComboBox = $window.FindName("ProfileComboBox")
    $serialNumberTextBox = $window.FindName("SerialNumberTextBox")
    $basicCheckBox = $window.FindName("BasicCheckBox")
    $optionCheckBox = $window.FindName("OptionCheckBox")
    $optionalCheckBox = $window.FindName("OptionalCheckBox")
    $showSelectedCheckBox = $window.FindName("ShowSelectedCheckBox")
    $siteCheckBox = $window.FindName("SiteCheckBox")
    $customCheckBox = $window.FindName("CustomCheckBox")
    $prepCheckBox = $window.FindName("PrepCheckBox")
    $zeppelinCheckBox = $window.FindName("ZeppelinCheckBox")
    $globalSiteCheckBox = $window.FindName("GlobalSiteCheckBox")
    $chassisPatchesCheckBox = $window.FindName("ChassisPatchesCheckBox")
    $optionalCheckBox = $window.FindName("OptionalCheckBox")
    $generateButton = $window.FindName("GenerateButton")
    $saveButton = $window.FindName("SaveButton")
    $saveAsButton = $window.FindName("SaveAsButton")
    $closeButton = $window.FindName("CloseButton")

#$script:CurrentManifest = $null

$config = Get-PlatformConfiguration

if ($config.IniFilesDirectory -match "USDBTLBCA1MS1IT") {

    $saveButton.IsEnabled = $false
}

$serialNumber =
    (Get-CimInstance Win32_BIOS).SerialNumber

$serialNumberTextBox.Text =
    $serialNumber.Trim()

$script:ResumeRequested =
    $false

$script:ResumeState =
    $null

Test-ResumeDeployment `
    -SerialNumber $serialNumber

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

Set-ProfileSelection -ProfileName "Default"

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

    $selectedApps = Get-SelectedApplications

    if ($selectedApps.Count -eq 0) {

        [System.Windows.MessageBox]::Show(
            "No applications selected.",
            "Generate"
        )

        return
    }

    $manifest = New-DeploymentManifest -Applications $selectedApps

    $validationResults = Test-DeploymentManifest -Manifest $manifest -Configuration $config

    $failedResults = $validationResults | Where-Object {-not $_.Valid}

    if ($failedResults.Count -gt 0) {

        $failedResults |
            ForEach-Object {

                Write-Host "$($_.ApplicationName) - $($_.Message)"
            }
    }

    $script:CurrentManifest = $manifest

    $serialNumber = $serialNumberTextBox.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($serialNumber)) {

        [System.Windows.MessageBox]::Show(
            "Serial Number is required.",
            "Generate"
        )

        return
    }

    $fileName =
        "$serialNumber.ini"

    $manifestPath =
        Join-Path `
            $config.ConfigDirectory `
            $fileName

    Write-DeploymentManifest `
        -Manifest $manifest `
        -Path $manifestPath

    $progressWindow = New-DeploymentProgressWindow

    $progressWindow.Show()
    
    $executionResults = Invoke-DeploymentManifest `
        -Manifest $manifest `
        -Configuration $config `
        -SerialNumber $serialNumber `
        -ProgressWindow $progressWindow

    #$progressWindow.Hide()

    $rebootRequired =
        ($executionResults |
            Where-Object {
                $_.RebootRequired
            }).Count -gt 0

    if ($rebootRequired) {    

        $resumeDirectory =
            "C:\Temp\PDDv2"

        if (-not (Test-Path $resumeDirectory)) {

            New-Item `
                -Path $resumeDirectory `
                -ItemType Directory `
                -Force | Out-Null
        }

        $localLauncher =
            Join-Path `
                $resumeDirectory `
                "Launch-PDDv2.cmd"

        Copy-Item `
            -Path $config.ResumeLauncher `
            -Destination $localLauncher `
            -Force

        $runOnceKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce'

        if (-not (Test-Path $runOnceKey)) {
            New-Item -Path $runOnceKey -Force | Out-Null
        }

        New-ItemProperty `
            -Path $runOnceKey `
            -Name 'PDDv2Resume' `
            -Value $localLauncher `
            -PropertyType String `
            -Force | Out-Null

        shutdown.exe /r /t 10

        #F all this code below
        <#[System.Windows.MessageBox]::Show(
            "Deployment requires a reboot. The computer will restart in 10 seconds and PDDv2 will automatically relaunch after sign-in.",
            "Reboot Required",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Information
        )#>

        if ($null -ne $script:MainWindow) {

            $script:MainWindow.Close()
        }

        return
    }

    $successfulCount =
        ($executionResults |
            Where-Object {
                $_.Success
            }).Count

    $failedResults =
        $executionResults |
        Where-Object {
            -not $_.Success
        }

    $failedCount = $failedResults.Count

    $rebootRequired =
        ($executionResults |
            Where-Object {
                $_.RebootRequired
            }).Count -gt 0

    $totalCount = $executionResults.Count

    $summaryWindow =
        New-DeploymentSummaryWindow

    $summaryHeaderTextBlock =
        $summaryWindow.FindName(
            "SummaryHeaderTextBlock"
        )

    $summaryTextBox =
        $summaryWindow.FindName(
            "SummaryTextBox"
        )
    
    $openLogButton =
        $summaryWindow.FindName(
            "OpenLogButton"
        )

    $closeButton =
        $summaryWindow.FindName(
            "CloseButton"
        )

    $summaryHeaderTextBlock.Text =
        "Deployment Complete"

    $failureList =
        $failedResults |
        ForEach-Object {

@"
$($_.ApplicationName)
Reason: $($_.FailureReason)
"@
        }

$summary =
@"
Total Applications : $totalCount

Successful         : $successfulCount

Failed             : $failedCount

Reboot Required    : $rebootRequired

Failed Applications:

$($failureList -join "`r`n`r`n")
"@

if ($rebootRequired) {

    $summary += @"
*** SYSTEM REBOOT REQUIRED ***
"@
}

$summaryTextBox.Text =
    $summary

$closeButton.Add_Click({

    $summaryWindow.Close()
})

$logDirectory =
    Join-Path `
        $config.LogDirectory `
        $serialNumber

$logPath =
    Join-Path `
        $logDirectory `
        "$serialNumber.log"

    $openLogButton.Add_Click({

        if (Test-Path $logPath) {

            Invoke-Item $logPath
        }
    })

    $summaryWindow.ShowDialog() | Out-Null

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

    Set-ProfileSelection `
        -ProfileName $profileComboBox.SelectedItem
})

Update-FilteredApplicationList

$window.ShowDialog()