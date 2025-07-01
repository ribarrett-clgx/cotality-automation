# ===============================
# cleanup_logs.ps1 – Log Cleanup Script
# ===============================

$logDir = "D:\\PxPointDataBuild"
$retentionDays = 90

Write-Host "🧹 Cleaning up logs older than $retentionDays days in $logDir..."

Get-ChildItem -Path $logDir -Recurse -Include *.log | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$retentionDays) } | Remove-Item -Force

Write-Host "✅ Log cleanup complete."
