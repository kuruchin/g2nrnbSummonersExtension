# Stage scripts into VDF and copy VDF to Gothic II Data.
# Source files: UTF-8. VDF staging uses CP1251 (vdf_pack\\stage_autorun.ps1).

param()

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path $scriptDir -Parent

& (Join-Path $scriptDir "patch_compile_ou.ps1") -ErrorAction SilentlyContinue
& (Join-Path $root "vdf_pack\\stage_autorun.ps1")
& (Join-Path $scriptDir "deploy_vdf.ps1")
