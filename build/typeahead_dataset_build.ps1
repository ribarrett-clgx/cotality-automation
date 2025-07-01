# ============================================
# Typeahead Dataset Build - Quarterly Pipeline
# With Per-step Error Handling & Exit Codes
# ============================================

Start-Transcript -Path "D:\PxPointDataBuild\typeahead_build_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Get-CurrentQuarter {
    $now = Get-Date
    $year = $now.Year
    $quarter = [math]::Ceiling($now.Month / 3)
    return "$($year)q$quarter"
}

function Exit-OnError {
    param([string]$step)
    if (!$?) {
        Write-Host "❌ FAILED at step: $step"
        Stop-Transcript
        exit 1
    }
}

$Quarter = Get-CurrentQuarter
$BasePath = "D:\PxPointDataBuild\$Quarter"
$BinPath = "$BasePath\bin"
$DatasetPath = "$BasePath\dataset"
$LogPath = "$BasePath\logs"
$LicenseFile = "C:\license\CoreLogicAll.lic"
$Threads = 10
$SevenZip = "C:\Program Files\7-Zip\7z.exe"

Write-Host "Starting Typeahead dataset builds for $Quarter"

# Parcel_us_atx Build
Write-Host "`n🚀 Building parcel_us_atx Typeahead dataset..."
& "$BinPath\BuildTypeaheadDataset.exe" `
    -inputFile "$DatasetPath\parcel_us.gdx" `
    -licFile $LicenseFile `
    -atxDir "$DatasetPath\parcel_us_atx" `
    -buildCounties `
    -numThreads $Threads `
    >> "$LogPath\typeahead_parcel_us_atx.log" 2>&1
Exit-OnError "Build parcel_us_atx -buildCounties"

& "$BinPath\BuildTypeaheadDataset.exe" `
    -inputFile "$DatasetPath\parcel_us.gdx" `
    -licFile $LicenseFile `
    -atxDir "$DatasetPath\parcel_us_atx" `
    -buildRegions `
    -numThreads $Threads `
    >> "$LogPath\typeahead_parcel_us_atx.log" 2>&1
Exit-OnError "Build parcel_us_atx -buildRegions"

# Copy results to NFS
Write-Host "📁 Copying parcel_us_atx results to NFS..."
Copy-Item -Recurse "$DatasetPath\parcel_us_atx" "P:\$Quarter\dataset\$(Get-Date -Format 'yyyy-MM-dd')_parcel_us_atx"
Exit-OnError "Copy parcel_us_atx to NFS"

# ParcelPlus_us_atx Build
Write-Host "`n🚀 Building parcelplus_us_atx Typeahead dataset..."
& "$BinPath\BuildTypeaheadDataset.exe" `
    -inputFile "$DatasetPath\parcelplus_us.gdx" `
    -licFile $LicenseFile `
    -atxDir "$DatasetPath\parcelplus_us_atx" `
    -buildCounties `
    -numThreads $Threads `
    >> "$LogPath\typeahead_parcelplus_us_atx.log" 2>&1
Exit-OnError "Build parcelplus_us_atx -buildCounties"

& "$BinPath\BuildTypeaheadDataset.exe" `
    -inputFile "$DatasetPath\parcelplus_us.gdx" `
    -licFile $LicenseFile `
    -atxDir "$DatasetPath\parcelplus_us_atx" `
    -buildRegions `
    -numThreads $Threads `
    >> "$LogPath\typeahead_parcelplus_us_atx.log" 2>&1
Exit-OnError "Build parcelplus_us_atx -buildRegions"

# Copy results to NFS
Write-Host "📁 Copying parcelplus_us_atx results to NFS..."
Copy-Item -Recurse "$DatasetPath\parcelplus_us_atx" "P:\$Quarter\dataset\$(Get-Date -Format 'yyyy-MM-dd')_parcelplus_us_atx"
Exit-OnError "Copy parcelplus_us_atx to NFS"

# Compress Typeahead directories
Write-Host "`n📦 Compressing parcel_us_atx dataset..."
& $SevenZip a "$DatasetPath\parcel_us_atx.zip" "$DatasetPath\parcel_us_atx\*"
Exit-OnError "Compress parcel_us_atx"

Write-Host "`n📦 Compressing parcelplus_us_atx dataset..."
& $SevenZip a "$DatasetPath\parcelplus_us_atx.zip" "$DatasetPath\parcelplus_us_atx\*"
Exit-OnError "Compress parcelplus_us_atx"

Write-Host "`n✅ Typeahead builds complete."

Stop-Transcript
