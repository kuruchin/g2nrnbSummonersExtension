# Build G2A MD Release, then deploy scripts (CP1251) and VDF with fresh DLL.
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$msb = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find "MSBuild\**\Bin\MSBuild.exe" 2>$null | Select-Object -First 1
if (-not $msb) {
    $msb = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
}
if (-not (Test-Path $msb)) {
    Write-Error "MSBuild not found. Build G2A MD Release in Visual Studio first."
}
& $msb (Join-Path $root "SummonersExtention\SummonersExtention.vcxproj") /p:Configuration="G2A MD Release" /p:Platform=Win32 /v:m /nologo
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& (Join-Path $PSScriptRoot "deploy.ps1")
