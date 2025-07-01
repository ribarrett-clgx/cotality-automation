# ================================
# PxPoint Quarterly Build Orchestrator
# With Error Aggregation & Parallelism
# ================================

Start-Transcript -Path "D:\\PxPointDataBuild\\orchestrator_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Load config
$config = . .\\build_config.ps1

$errors = @()
$jobs = @()

foreach ($build in $config.builds) {
    $script = $build.script
    $isParallel = $build.parallel

    if ($isParallel) {
        Write-Host "🧵 Starting $script in parallel..."
        $jobs += Start-Job -ScriptBlock {
            param($s)
            try {
                & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $s
                if ($LASTEXITCODE -ne 0) {
                    Write-Output "❌ $s failed with exit code $LASTEXITCODE"
                } else {
                    Write-Output "✅ $s completed successfully."
                }
            } catch {
                Write-Output "❌ Exception in $s: $_"
            }
        } -ArgumentList $script
    } else {
        Write-Host "🚀 Running $script sequentially..."
        try {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script
            if ($LASTEXITCODE -ne 0) {
                $errors += "❌ $script failed with exit code $LASTEXITCODE"
            } else {
                Write-Host "✅ $script completed."
            }
        } catch {
            $errors += "❌ Exception in $script: $_"
        }
    }
}

# Wait for parallel jobs
if ($jobs.Count -gt 0) {
    Write-Host "⏳ Waiting for parallel jobs to finish..."
    $jobs | Wait-Job | ForEach-Object {
        $result = Receive-Job $_
        Write-Host $result
        if ($result -match '❌') {
            $errors += $result
        }
    }
}

# Final aggregated error report
if ($errors.Count -gt 0) {
    Write-Host "`n❌ BUILD FAILURES SUMMARY:"
    $errors | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    Stop-Transcript
    exit 1
} else {
    Write-Host "`n✅ ALL BUILDS COMPLETED SUCCESSFULLY."
}

Stop-Transcript

Write-Host "`n📊 ==== PxPoint Build Summary ===="
foreach ($build in $config.builds) {
    $scriptName = $build.script
    if ($errors -contains $scriptName) {
        Write-Host "$scriptName : ❌ Failed" -ForegroundColor Red
    } else {
        Write-Host "$scriptName : ✅ Success"
    }
}
