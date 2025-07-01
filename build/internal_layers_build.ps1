# ============================================
# Internal Layers Build - Quarterly Pipeline
# With Per-step Error Handling
# ============================================

Start-Transcript -Path "D:\PxPointDataBuild\internal_layers_build_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Exit-OnError {
    param([string]$step)
    if (!$?) {
        Write-Host "❌ FAILED at step: $step"
        Stop-Transcript
        exit 1
    }
}

$Quarter = Get-Date -Format "yyyyQq"
$BasePath = "D:\PxPointDataBuild\$Quarter"
$BinPath = "$BasePath\bin"
$WorkingDir = "$BasePath\working\DA_Addr\DA_AddrResult"
$LayersOutput = "$BasePath\working\Layers"

Write-Host "🚀 Starting Internal Layers build for $Quarter"

# Replace CSV headers
$CSV_HEADER='CNTYCD|CENSID|YYBLTACTDT|YYBLTEFFDT|UNVBSMTCD|SQFTNMR|IMPVVALAMT|VALAMT|UNVSEWERCD|LEGALBLKID|STDSUBDCD|SUBDNAME|TRACTNBR|BSMTFINCD|BSMTFINPCT|UFC|FTFRONTNBR|FDEPTHNBR|ACRESTOTAL|LANDUSE|UBSF|BSF|NUMBER|STYLE|UNVCNSTRCD|LON|LAT|GMC|DATASET|GPMC|GPLP|GNSMC|FEATUREID|GeoNavteqStLocationPoint|FEAT_ID|SMATCHCODE|GUSPLP|GSMC|GSLP'
Get-ChildItem -Path $WorkingDir -Recurse -Filter *.csv | ForEach-Object {
    (Get-Content $_.FullName) | %{if ($_.ReadCount -eq 1) {$CSV_HEADER} else {$_}} | Set-Content $_.FullName
}
Exit-OnError "Replace CSV headers"

# Run CSVToShape
cd $BinPath
& .\CSVToShape.exe -inputDir ..\working\DA_Addr\DA_AddrResult -useGeometryColumn GeoNavteqStLocationPoint -numThreads 100 *> ..\logs\dna_CSVToShape.log
Exit-OnError "Run CSVToShape"

# Run buildrtx
& .\buildrtx.exe ..\working\DA_Addr\DA_AddrResult --nthreads=100
Exit-OnError "Run buildrtx"

# Run RegionStats
& .\RegionStats.exe -inputDir ..\working\DA_Addr\DA_AddrResult -countyLayer ..\working\parcel\shp\County_2025_04.shp -navteqStreets ..\dataset\navteq_us.gdx -numThreads 400 -outputDir ..\working\Layers *> ..\logs\RegionStats.log
Exit-OnError "Run RegionStats"

# Copy results to NFS
Write-Host "📁 Copying layers build results to NFS"
Copy-Item -Recurse $LayersOutput "P:\$Quarter\layers\CommunityYearBuilt_$(Get-Date -Format 'yyyy_MM')"
Exit-OnError "Copy CommunityYearBuilt to NFS"
Copy-Item -Recurse $LayersOutput "P:\$Quarter\layers\LocationYearBuilt_$(Get-Date -Format 'yyyy_MM')"
Exit-OnError "Copy LocationYearBuilt to NFS"

Stop-Transcript
