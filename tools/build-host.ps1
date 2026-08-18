param(
    [ValidateSet("win-x64", "win-arm64", "linux-x64", "linux-arm64", "osx-arm64")]
    [string] $Runtime = $(
        $arch = $null
        try { $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString() }
        catch { $arch = $env:PROCESSOR_ARCHITECTURE }
        if (-not $arch) { $arch = $env:PROCESSOR_ARCHITECTURE }
        $isWindows = if (Get-Variable -Name IsWindows -ErrorAction SilentlyContinue) { [bool]$IsWindows } else { [bool]($env:OS -match "Windows") }
        $isMac = if (Get-Variable -Name IsMacOS -ErrorAction SilentlyContinue) { [bool]$IsMacOS } else { $false }
        $arm = $arch -match "Arm|ARM64|Aarch64|AArch64"
        if ($isWindows) { if ($arm) { "win-arm64" } else { "win-x64" } }
        elseif ($isMac) { "osx-arm64" }
        elseif ($arm) { "linux-arm64" }
        else { "linux-x64" }
    ),
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
