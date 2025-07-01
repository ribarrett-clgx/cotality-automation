# ========================================
# Lumen Dataset Build - Quarterly Pipeline
# With Per-step Error Handling
# ========================================

Start-Transcript -Path "D:\PxPointDataBuild\lumen_build_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Exit-OnError {
    param([string]$step)
    if (!$?) {
        Write-Host "❌ FAILED at step: $step"
        Stop-Transcript
        exit 1
    }
}

$Quarter = Get-Date -Format "yyyyQq"
$RepoPath = "D:\Users\<username>\git\spatial_us-pxpoint-core"
$BuildPath = "$RepoPath\release"
$DockerTar = "corelogic-customds-9.11.tar"
$PXPOINT_DIR = "/usr/local/pxpoint/"
$WORKING = "/usr/local/build"

Write-Host "🚀 Building Lumen dataset for $Quarter"

# Clone repo if not present
if (!(Test-Path $RepoPath)) {
    git clone https://github.com/corelogic-private/spatial_us-pxpoint-core $RepoPath
}
Exit-OnError "Clone repo"

# Build native tools
cd $BuildPath
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --target LicensePatcher CustomDataset StreetIndexer --parallel
Exit-OnError "Build native tools"

# Navigate to Lumen client directory and build docker tar
cd "$RepoPath\clients\Lumen"
make tar
Exit-OnError "Make Lumen docker tar"

# Load Docker image
docker load -i $DockerTar
Exit-OnError "Load docker image"

# Run dataset build container
docker run --rm --user $(id -u):$(id -g) --name lumen-ds-builder `
  --mount dst=/usr/local/pxpoint,src=$PXPOINT_DIR,type=bind `
  --mount dst=/usr/local/build,src=$WORKING,type=bind `
  corelogic/customds `
  -i /usr/local/build/input -o /usr/local/build/output -p /usr/local/pxpoint -d LumenDS_$Quarter
Exit-OnError "Run lumen-ds-builder container"

Write-Host "📁 Uploading outputs to NFS share"
# Copy outputs to NFS
Copy-Item -Recurse "/usr/local/build/output" "P:\$Quarter\client\lumen-custom-dataset-builder\"
Exit-OnError "Copy outputs to NFS"

Stop-Transcript
