class PackageVersion {
    # Properties for PackageVersion class
    [System.String]$Version
    [System.String]$ManifestPath
    [System.Collections.ObjectModel.Collection[PackageLocale]]$Locales
    [PackageLocale]$DefaultLocale

    # Constructor(s) for PackageVersion class
    PackageVersion([System.String]$version, [System.String]$manifestPath, [boolean]$isLatest = $false) {
        $this.Version = $version
        $this.ManifestPath = $manifestPath
        $this.SetLocales()
        $this.DefaultLocale = $this.Locales | Where-Object { $_.IsDefault } | Select-Object -First 1
    }

    # Method(s) for PackageVersion class
    [void]SetLocales() {
        $packageId = Split-Path -Path $this.ManifestPath -LeafBase
        Get-ChildItem -Path (Split-Path -Path $this.ManifestPath -Parent) | Where-Object {
            $_.Name -match "^$packageId\.locale\.[a-z]{2}(-[A-Z]{2})?\.yaml$"
        } | ForEach-Object {
            $locale = $_.BaseName -replace "^$packageId\.locale\.", ''
            $manifestPath = $_.FullName
            $isDefault = Select-String -Path $manifestPath -Pattern 'ManifestType: defaultLocale' -Quiet
            $this.Locales += [PackageLocale]::new($locale, $manifestPath, $isDefault)
        }
    }
}

class PackageLocale {
    # Properties for PackageLocale class
    [System.String]$Locale
    [System.String]$ManifestPath
    [boolean]$IsDefault

    # Constructor(s) for PackageLocale class
    PackageLocale([System.String]$locale, [System.String]$manifestPath, [boolean]$isDefault = $false) {
        $this.Locale = $locale
        $this.ManifestPath = $manifestPath
        $this.IsDefault = $isDefault
    }

}

class PackageObject {
    # Properties for PackageObject class
    [System.String]$Id
    [System.String]$DisplayName
    [System.String]$Publisher
    [System.String]$LatestVersion
    [PackageVersion]$LatestVersionObject
    [System.Collections.ObjectModel.Collection[PackageVersion]]$VersionObjects
    [System.String]$Path

    # Constructor(s) for PackageObject class
    PackageObject( [System.String] $id, [System.String] $manifestsRoot ) {
        $this.Id = $id
        $this.SetPackagePath($manifestsRoot)
        $this.SetVersions()
        $this.SetLatestVersion()
        $this.SetPackageInformations()
    }

    # Method(s) for PackageObject class
    hidden [void]SetPackagePath([System.String]$manifestsRoot) {
        $this.Path = Join-Path $manifestsRoot ($this.Id.Substring(0, 1).ToLower()) ($this.Id.Split('.'))
    }

    hidden [void]SetVersions() {
        Get-ChildItem -Path $this.Path -Recurse -Depth 1 -Filter "$($this.Id).yaml" | ForEach-Object {
            $version = $_.Directory.BaseName
            $manifestPath = $_.FullName
            $this.VersionObjects += [PackageVersion]::new($version, $manifestPath, $isLatest)
        }
    }

    hidden [void]SetLatestVersion() {
        $this.LatestVersionObject = ($this.VersionObjects | Sort-Object -Property 'Version' -Descending | Select-Object -First 1)
    }

    hidden [void]SetPackageInformations() {
        $latestDefaultLocaleManifest = Get-Content $this.LatestVersionObject.DefaultLocale.ManifestPath -Raw
        $this.DisplayName = [regex]::Matches($latestDefaultLocaleManifest, 'PackageName:\s*(.+)').Groups[1].Value.Trim()
        $this.Publisher = [regex]::Matches($latestDefaultLocaleManifest, 'Publisher:\s*(.+)').Groups[1].Value.Trim()
        $this.LatestVersion = $this.LatestVersionObject.Version

    }

    [PackageVersion]GetVersion([System.String]$version) {
        return $this.VersionObjects | Where-Object { $_.Version -eq $version } | Select-Object -First 1
    }

}
