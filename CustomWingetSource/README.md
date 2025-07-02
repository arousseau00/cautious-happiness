# Creating a Custom Winget Source

This guide explains how to create a custom winget source for distributing your own applications or packages.

## Overview

A winget source consists of:
1. **Package Manifests** - YAML files describing your applications
2. **Source Index** - A JSON file listing all available packages
3. **Web Server** - To host the manifests and index

## Directory Structure

```
CustomWingetSource/
├── manifests/
│   └── m/
│       └── MyCompany/
│           └── MyApp/
│               ├── 1.0.0/
│               │   ├── MyApp.yaml
│               │   ├── MyApp.locale.en-US.yaml
│               │   └── MyApp.installer.yaml
│               └── latest/
│                   └── MyApp.yaml
├── index.json
├── source.json
└── README.md
```

## 1. Create Package Manifest

### Example: `manifests/m/MyCompany/MyApp/1.0.0/MyApp.yaml`

```yaml
PackageIdentifier: MyCompany.MyApp
PackageVersion: 1.0.0
DefaultLocale: en-US
ManifestType: singleton
ManifestVersion: 1.0.0
```

### Example: `manifests/m/MyCompany/MyApp/1.0.0/MyApp.locale.en-US.yaml`

```yaml
PackageLocale: en-US
Publisher: MyCompany
PublisherUrl: https://mycompany.com
PublisherSupportUrl: https://mycompany.com/support
PrivacyUrl: https://mycompany.com/privacy
Author: MyCompany
PackageName: MyApp
PackageUrl: https://mycompany.com/myapp
License: MIT
LicenseUrl: https://opensource.org/licenses/MIT
Copyright: Copyright (c) 2024 MyCompany
CopyrightUrl: https://mycompany.com
ShortDescription: A sample application
Description: This is a sample application for demonstrating winget source creation.
Tags:
  - sample
  - demo
Moniker: myapp
```

### Example: `manifests/m/MyCompany/MyApp/1.0.0/MyApp.installer.yaml`

```yaml
PackageIdentifier: MyCompany.MyApp
PackageVersion: 1.0.0
MinimumOSVersion: 10.0.0.0
Installers:
  - Architecture: x64
    InstallerType: exe
    InstallerUrl: https://mycompany.com/downloads/MyApp-1.0.0-x64.exe
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
    Dependencies:
      WindowsFeatures:
        - Microsoft-Windows-Subsystem-Linux
    PackageFamilyName: MyCompany.MyApp_1234567890abc
    Platform:
      - Windows.Desktop
    InstallerAbortsTerminal: false
    ReleaseDate: 2024-01-01
    InstallLocationRequired: false
    RequireExplicitUpgrade: false
    UnsupportedOSArchitectures:
      - arm
    AppsAndFeaturesEntries:
      - DisplayName: MyApp
        DisplayVersion: 1.0.0
        Publisher: MyCompany
        ProductCode: "{12345678-1234-1234-1234-123456789012}"
        InstallType: 1
```

## 2. Create Source Index

### Example: `index.json`

```json
{
  "CreationDate": "2024-01-01T00:00:00.0000000Z",
  "Sources": [
    {
      "Packages": [
        {
          "PackageIdentifier": "MyCompany.MyApp",
          "Versions": [
            {
              "PackageVersion": "1.0.0",
              "DefaultLocale": "en-US",
              "Locales": [
                "en-US"
              ],
              "Installers": [
                {
                  "Architecture": "x64",
                  "InstallerType": "exe",
                  "InstallerUrl": "https://mycompany.com/downloads/MyApp-1.0.0-x64.exe",
                  "InstallerSha256": "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
                  "ProductCode": "{12345678-1234-1234-1234-123456789012}",
                  "PackageFamilyName": "MyCompany.MyApp_1234567890abc"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

## 3. Create Source Configuration

### Example: `source.json`

```json
{
  "Information": {
    "SourceAgreements": {
      "Agreement": "https://mycompany.com/agreement",
      "AgreementUrl": "https://mycompany.com/agreement"
    },
    "SourceAgreementsIdentifier": "MyCompanyAgreement",
    "Documentation": "https://mycompany.com/docs",
    "Icon": "https://mycompany.com/icon.png",
    "License": "MIT",
    "LicenseUrl": "https://opensource.org/licenses/MIT",
    "Privacy": "https://mycompany.com/privacy",
    "Publisher": "MyCompany",
    "PublisherUrl": "https://mycompany.com",
    "Support": "https://mycompany.com/support",
    "SupportUrl": "https://mycompany.com/support"
  }
}
```

## 4. Hosting Your Source

### Option A: GitHub Pages (Free)

1. Create a GitHub repository
2. Upload your manifest files
3. Enable GitHub Pages
4. Your source URL will be: `https://yourusername.github.io/repositoryname`

### Option B: Azure Static Web Apps

1. Create an Azure Static Web App
2. Deploy your manifest files
3. Your source URL will be: `https://yourapp.azurestaticapps.net`

### Option C: Local File System

For testing, you can host locally:
```powershell
# Start a simple HTTP server
python -m http.server 8080
# Your source URL will be: http://localhost:8080
```

## 5. Adding Your Custom Source

Once hosted, add your source to winget:

```powershell
# Add the source
winget source add --name "MyCompany" --arg "https://mycompany.com/winget"

# Verify it was added
winget source list

# Search for your packages
winget search MyCompany.MyApp

# Install your package
winget install MyCompany.MyApp
```

## 6. Validation Tools

Use Microsoft's validation tools:

```powershell
# Install winget-create (if not already installed)
winget install Microsoft.WingetCreate

# Validate your manifest
winget-create validate MyApp.yaml

# Create a new manifest from an installer
winget-create new MyApp.exe
```

## 7. Best Practices

1. **Versioning**: Use semantic versioning (e.g., 1.0.0, 1.0.1)
2. **Architecture**: Support multiple architectures (x64, x86, arm64)
3. **Localization**: Provide locale files for multiple languages
4. **Security**: Use HTTPS for all URLs
5. **Updates**: Keep your index.json updated with new versions
6. **Documentation**: Provide clear installation instructions
7. **Testing**: Test your manifests thoroughly before publishing

## 8. Troubleshooting

### Common Issues:
- **Manifest validation errors**: Check YAML syntax and required fields
- **Installation failures**: Verify installer URLs and SHA256 hashes
- **Source not found**: Ensure your web server is accessible
- **Version conflicts**: Use unique package identifiers

### Debug Commands:
```powershell
# Check source status
winget source list

# Update source
winget source update --name "MyCompany"

# Remove problematic source
winget source remove --name "MyCompany"

# Reset to defaults
winget source reset --force
```

## 9. Advanced Features

### Multiple Installers:
```yaml
Installers:
  - Architecture: x64
    InstallerType: msi
    InstallerUrl: https://example.com/app-x64.msi
  - Architecture: x86
    InstallerType: msi
    InstallerUrl: https://example.com/app-x86.msi
  - Architecture: arm64
    InstallerType: msi
    InstallerUrl: https://example.com/app-arm64.msi
```

### Dependencies:
```yaml
Dependencies:
  WindowsFeatures:
    - Microsoft-Windows-Subsystem-Linux
  WindowsLibraries:
    - Microsoft.VCLibs.140.00
  ExternalDependencies:
    - Microsoft.DotNet.Runtime.6
```

### Commands:
```yaml
Commands:
  - MyApp
  - myapp
  - my-app
```

This guide provides a complete foundation for creating and maintaining a custom winget source. Start with a simple manifest and gradually add more features as needed. 