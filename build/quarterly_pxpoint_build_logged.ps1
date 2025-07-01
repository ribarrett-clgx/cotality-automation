# ==============================
# PxPoint Quarterly Build Script with Logging and Error Handling
# Target: Windows Server 2022 + Visual Studio 2022
# ==============================

$LogFile = "D:\PxPointDataBuild\pxpoint_build_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Start-Transcript -Path $LogFile -Append

function Log-Step {
    param([string]$message)
    Write-Host "`n=== $message ==="
    Write-Output "=== $message ==="
}

function Run-Command {
    param([string]$description, [scriptblock]$command)
    try {
        Log-Step $description
        & $command
    } catch {
        Write-Host "ERROR: $description failed." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

function Get-CurrentQuarter {
    $now = Get-Date
    $year = $now.Year
    $month = $now.Month
    $quarter = [math]::Ceiling($month / 3)
    return "$($year)q$quarter"
}

function Get-PreviousQuarter {
    $now = Get-Date
    $month = $now.Month
    $year = $now.Year
    $quarter = [math]::Ceiling($month / 3)
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
$ToolPath = "D:\Tools\43MillionComparisonTest.exe"
$LicensePath = "D:\TestSolution\License\corelogicall.lic"
$DatasetList = @("usps_us", "navteq_us", "parcel_us", "all_us", "structure_us")
$RepoPath = "D:\Users\<username>\git\spatial_us-pxpoint-core"
$VSBuildPath = "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
$BuildOutputPath = "$BasePath\$Quarter\bin"

# Step 1: Generate Baselines
foreach ($dataset in $DatasetList) {
    Run-Command "Generating baseline for $dataset" {
        & $ToolPath --cmd gdxgeocode `
            --baseline "$BasePath\$PreviousQuarter\release\$dataset.gdx" `
            --function geocode `
            --datasource 4m `
            --lic $LicensePath
    }
}

# Step 2: Archive and Delete Old Data
$gsutil = "C:\gsutil\gsutil.cmd"
Run-Command "Archiving VendorPrepared data" {
    & $gsutil -m rsync -rp "$BasePath\$PreviousQuarter\VendorPrepared" "gs://spatial-pxpoint-vendor-curated/$PreviousQuarter/"
}
Run-Command "Archiving dataset" {
    & $gsutil -m rsync -rp "$BasePath\$PreviousQuarter\dataset" "gs://spatial-pxpoint-release-candidates/$PreviousQuarter/"
}
Run-Command "Deleting old quarter data" {
    Remove-Item -Recurse -Force "$BasePath\$PreviousQuarter"
}

# Step 3: Manual DB Steps
Log-Step "Step 3: Manual DB backup and recreation required on SQL Server VM"

# Step 4: Build GUI Tools
Run-Command "Building solution with MSBuild" {
    & "$VSBuildPath" "$RepoPath\pxpoint.sln" /p:Configuration=Release /p:Platform=x64 /m
}

Run-Command "Copying Release binaries" {
    New-Item -ItemType Directory -Force -Path $BuildOutputPath
    Copy-Item "$RepoPath\bin\Release-x64\pxpoint\*" "$BuildOutputPath" -Recurse -Force
}

Log-Step "Build process complete. Check logs and verify DB/manual steps."

Stop-Transcript
