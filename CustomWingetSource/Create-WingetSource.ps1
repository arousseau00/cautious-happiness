#requires -Version 5.1

<#
.SYNOPSIS
    Creates and manages custom winget sources
.DESCRIPTION
    This script helps create, validate, and manage custom winget sources for distributing applications.
.PARAMETER Action
    The action to perform: Create, Validate, Deploy, or Add
.PARAMETER SourceName
    The name of the winget source
.PARAMETER SourceUrl
    The URL where the source will be hosted
.PARAMETER PackageName
    The name of the package to create
.PARAMETER PackageVersion
    The version of the package
.PARAMETER Publisher
    The publisher name
.PARAMETER InstallerPath
    Path to the installer file
.PARAMETER OutputPath
    Path where to create the source files
.EXAMPLE
    .\Create-WingetSource.ps1 -Action Create -SourceName "MyCompany" -PackageName "MyApp" -PackageVersion "1.0.0" -Publisher "MyCompany"
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Create", "Validate", "Deploy", "Add")]
    [string]$Action,
    
    [Parameter(Mandatory = $false)]
    [string]$SourceName = "MyCompany",
    
    [Parameter(Mandatory = $false)]
    [string]$SourceUrl = "https://mycompany.com/winget",
    
    [Parameter(Mandatory = $false)]
    [string]$PackageName = "MyApp",
    
    [Parameter(Mandatory = $false)]
    [string]$PackageVersion = "1.0.0",
    
    [Parameter(Mandatory = $false)]
    [string]$Publisher = "MyCompany",
    
    [Parameter(Mandatory = $false)]
    [string]$InstallerPath,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".\WingetSource"
)

function New-WingetSource {
    param(
        [string]$SourceName,
        [string]$SourceUrl,
        [string]$PackageName,
        [string]$PackageVersion,
        [string]$Publisher,
        [string]$OutputPath
    )
    
    Write-Host "Creating winget source structure..." -ForegroundColor Green
    
    # Create directory structure
    $manifestPath = Join-Path $OutputPath "manifests\m\$Publisher\$PackageName\$PackageVersion"
    $latestPath = Join-Path $OutputPath "manifests\m\$Publisher\$PackageName\latest"
    
    New-Item -ItemType Directory -Path $manifestPath -Force | Out-Null
    New-Item -ItemType Directory -Path $latestPath -Force | Out-Null
    
    # Create package manifest
    $packageManifest = @"
PackageIdentifier: $Publisher.$PackageName
PackageVersion: $PackageVersion
DefaultLocale: en-US
ManifestType: singleton
ManifestVersion: 1.0.0
"@
    $packageManifest | Out-File -FilePath (Join-Path $manifestPath "$PackageName.yaml") -Encoding UTF8
    
    # Create locale manifest
    $localeManifest = @"
PackageLocale: en-US
Publisher: $Publisher
PublisherUrl: $SourceUrl
PublisherSupportUrl: $SourceUrl/support
PrivacyUrl: $SourceUrl/privacy
Author: $Publisher
PackageName: $PackageName
PackageUrl: $SourceUrl/$PackageName
License: MIT
LicenseUrl: https://opensource.org/licenses/MIT
Copyright: Copyright (c) $(Get-Date -Format "yyyy") $Publisher
CopyrightUrl: $SourceUrl
ShortDescription: A sample application
Description: This is a sample application for demonstrating winget source creation.
Tags:
  - sample
  - demo
Moniker: $($PackageName.ToLower())
"@
    $localeManifest | Out-File -FilePath (Join-Path $manifestPath "$PackageName.locale.en-US.yaml") -Encoding UTF8
    
    # Create installer manifest
    $installerManifest = @"
PackageIdentifier: $Publisher.$PackageName
PackageVersion: $PackageVersion
MinimumOSVersion: 10.0.0.0
Installers:
  - Architecture: x64
    InstallerType: exe
    InstallerUrl: $SourceUrl/downloads/$PackageName-$PackageVersion-x64.exe
    InstallerSha256: 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
    InstallerSwitches:
      Silent: /S
      SilentWithProgress: /S
    InstallModes:
      - interactive
      - silent
      - silentWithProgress
    ProductCode: "{12345678-1234-1234-1234-123456789012}"
    Capabilities:
      - internetClient
    RestrictedCapabilities:
      - runFullTrust
    PackageFamilyName: $Publisher.$PackageName`_1234567890abc
    Platform:
      - Windows.Desktop
    InstallerAbortsTerminal: false
    ReleaseDate: $(Get-Date -Format "yyyy-MM-dd")
    InstallLocationRequired: false
    RequireExplicitUpgrade: false
    AppsAndFeaturesEntries:
      - DisplayName: $PackageName
        DisplayVersion: $PackageVersion
        Publisher: $Publisher
        ProductCode: "{12345678-1234-1234-1234-123456789012}"
        InstallType: 1
"@
    $installerManifest | Out-File -FilePath (Join-Path $manifestPath "$PackageName.installer.yaml") -Encoding UTF8
    
    # Create latest manifest
    $latestManifest = @"
PackageIdentifier: $Publisher.$PackageName
PackageVersion: $PackageVersion
DefaultLocale: en-US
ManifestType: singleton
ManifestVersion: 1.0.0
"@
    $latestManifest | Out-File -FilePath (Join-Path $latestPath "$PackageName.yaml") -Encoding UTF8
    
    # Create index.json
    $indexJson = @{
        CreationDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
        Sources = @(
            @{
                Packages = @(
                    @{
                        PackageIdentifier = "$Publisher.$PackageName"
                        Versions = @(
                            @{
                                PackageVersion = $PackageVersion
                                DefaultLocale = "en-US"
                                Locales = @("en-US")
                                Installers = @(
                                    @{
                                        Architecture = "x64"
                                        InstallerType = "exe"
                                        InstallerUrl = "$SourceUrl/downloads/$PackageName-$PackageVersion-x64.exe"
                                        InstallerSha256 = "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
                                        ProductCode = "{12345678-1234-1234-1234-123456789012}"
                                        PackageFamilyName = "$Publisher.$PackageName`_1234567890abc"
                                    }
                                )
                            }
                        )
                    }
                )
            }
        )
    }
    $indexJson | ConvertTo-Json -Depth 10 | Out-File -FilePath (Join-Path $OutputPath "index.json") -Encoding UTF8
    
    # Create source.json
    $sourceJson = @{
        Information = @{
            SourceAgreements = @{
                Agreement = "$SourceUrl/agreement"
                AgreementUrl = "$SourceUrl/agreement"
            }
            SourceAgreementsIdentifier = "${Publisher}Agreement"
            Documentation = "$SourceUrl/docs"
            Icon = "$SourceUrl/icon.png"
            License = "MIT"
            LicenseUrl = "https://opensource.org/licenses/MIT"
            Privacy = "$SourceUrl/privacy"
            Publisher = $Publisher
            PublisherUrl = $SourceUrl
            Support = "$SourceUrl/support"
            SupportUrl = "$SourceUrl/support"
        }
    }
    $sourceJson | ConvertTo-Json -Depth 10 | Out-File -FilePath (Join-Path $OutputPath "source.json") -Encoding UTF8
    
    Write-Host "Winget source created successfully at: $OutputPath" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Update the installer URLs and SHA256 hashes" -ForegroundColor Yellow
    Write-Host "2. Host the files on a web server" -ForegroundColor Yellow
    Write-Host "3. Add the source using: winget source add --name '$SourceName' --arg '$SourceUrl'" -ForegroundColor Yellow
}

