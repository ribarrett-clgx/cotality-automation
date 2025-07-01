# ===============================
# setup.ps1 – PxPoint Environment Bootstrap
# ===============================

Write-Host "🔧 Starting PxPoint build environment validation..."

# Check required tools
$tools = @(
    "7z.exe",
    "docker",
    "gsutil.cmd",
    "powershell.exe",
    "cmake.exe"
)

foreach ($tool in $tools) {
    Write-Host "Checking $tool..."
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "❌ $tool not found in PATH." -ForegroundColor Red
    } else {
        Write-Host "✅ $tool found."
    }
}

# Check required environment variables
$envVars = @("JAVA_HOME")
foreach ($var in $envVars) {
    if (-not $Env:$var) {
        Write-Host "❌ Environment variable $var not set." -ForegroundColor Red
    } else {
        Write-Host "✅ $var is set to $($Env:$var)"
    }
}

# Check required PxPoint binaries exist
$requiredBinaries = @(
    "D:\\PxPointDataBuild\\Tools\\43MillionComparisonTest.exe",
    "D:\\PxPointDataBuild\\Tools\\DAProcess.exe",
    "D:\\PxPointDataBuild\\Tools\\BuildTypeaheadDataset.exe"
)

foreach ($binary in $requiredBinaries) {
    if (-not (Test-Path $binary)) {
        Write-Host "❌ Missing binary: $binary" -ForegroundColor Red
    } else {
        Write-Host "✅ Found binary: $binary"
    }
}

Write-Host "✅ Environment bootstrap check complete."
Write-Host "🚀 Starting PxPoint build process..."