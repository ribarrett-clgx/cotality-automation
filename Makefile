# ============================
# PxPoint Build Automation Makefile
# ============================

SHELL := pwsh

.PHONY: help setup healthcheck build cleanup logs

# Default target
help:
	@echo ""
	@echo "PxPoint Build Automation Commands:"
	@echo ""
	@echo "  make help           Show this help menu"
	@echo "  make setup          Run environment setup validation"
	@echo "  make healthcheck    Run weekly health check script"
	@echo "  make build          Run quarterly build orchestrator"
	@echo "  make cleanup        Cleanup logs older than retention policy"
	@echo "  make logs           List recent build logs"
	@echo ""

# Run setup validation
setup:
	pwsh -Command "./setup.ps1"

# Run health check
healthcheck:
	pwsh -Command "./healthcheck.ps1"

# Run orchestrator build
build:
	pwsh -Command "./run_all_builds.ps1"

# Cleanup logs
cleanup:
	pwsh -Command "./cleanup_logs.ps1"

# Show last 5 logs (example utility)
logs:
	@echo "Recent build logs:"
	@pwsh -Command "Get-ChildItem -Path D:\PxPointDataBuild -Filter *.log | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | ForEach-Object { Write-Output ($_.LastWriteTime.ToString() + ' ' + $_.Name) }"
