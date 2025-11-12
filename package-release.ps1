# AffinityPluginLoader Release Packager
# Builds a clean distribution package from Release build output

param(
    [string]$Version = "0.1.0",
    [switch]$IncludeWineFix = $true,
    [switch]$IncludeSymbols = $false
)

$ErrorActionPreference = "Stop"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " AffinityPluginLoader Release Packager" -ForegroundColor Cyan
Write-Host " Version: $Version" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host

# Paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outDirName = "AffinityPluginLoader-v$Version"
$outDir = Join-Path $scriptDir $outDirName
$zipPath = Join-Path $scriptDir "$outDirName.zip"

$affinityHookBin = Join-Path $scriptDir "AffinityHook\bin\x64\Release"
$pluginLoaderBin = Join-Path $scriptDir "AffinityPluginLoader\bin\x64\Release"
$wineFixBin = Join-Path $scriptDir "WineFix\bin\x64\Release"
$bootstrapDir = Join-Path $scriptDir "AffinityBootstrap"

# Verify build outputs exist
if (-not (Test-Path $affinityHookBin)) {
    Write-Error "AffinityHook Release build not found. Build the solution in x64 Release configuration first."
    exit 1
}

if (-not (Test-Path $pluginLoaderBin)) {
    Write-Error "AffinityPluginLoader Release build not found. Build the solution in x64 Release configuration first."
    exit 1
}

# Clean output directory
Write-Host "[1/6] Cleaning output directory..." -ForegroundColor Yellow
if (Test-Path $outDir) {
    Remove-Item $outDir -Recurse -Force
}
New-Item $outDir -ItemType Directory | Out-Null
New-Item (Join-Path $outDir "plugins") -ItemType Directory | Out-Null

# Copy AffinityHook launcher
Write-Host "[2/6] Copying AffinityHook launcher..." -ForegroundColor Yellow
Copy-Item (Join-Path $affinityHookBin "AffinityHook.exe") $outDir
Copy-Item (Join-Path $affinityHookBin "AffinityHook.exe.config") $outDir

# Copy core plugin loader files
Write-Host "[3/6] Copying plugin loader..." -ForegroundColor Yellow
Copy-Item (Join-Path $pluginLoaderBin "AffinityPluginLoader.dll") $outDir
Copy-Item (Join-Path $pluginLoaderBin "0Harmony.dll") $outDir

# Copy native bootstrap (REQUIRED - no longer using EasyHook)
Write-Host "[4/6] Copying native bootstrap..." -ForegroundColor Yellow
$bootstrapDll = Join-Path $bootstrapDir "AffinityBootstrap.dll"
if (Test-Path $bootstrapDll) {
    Copy-Item $bootstrapDll $outDir
    Write-Host "    Included AffinityBootstrap.dll" -ForegroundColor Green
} else {
    Write-Host "    WARNING: AffinityBootstrap.dll not found!" -ForegroundColor Yellow
    Write-Host "    Build it with: cd AffinityBootstrap && build.bat" -ForegroundColor Yellow
}

# Copy WineFix plugin (recommended for Wine users)
Write-Host "[5/6] Copying plugins..." -ForegroundColor Yellow
if ($IncludeWineFix) {
    Write-Host "    Including WineFix plugin..." -ForegroundColor Gray
    if (Test-Path $wineFixBin) {
        Copy-Item (Join-Path $wineFixBin "WineFix.dll") (Join-Path $outDir "plugins\")
        
        if ($IncludeSymbols) {
            Copy-Item (Join-Path $wineFixBin "WineFix.pdb") (Join-Path $outDir "plugins\") -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host "    WARNING: WineFix not found at $wineFixBin" -ForegroundColor Yellow
    }
}

# Optional: Copy debug symbols
if ($IncludeSymbols) {
    Write-Host "    Including debug symbols..." -ForegroundColor Gray
    Copy-Item (Join-Path $affinityHookBin "AffinityHook.pdb") $outDir -ErrorAction SilentlyContinue
    Copy-Item (Join-Path $pluginLoaderBin "AffinityPluginLoader.pdb") $outDir -ErrorAction SilentlyContinue
    Copy-Item (Join-Path $pluginLoaderBin "0Harmony.pdb") $outDir -ErrorAction SilentlyContinue
}

# Copy documentation
Write-Host "[6/6] Copying documentation..." -ForegroundColor Yellow
if (Test-Path (Join-Path $scriptDir "README.md")) {
    Copy-Item (Join-Path $scriptDir "README.md") $outDir
}
if (Test-Path (Join-Path $scriptDir "LICENSE")) {
    Copy-Item (Join-Path $scriptDir "LICENSE") $outDir
}
if (Test-Path (Join-Path $scriptDir "WINE_SUPPORT.md")) {
    Copy-Item (Join-Path $scriptDir "WINE_SUPPORT.md") $outDir
}
if (Test-Path (Join-Path $bootstrapDir "QUICKSTART.md")) {
    Copy-Item (Join-Path $bootstrapDir "QUICKSTART.md") (Join-Path $outDir "BUILDING.md")
}

# Create ZIP archive
Write-Host
Write-Host "Creating ZIP archive..." -ForegroundColor Yellow
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}
Compress-Archive -Path $outDir -DestinationPath $zipPath -CompressionLevel Optimal

# Summary
Write-Host
Write-Host "================================================" -ForegroundColor Green
Write-Host " Package Created Successfully!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host "Location: $zipPath" -ForegroundColor White
Write-Host

# Show package contents
Write-Host "Package Contents:" -ForegroundColor Cyan
Get-ChildItem $outDir -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($outDir.Length + 1)
    $size = "{0:N2} KB" -f ($_.Length / 1KB)
    Write-Host "  $relativePath" -NoNewline -ForegroundColor Gray
    Write-Host " ($size)" -ForegroundColor DarkGray
}

# Calculate total size
$totalSize = (Get-ChildItem $outDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
Write-Host
Write-Host "Total Size: " -NoNewline
Write-Host ("{0:N2} MB" -f ($totalSize / 1MB)) -ForegroundColor Yellow