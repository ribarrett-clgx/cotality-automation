# =============================================
# USPS & Navteq Dataset Build - Quarterly Script
# =============================================

Start-Transcript -Path "D:\PxPointDataBuild\usps_navteq_build_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

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
$HereRawPath = "$BasePath\$Quarter\VendorRaw\here"
$HerePrepPath = "$BasePath\$Quarter\VendorPrepared\here"
$RepoPath = "D:\Users\<username>\git\spatial_us-pxpoint-pipelines\dataset-build\scripts\pxpoint-bld\RefBuild\here"
$BinPath = "$BasePath\$Quarter\bin"

# Step 1: Run download_from_xml.py to fetch Navteq tarballs
Write-Host "Downloading Navteq tars..."
python.exe "$RepoPath\download_from_xml.py" `
  -x "$HereRawPath\filesNotDownloaded.xml" `
  -d "$HereRawPath\tars\"

# Step 2: Unpack tars to extract dcas
Write-Host "Unpacking Navteq DCAs..."
python.exe "$RepoPath\unpack_tars.py" `
  -s "$HereRawPath\tars\" `
  -d "$HereRawPath\untars\"

# Step 3: Unpack zip5 and zip9 shapefiles
Write-Host "Unpacking Navteq zip5/zip9 shapefiles..."
python.exe "$RepoPath\unpack_zip5_zip9.py" `
  -s "$HereRawPath\tars\" `
  -d "$HereRawPath\untars\"

# Step 4: Move extracted data to VendorPrepared
Write-Host "Moving prepared Navteq data to VendorPrepared..."
Move-Item "$HereRawPath\untars\dcas" "$HerePrepPath\dcas" -Force
Move-Item "$HereRawPath\untars\zip5polys" "$HerePrepPath\zip5polys" -Force
Move-Item "$HereRawPath\untars\zip9centroids" "$HerePrepPath\zip9centroids" -Force

# Step 5: Setup and launch USPSBuildConsole.exe for USPS
Write-Host "Launching USPSBuildConsole.exe for USPS build..."
$uspsConfig = "$BinPath\USPSBuildConsole.exe.config"
$uspsExe = "$BinPath\USPSBuildConsole.exe"

# Placeholder: Modify USPS config file if needed
Write-Host "🛠️ Please ensure USPS config is correctly set in: $uspsConfig"

Start-Process -FilePath $uspsExe

# Step 6: Reminder to run RegenerateGlobalPlaces.exe
Write-Host "`n📌 REMINDER: Run RegenerateGlobalPlaces.exe with the correct INI file:"
Write-Host "`n    cd $BasePath\$Quarter\"
Write-Host "    .\bin\RegenerateGlobalPlaces.exe INI=.\RefData\RegenerateGloabalPlaces.ini RefDir=.\RefData DCADIR=.\VendorPrepared\here\dcas ..."
Write-Host "    ➤ Output goes to: $BasePath\$Quarter\logs\RegenerateGloabalPlaces.log"

# Step 7: Reminder to continue GUI-based steps
Write-Host "`n📌 Final USPS and Navteq build steps must be completed via USPSBuildConsole.exe UI."
Write-Host "  - Enable and run: Load Zip4 File, Import Zip4 Centroids, Import Navteq Streets, etc."
Write-Host "  - Monitor output and logs for completion."

Stop-Transcript
