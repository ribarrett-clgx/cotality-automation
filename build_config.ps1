@{
    # Define builds and whether they run in parallel
    builds = @(
        @{ script = ".\\build\\quarterly_pxpoint_build_logged.ps1"; parallel = $false },
        @{ script = ".\\build\\diablo_dataset_build.ps1"; parallel = $true },
        @{ script = ".\\build\\usps_navteq_dataset_build.ps1"; parallel = $true },
        @{ script = ".\\build\\parcel_dataset_build.ps1"; parallel = $false },
        @{ script = ".\\build\\typeahead_dataset_build.ps1"; parallel = $true },
        @{ script = ".\\build\\lumen_dataset_build.ps1"; parallel = $false },
        @{ script = ".\\build\\internal_layers_build.ps1"; parallel = $true }
    )
}
