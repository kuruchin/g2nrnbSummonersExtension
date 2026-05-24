# Deploy patched scripts (CP1251) to Gothic II Autorun; sources keep SE_* markers.
$ErrorActionPreference = "Stop"
& (Join-Path $PSScriptRoot "deploy.ps1")
