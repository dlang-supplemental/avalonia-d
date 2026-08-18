param(
    [ValidateSet("win-x64", "linux-x64", "osx-x64", "osx-arm64")]
    [string] $Runtime = $(if ($IsWindows -or $env:OS -match "Windows") { "win-x64" } elseif ($IsMacOS) { "osx-arm64" } else { "linux-x64" }),
    [ValidateSet("Debug", "Release")]
    [string] $Configuration = "Release"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$proj = Join-Path $root "host/AvaloniaD.Host/AvaloniaD.Host.csproj"
$outDir = Join-Path $root "native/$Runtime"

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw "dotnet SDK is required to build the Avalonia host."
}

Write-Host "Publishing AvaloniaD.Host ($Configuration, $Runtime)..."
dotnet publish $proj -c $Configuration -r $Runtime --self-contained false -o $outDir
if ($LASTEXITCODE -ne 0) {
    throw "dotnet publish failed with exit $LASTEXITCODE"
}

$dnneBin = Join-Path $root "host/AvaloniaD.Host/obj/$Configuration/net9.0/$Runtime/dnne/bin"
if (Test-Path $dnneBin) {
    Copy-Item (Join-Path $dnneBin "AvaloniaD.HostNE.dll") $outDir -Force -ErrorAction SilentlyContinue
    Copy-Item (Join-Path $dnneBin "libAvaloniaD.HostNE.so") $outDir -Force -ErrorAction SilentlyContinue
    Copy-Item (Join-Path $dnneBin "libAvaloniaD.HostNE.dylib") $outDir -Force -ErrorAction SilentlyContinue
}

$shimNames = @(
    "AvaloniaD.HostNE.dll",
    "libAvaloniaD.HostNE.so",
    "libAvaloniaD.HostNE.dylib",
    "AvaloniaD.HostNE.so",
    "AvaloniaD.HostNE.dylib"
)
$found = Get-ChildItem $outDir -File | Where-Object { $shimNames -contains $_.Name }
if (-not $found) {
    Write-Warning "DNNE native shim not found in $outDir. Listing output:"
    Get-ChildItem $outDir | Select-Object -ExpandProperty Name
}

Write-Host "Host published to $outDir"
