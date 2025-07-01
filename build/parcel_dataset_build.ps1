# ===============================================
# Parcel & ParcelPlus Dataset Build Automation
# ===============================================

Start-Transcript -Path "D:\PxPointDataBuild\parcel_build_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Get-CurrentQuarter {
    $now = Get-Date
    $year = $now.Year
    $quarter = [math]::Ceiling($now.Month / 3)
    return "$($year)q$quarter"
}

function Get-PreviousQuarter {
    $now = Get-Date
    $year = $now.Year
    $quarter = [math]::Ceiling($now.Month / 3)
    if ($quarter -eq 1) {
        $year -= 1
        $quarter = 4
    } else {
        $quarter -= 1
    }
    return "$($year)q$quarter"
}

$Quarter = Get-CurrentQuarter
$PreviousQuarter = Get-PreviousQuarter
$BasePath = "D:\PxPointDataBuild"
$BinPath = "$BasePath\$Quarter\bin"
$LogsPath = "$BasePath\$Quarter\logs"
$RefDataPath = "$BasePath\$Quarter\RefData"

# Step 1: Launch the ParcelBuildConsole.exe UI
$parcelBuildExe = "$BinPath\ParcelBuilderNew.exe"
Write-Host "Launching ParcelBuilderNew.exe - Please use the UI to trigger ParcelPlus and Parcel builds."
Start-Process -FilePath $parcelBuildExe

# Step 2: Reminder - Run Diff Testing (via 43MillionComparisonTest.exe)
Write-Host "Reminder: Run diff testing using 43MillionComparisonTest.exe:"
Write-Host "  1. Create baseline: --cmd gdxgeocode"
Write-Host "  2. Run diff: --cmd gdxdiff"
Write-Host "  3. Generate analysis: --cmd diffexamine"
Write-Host "Example:"
Write-Host "43MillionComparisonTest.exe --cmd gdxdiff --baseline path_to_baseline.txt --second path_to_parcel.gdx ..."

# Step 3: Compress the datasets using 7-Zip
Write-Host "Compressing Parcel and ParcelPlus datasets..."
$SevenZip = "C:\Program Files\7-Zip\7z.exe"
& $SevenZip a "$BasePath\$Quarter\parcel_us.zip" "$BasePath\$Quarter\release\parcel_us.gdx"
& $SevenZip a "$BasePath\$Quarter\parcelplus_us.zip" "$BasePath\$Quarter\release\parcelplus_us.gdx"

# Step 4: Reminder - Load into BigQuery
Write-Host "`nReminder: Load compressed Parcel and ParcelPlus datasets into BigQuery manually."
Write-Host "Files:"
Write-Host "  - $BasePath\$Quarter\release\parcel_us.gdx"
Write-Host "  - $BasePath\$Quarter\release\parcelplus_us.gdx"

# Step 5: Reminder - Perform BQ validation & profiling
Write-Host "`nReminder: Validate BigQuery row counts and file schema."
Write-Host "  - Use bq show and bq head to confirm structure and sample data"
Write-Host "  - Verify row counts match CSVs"

Stop-Transcript
