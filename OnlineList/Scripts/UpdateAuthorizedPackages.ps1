<#
.SYNOPSIS
Updates the list of authorized packages by searching for package IDs in a specified directory.

.DESCRIPTION
This script reads a list of authorized package IDs from a JSON file and searches for corresponding package files
in a specified directory. It constructs paths for each package file based on the IDs and outputs the results.

.PARAMETER IdListPath
The path to the JSON file containing the list of authorized package IDs.
It expects the file to contain an array of package IDs in JSON format.

.PARAMETER SearchPath
The directory where the script will search for package manifests.
It expects the directory to contain package files named according to the IDs.

.PARAMETER OutputPath
The path where the output will be saved.
It expects the directory or file to be valid and writable.

.EXAMPLE
$param = @{
    IdListPath = "C:\path\to\authorizedPackages.json"
    SearchPath = "C:\path\to\packages"
    OutputPath = "C:\path\to\output"
}
.\UpdateAuthorizedPackages.ps1 @param
This example runs the script with specified paths for the authorized package IDs, the search directory, and the output location.

.NOTES
Author: Adam R-B
Date: 2025-07-06

#>
param (
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
    [string]$IdListPath,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType 'Container' })]
    [string]$SearchPath,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -IsValid })]
    [string]$OutputPath
)

. "$PSScriptRoot\PackageClasses.ps1"
# Load the list of authorized package IDs
Get-Content -Path $IdListPath | ConvertFrom-Json | ForEach-Object {
    [PackageObject]::new($_, $SearchPath)
}
