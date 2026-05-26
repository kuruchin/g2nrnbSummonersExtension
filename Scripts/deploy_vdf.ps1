# Build SummonersExtention.vdf and copy to Gothic II_8_0\Data
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$gameData = "d:\Games\Steam\steamapps\common\Gothic II_8_0\Data"
$bat = Join-Path $root "vdf_pack\build_vdf.bat"

if (-not (Test-Path $bat)) {
    Write-Error "Not found: $bat"
}
cmd /c "`"$bat`""
$vdfSrc = Join-Path $root "vdf_pack\SummonersExtention.vdf"
if (-not (Test-Path $vdfSrc)) {
    Write-Error "VDF build failed: $vdfSrc"
}
if (-not (Test-Path $gameData)) {
    Write-Error "Game Data folder not found: $gameData"
}
Copy-Item $vdfSrc (Join-Path $gameData "SummonersExtention.vdf") -Force
Write-Host "VDF -> $gameData\SummonersExtention.vdf"
Get-Item (Join-Path $gameData "SummonersExtention.vdf") | Format-List Length, LastWriteTime
