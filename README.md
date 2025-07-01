# cotality-automation
Cotality Automation

## PxPoint Quarterly Build Automation

## 📌 Summary
This project automates **quarterly PxPoint dataset builds**, including Parcel, ParcelPlus, Diablo, USPS, Navteq, Typeahead, Lumen, and Internal Layers datasets. It ensures consistent, reliable, and scheduled execution of all build processes.

---

## 📝 Overview
The build orchestration includes:
- **Root orchestrator:** `run_all_builds.ps1`
- **Config file:** `build_config.ps1` defining builds and parallelism
- **Individual build scripts:** located in the `build/` directory
- **Logging:** Each script generates timestamped logs
- **Quarter detection:** Scripts dynamically detect the current and previous quarter
- **Error aggregation:** Reports all failed builds at the end
- **Optional parallelism:** Runs independent builds simultaneously to reduce runtime

### 📂 Directory Structure
```
cotality-automation/
├── run_all_builds.ps1
├── build_config.ps1
├── setup.ps1
├── healthcheck.ps1
├── cleanup_logs.ps1
├── build/
│   ├── quarterly_pxpoint_build_logged.ps1
│   ├── diablo_dataset_build.ps1
│   ├── usps_navteq_dataset_build.ps1
│   ├── parcel_dataset_build.ps1
│   ├── typeahead_dataset_build.ps1
│   ├── lumen_dataset_build.ps1
│   └── internal_layers_build.ps1
└── tasks/
    ├── PxPointQuarterlyBuilds.xml
    ├── PxPointHealthCheck.xml
    └── PxPointCleanupLogs.xml
```

---

## ⚙️ **Config File: `build_config.ps1`**

### Example
```powershell
@{
    builds = @(
        @{ script = ".\build\quarterly_pxpoint_build_logged.ps1"; parallel = $false },
        @{ script = ".\build\diablo_dataset_build.ps1"; parallel = $true },
        @{ script = ".\build\usps_navteq_dataset_build.ps1"; parallel = $true },
        @{ script = ".\build\parcel_dataset_build.ps1"; parallel = $false },
        @{ script = ".\build\typeahead_dataset_build.ps1"; parallel = $true },
        @{ script = ".\build\lumen_dataset_build.ps1"; parallel = $false },
        @{ script = ".\build\internal_layers_build.ps1"; parallel = $true }
    )
}
```

✅ **Key**
- `script`: path to build script  
- `parallel`: `$true` or `$false` to run in parallel or sequentially

---

## ⚠️ Dependencies

✅ **Pre-requisites:**
- PxPoint build system binaries installed on Windows 2022 build machine
- Visual Studio 2022 build tools configured
- Licensed PxPoint datasets and tools in `D:\PxPointDataBuild`
- Required tools:
  - `43MillionComparisonTest.exe`
  - `DAProcess.exe`
  - `BuildTypeaheadDataset.exe`
  - Docker (for Lumen dataset)
  - 7-Zip
  - gsutil (for GCS uploads)

⚠️ **Note:** Scripts **do not install binaries or build dependencies themselves**.

---

## 🚀 Usage

### ✅ **Run via Windows Task Scheduler**
1. Import `PxPointQuarterlyBuilds.xml` in **Task Scheduler > Import Task**.
2. Adjust user account, permissions, and `<Arguments>` path to your deployment.
3. Task runs quarterly (Jan, Apr, Jul, Oct) at **2:00 AM** by default.

### ✅ **Run via Jenkins**
1. Copy `Jenkinsfile` into your repository.
2. Adjust `BUILD_DIR` to point to your deployment folder.
3. Create Jenkins pipeline pointing to this repository.
4. Trigger manually or set up a cron schedule for quarterly runs.

### ✅ **Run manually**
1. Open an **elevated PowerShell terminal**.
2. Navigate to your scripts directory.
3. Execute:

```powershell
.\run_all_builds.ps1
```

---

## 🛠 **Error Aggregation and Reporting**

- Scripts continue running all builds even if some fail.
- At the end, failures are summarized in a clear **❌ BUILD FAILURES SUMMARY**.
- Exit code is non-zero if any build fails.

---

## ⚡ **Optional Parallelism**

- Independent builds can run in parallel, reducing total build time.
- Controlled via `build_config.ps1` by setting `parallel = $true`.

---

## 🛠 **Maintainers Notes**
- Ensure dataset folders are backed up before running.
- Review and clean logs periodically to avoid storage bloat.
- Update environment-specific paths if deploying on new build machines.

---

## 📧 Support
For issues, contact the **PxPoint Data Engineering team** or open a ticket in Jira under **PxPoint Build Automation**.