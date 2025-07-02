# GitHub-Hosted Winget REST Source Setup

This guide shows you how to create a winget REST source hosted on GitHub using either Azure Functions or GitHub Pages.

## Option 1: Azure Functions + GitHub Actions (Recommended)

### Prerequisites

1. **Azure subscription** with billing enabled
2. **GitHub repository** with Actions enabled
3. **Visual Studio 2022** (for local development)

### Step 1: Fork the Official Repository

```bash
# Fork the official Microsoft repository
git clone https://github.com/microsoft/winget-cli-restsource.git
cd winget-cli-restsource

# Create your own repository
git remote set-url origin https://github.com/yourusername/your-winget-source.git
git push -u origin main
```

### Step 2: Set Up Azure Resources

1. **Create Azure Function App:**
```powershell
# Install Azure CLI if not already installed
winget install Microsoft.AzureCLI

# Login to Azure
az login

# Create resource group
az group create --name MyWingetSource --location EastUS

# Create storage account
az storage account create --name mywingetsource --resource-group MyWingetSource --location EastUS --sku Standard_LRS

# Create Function App
az functionapp create --resource-group MyWingetSource --consumption-plan-location EastUS --runtime dotnet --functions-version 4 --name my-winget-source --storage-account mywingetsource --os-type Windows
```

2. **Create CosmosDB:**
```powershell
# Create CosmosDB account
az cosmosdb create --name my-winget-cosmos --resource-group MyWingetSource

# Create database
az cosmosdb sql database create --account-name my-winget-cosmos --resource-group MyWingetSource --name WinGet

# Create container
az cosmosdb sql container create --account-name my-winget-cosmos --resource-group MyWingetSource --database-name WinGet --name Manifests --partition-key-path "/id"
```

### Step 3: Configure GitHub Secrets

In your GitHub repository, go to **Settings → Secrets and variables → Actions** and add:

- `AZURE_FUNCTIONAPP_NAME`: Your Function App name (e.g., `my-winget-source`)
- `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`: Download from Azure Portal → Function App → Overview → Get publish profile
- `FUNCTION_HOST_KEY`: Get from Azure Portal → Function App → App keys → _master key

### Step 4: Deploy

Push to your main branch and the GitHub Action will automatically deploy:

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

### Step 5: Add to Winget

```powershell
# Add your REST source
winget source add -n "MyPrivateSource" -a "https://my-winget-source.azurewebsites.net/api/" -t "Microsoft.Rest"

# Verify it's added
winget source list

# Test search
winget search --source "MyPrivateSource"
```

## Option 2: GitHub Pages + Static REST API (Simpler)

### Step 1: Create Repository Structure

```bash
mkdir my-winget-static-source
cd my-winget-static-source
git init
```

### Step 2: Add Files

Copy the files from this repository:
- `.github/workflows/deploy-static-rest.yml`
- `api/index.json`
- `package.json`

### Step 3: Enable GitHub Pages

1. Go to **Settings → Pages**
2. Source: **Deploy from a branch**
3. Branch: **gh-pages** (will be created by the workflow)
4. Click **Save**

### Step 4: Deploy

```bash
git add .
git commit -m "Initial static REST API"
git push origin main
```

### Step 5: Add to Winget

```powershell
# Add your static REST source
winget source add -n "MyStaticSource" -a "https://yourusername.github.io/my-winget-static-source/api/" -t "Microsoft.Rest"
```

## Managing Packages

### Option 1: Using GitHub Actions (Azure Functions)

1. Go to **Actions → Manage Winget Packages**
2. Click **Run workflow**
3. Fill in the details:
   - Action: `add`
   - Package ID: `MyCompany.MyApp`
   - Package Version: `1.0.0`
   - Manifest Path: `manifests/MyApp.yaml`

### Option 2: Direct API Calls

```powershell
# Add a package
$manifest = Get-Content "manifests/MyApp.yaml" -Raw
Invoke-RestMethod -Uri "https://my-winget-source.azurewebsites.net/api/PackageManifestPost" -Method POST -Body $manifest -Headers @{"x-functions-key"="your-key"}

# Update a package
Invoke-RestMethod -Uri "https://my-winget-source.azurewebsites.net/api/PackageManifestPut" -Method PUT -Body $manifest -Headers @{"x-functions-key"="your-key"}

# Delete a package
Invoke-RestMethod -Uri "https://my-winget-source.azurewebsites.net/api/PackageManifestDelete?packageId=MyCompany.MyApp&version=1.0.0" -Method DELETE -Headers @{"x-functions-key"="your-key"}
```

### Option 3: Manual File Updates (Static API)

For the static approach, simply update the `api/index.json` file and push:

```bash
# Edit api/index.json
git add api/index.json
git commit -m "Add new package"
git push origin main
```

## Testing Your Source

```powershell
# List sources
winget source list

# Search packages
winget search --source "MyPrivateSource"

# Install a package
winget install MyCompany.MyApp --source "MyPrivateSource"

# Update source
winget source update --name "MyPrivateSource"
```

## Troubleshooting

### Common Issues:

1. **Function App not found:**
   - Check Azure Function App name in secrets
   - Verify publish profile is correct

2. **Authentication errors:**
   - Check function host key
   - Verify CORS settings in Azure

3. **Package not found:**
   - Check package ID format (Publisher.PackageName)
   - Verify manifest structure

4. **GitHub Pages not working:**
   - Check repository settings
   - Verify workflow completed successfully

### Debug Commands:

```powershell
# Test REST API directly
Invoke-RestMethod -Uri "https://my-winget-source.azurewebsites.net/api/InformationGet"

# Check source status
winget source list --verbose

# Reset sources if needed
winget source reset --force
```

## Cost Considerations

### Azure Functions:
- **Free tier**: 1M requests/month
- **Consumption plan**: Pay per execution
- **CosmosDB**: Free tier available (25GB storage, 400 RU/s)

### GitHub Pages:
- **Free**: Unlimited for public repositories
- **Private repos**: Requires GitHub Pro ($4/month)

## Security Best Practices

1. **Use Azure Key Vault** for sensitive configuration
2. **Enable authentication** for write operations
3. **Use HTTPS** for all endpoints
4. **Validate manifests** before adding
5. **Monitor usage** and set up alerts

## Next Steps

1. **Add authentication** to your REST source
2. **Set up monitoring** and logging
3. **Create automated testing** for your packages
4. **Implement CI/CD** for package updates
5. **Add documentation** for your packages

This setup gives you a fully functional winget REST source hosted on GitHub with automated deployment and package management capabilities. 