function Test-WingetSource {
    param([string]$SourcePath)
    
    Write-Host "Validating winget source..." -ForegroundColor Green
    
    # Check if winget-create is available
    try {
        $null = Get-Command winget-create -ErrorAction Stop
    } catch {
        Write-Warning "winget-create not found. Install it using: winget install Microsoft.WingetCreate"
        return
    }
    
    # Validate manifests
    $manifestFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.yaml"
    foreach ($file in $manifestFiles) {
        Write-Host "Validating $($file.Name)..." -ForegroundColor Cyan
        try {
            winget-create validate $file.FullName
            Write-Host "✓ $($file.Name) is valid" -ForegroundColor Green
        } catch {
            Write-Host "✗ $($file.Name) has validation errors" -ForegroundColor Red
        }
    }
}

function Add-WingetSource {
    param(
        [string]$SourceName,
        [string]$SourceUrl
    )
    
    Write-Host "Adding winget source..." -ForegroundColor Green
    
    try {
        winget source add --name $SourceName --arg $SourceUrl --accept-source-agreements
        Write-Host "✓ Source '$SourceName' added successfully" -ForegroundColor Green
        
        Write-Host "`nVerifying source..." -ForegroundColor Cyan
        winget source list
        
        Write-Host "`nUpdating source..." -ForegroundColor Cyan
        winget source update --name $SourceName
        
    } catch {
        Write-Error "Failed to add source: $_"
    }
}

# Main execution
switch ($Action) {
    "Create" {
        New-WingetSource -SourceName $SourceName -SourceUrl $SourceUrl -PackageName $PackageName -PackageVersion $PackageVersion -Publisher $Publisher -OutputPath $OutputPath
    }
    "Validate" {
        Test-WingetSource -SourcePath $OutputPath
    }
    "Add" {
        Add-WingetSource -SourceName $SourceName -SourceUrl $SourceUrl
    }
    "Deploy" {
        Write-Host "Deploy options:" -ForegroundColor Green
        Write-Host "1. GitHub Pages: Upload files to a GitHub repository and enable Pages" -ForegroundColor Yellow
        Write-Host "2. Azure Static Web Apps: Deploy to Azure Static Web Apps" -ForegroundColor Yellow
        Write-Host "3. Local testing: Use 'python -m http.server 8080' in the source directory" -ForegroundColor Yellow
    }
} 