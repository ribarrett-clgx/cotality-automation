# =====================================
# Diablo DNA Dataset Quarterly Pipeline
# =====================================

Start-Transcript -Path "D:\PxPointDataBuild\diablo_build_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

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
$DNAPath = "$BasePath\$Quarter\VendorRaw\DNA"
$LicenseSrc = "$BasePath\$Quarter\RefData\CoreLogicAll.lic"
$LicenseDst = "C:\license\CoreLogicAll.lic"
$DatasetDir = "$BasePath\$PreviousQuarter\dataset\"
$DAProcess = "$BasePath\$Quarter\bin\DAProcess.exe"
$NumThreads = 100
$DateStamp = Get-Date -Format yyyyMMdd
$DNAInput = "$DNAPath\Parcel_Point_Delivery_${DateStamp}.txt"
$DNAOutput = "$DNAPath\Parcel_Point_Geocoded_${DateStamp}.txt"
$TrimmedOutput = "$DNAPath\Parcel_Point_Geocoded_${DateStamp}_to_RCT.txt"
$GCSBucket = "gs://spatial-pxpoint-vendor-curated/$Quarter/DNA"

# Step 1: Prepare folders and copy license
Write-Host "`n--- Preparing environment and license ---"
New-Item -ItemType Directory -Force -Path "C:\license"
Copy-Item -Force $LicenseSrc $LicenseDst

# Step 2: Run DAProcess.exe
Write-Host "`n--- Running DAProcess.exe ---"
$env:PXPOINT_IGNORE_VERSION = 1
& $DAProcess `
  -inputFile $DNAInput `
  -licFile $LicenseDst `
  -datasetDir $DatasetDir `
  -numThreads $NumThreads `
  *> "$BasePath\$Quarter\logs\Parcel_Point_Delivery_${DateStamp}.log"

# Step 3: Trim geocoded file to RCT-required columns
Write-Host "`n--- Trimming geocoded file to RCT columns ---"
$columns = "1,2,3,27,28,36,37,39,40,42,43,44,45,46,47,48,49,50"
$cutCmd = "cut -d '|' -f $columns `"$DNAOutput`" > `"$TrimmedOutput`""
powershell.exe -Command $cutCmd

# Step 4: Compress output files with 7-Zip
Write-Host "`n--- Compressing output files ---"
& "C:\Program Files\7-Zip\7z.exe" a "$DNAOutput.zip" $DNAOutput
& "C:\Program Files\7-Zip\7z.exe" a "$TrimmedOutput.zip" $TrimmedOutput

# Step 5: Upload to GCS
Write-Host "`n--- Uploading to GCS ---"
& gsutil cp $DNAOutput $GCSBucket
& gsutil cp $TrimmedOutput $GCSBucket

# Step 6: Notify RCT
Write-Host "`n--- Reminder: Email RCT team (manual) ---"
Write-Host "To: dgossett@corelogic.com"
Write-Host "Subject: DNA geocoded data is available"
Write-Host "Body:"
Write-Host "Files available at:"
Write-Host "  $GCSBucket/Parcel_Point_Geocoded_${DateStamp}.txt"
Write-Host "  $GCSBucket/Parcel_Point_Geocoded_${DateStamp}_to_RCT.txt"
Write-Host "BigQuery Table: clgx-pxpointbld-app-dev-19c3.DNA_Geocoded_for_RCT.Parcel_Point_Geocoded_${DateStamp}_to_RCT"

Stop-Transcript
