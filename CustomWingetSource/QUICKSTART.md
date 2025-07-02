# Quick Start Guide: Custom Winget Source

This guide will help you create a custom winget source in 5 minutes.

## Prerequisites

1. **Windows 10/11** with winget installed
2. **PowerShell 5.1+**
3. **GitHub account** (for hosting)

## Step 1: Create Your Source Structure

Run the automation script:

```powershell
# Navigate to the CustomWingetSource directory
cd CustomWingetSource

# Create a new winget source
.\Create-WingetSource.ps1 -Action Create -SourceName "MyCompany" -PackageName "MyApp" -PackageVersion "1.0.0" -Publisher "MyCompany" -SourceUrl "https://mycompany.com/winget"
```

## Step 2: Customize Your Manifests

Edit the generated files in the `WingetSource` directory:

1. **Update URLs** in all manifest files to point to your actual URLs
2. **Update SHA256 hashes** for your actual installer files
3. **Customize descriptions** and metadata

## Step 3: Host Your Source

### Option A: GitHub Pages (Recommended)

1. Create a new GitHub repository
2. Upload all files from the `WingetSource` directory
3. Go to Settings → Pages
4. Enable GitHub Pages from the main branch
5. Your source URL will be: `https://yourusername.github.io/repositoryname`

### Option B: Local Testing

```powershell
# Start a local HTTP server
cd WingetSource
python -m http.server 8080
# Your source URL will be: http://localhost:8080
```

## Step 4: Add Your Source to Winget

```powershell
# Add the source
.\Create-WingetSource.ps1 -Action Add -SourceName "MyCompany" -SourceUrl "https://yourusername.github.io/repositoryname"

# Or manually:
winget source add --name "MyCompany" --arg "https://yourusername.github.io/repositoryname"
```

## Step 5: Test Your Source

```powershell
# List sources
winget source list

# Search for your package
winget search MyCompany.MyApp

# Install your package
winget install MyCompany.MyApp
```

## Step 6: Validate Your Manifests

```powershell
# Install winget-create if not already installed
winget install Microsoft.WingetCreate

# Validate your manifests
.\Create-WingetSource.ps1 -Action Validate -OutputPath ".\WingetSource"
```

## Common Issues & Solutions

### Manifest Validation Errors
- Check YAML syntax (indentation matters)
- Ensure all required fields are present
- Verify URLs are accessible

### Source Not Found
- Ensure your web server is running
- Check that `index.json` is accessible at the root URL
- Verify HTTPS is used for production

### Installation Failures
- Verify installer URLs are correct
- Check SHA256 hashes match your actual files
- Ensure installer switches are correct for your installer type

## Next Steps

1. **Add more packages** to your source
2. **Support multiple architectures** (x64, x86, arm64)
3. **Add localization** for multiple languages
4. **Set up automated updates** for new versions
5. **Add dependencies** between packages

## Example: Complete Workflow

```powershell
# 1. Create source structure
.\Create-WingetSource.ps1 -Action Create -SourceName "MyCompany" -PackageName "MyApp" -PackageVersion "1.0.0"

# 2. Customize manifests (edit files manually)

# 3. Validate manifests
.\Create-WingetSource.ps1 -Action Validate -OutputPath ".\WingetSource"

# 4. Deploy to GitHub Pages (upload files manually)

# 5. Add source to winget
.\Create-WingetSource.ps1 -Action Add -SourceName "MyCompany" -SourceUrl "https://yourusername.github.io/repositoryname"

# 6. Test installation
winget install MyCompany.MyApp
```

That's it! You now have a working custom winget source. 🎉 