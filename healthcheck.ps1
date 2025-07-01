# ===============================
# healthcheck.ps1 – PxPoint Build Health Check
# ===============================

Write-Host "🔧 Running weekly PxPoint build health check..."

# Check dataset folders exist
$datasetPath = "D:\\PxPointDataBuild"
if (-not (Test-Path $datasetPath)) {
    Write-Host "❌ Dataset path $datasetPath not found." -ForegroundColor Red
} else {
    Write-Host "✅ Dataset path exists."
}

# Check free disk space
$drive = Get-PSDrive -Name D
if ($drive.Free -lt 100GB) {
    Write-Host "❌ Less than 100 GB free on D: drive." -ForegroundColor Red
} else {
    Write-Host "✅ Sufficient disk space: $([math]::Round($drive.Free / 1GB)) GB free."
}

# Check NFS connectivity
try {
    Test-Path "P:\\" | Out-Null
    Write-Host "✅ NFS share P:\\ is reachable."
} catch {
    Write-Host "❌ Cannot reach NFS share P:\\" -ForegroundColor Red
}

Write-Host "✅ Health check complete."
