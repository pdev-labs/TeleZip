param(
    [string]$ParentDir = ""
)

# Get parent directory from argument or prompt
if ([string]::IsNullOrWhiteSpace($ParentDir)) {
    $ParentDir = Read-Host "Enter the path of the parent folder"
}

# Resolve absolute path
try {
    # If the path doesn't exist, this will throw an error
    $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ParentDir)
    if (Test-Path $resolvedPath) {
        $ParentDir = (Resolve-Path $ParentDir).Path
    } else {
        Write-Host "Error: Directory '$ParentDir' does not exist." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error: Directory '$ParentDir' does not exist." -ForegroundColor Red
    exit 1
}

# Verify it's a directory
if (-Not (Test-Path -Path $ParentDir -PathType Container)) {
    Write-Host "Error: '$ParentDir' is not a directory." -ForegroundColor Red
    exit 1
}

$ParentName = (Get-Item $ParentDir).Name
$OutputDir = Join-Path -Path $ParentDir -ChildPath "$ParentName-zip"

Write-Host "Output directory: $OutputDir"

# Create output directory if it doesn't exist
if (-Not (Test-Path -Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Get all subdirectories, excluding the output directory itself
$Subfolders = Get-ChildItem -Path $ParentDir -Directory | Where-Object { $_.FullName -ne $OutputDir }

if ($Subfolders.Count -eq 0) {
    Write-Host "No subfolders found in '$ParentDir'." -ForegroundColor Yellow
} else {
    foreach ($Sub in $Subfolders) {
        $ZipPath = Join-Path -Path $OutputDir -ChildPath "$($Sub.Name).zip"
        Write-Host "Zipping '$($Sub.Name)'..."
        
        # Windows PowerShell has Compress-Archive built-in, so no extra tools need to be installed
        Compress-Archive -Path "$($Sub.FullName)\*" -DestinationPath $ZipPath -Force
    }
    
    Write-Host "Done! All zip files are saved in:" -ForegroundColor Green
    Write-Host "  -> $OutputDir" -ForegroundColor Green
}
