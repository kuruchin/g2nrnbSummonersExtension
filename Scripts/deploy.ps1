# Deploy SummonersExtention .d scripts to Gothic II Autorun.
# Source files in this folder: UTF-8 with SE_* markers. Game Autorun: CP1251.

param(
    [string]$GameAutorun = "d:\Games\Steam\steamapps\common\Gothic II_8_0\system\Autorun"
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $scriptDir "patch_compile_ou.ps1") -ErrorAction SilentlyContinue
$enc1251 = [Text.Encoding]::GetEncoding(1251)
$utf8 = New-Object System.Text.UTF8Encoding $false

if (-not (Test-Path $GameAutorun)) {
    Write-Error "Autorun folder not found: $GameAutorun"
}

$staging = Join-Path ([IO.Path]::GetTempPath()) ("SE_deploy_" + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $staging -Force | Out-Null
try {
    $mainSrc = Join-Path $scriptDir "SummonersExtention.d"
    $mainStg = Join-Path $staging "SummonersExtention.d"
    & (Join-Path $scriptDir "fix_strings.ps1") -SourcePath $mainSrc -DestPath $mainStg

    $diaSrc = Join-Path $scriptDir "SummonersExtention_DIA.d"
    $diaStg = Join-Path $staging "SummonersExtention_DIA.d"
    & (Join-Path $scriptDir "fix_dia_strings.ps1") -SourcePath $diaSrc -DestPath $diaStg

    Get-ChildItem $staging -Filter "*.d" | ForEach-Object {
        $content = [IO.File]::ReadAllText($_.FullName, $utf8)
        $dest = Join-Path $GameAutorun $_.Name
        [IO.File]::WriteAllText($dest, $content, $enc1251)
        Write-Host "Deployed: $($_.Name) -> $dest"
    }

    Get-ChildItem $scriptDir -Filter "SummonersExtention*.d" | Where-Object {
        $_.Name -notin @("SummonersExtention.d", "SummonersExtention_DIA.d")
    } | ForEach-Object {
        $content = [IO.File]::ReadAllText($_.FullName, $utf8)
        if ($content -match '[\?]{4,}') {
            Write-Warning "$($_.Name): broken Cyrillic. Skipping."
            return
        }
        $dest = Join-Path $GameAutorun $_.Name
        [IO.File]::WriteAllText($dest, $content, $enc1251)
        Write-Host "Deployed: $($_.Name) -> $dest"
    }
}
finally {
    Remove-Item -Recurse -Force $staging -ErrorAction SilentlyContinue
}

$projectRoot = Split-Path $scriptDir -Parent
$dllCandidates = @(
    (Join-Path $projectRoot "SummonersExtention\Bin\SummonersExtention.dll"),
    (Join-Path $projectRoot "Bin\SummonersExtention.dll")
)
# DLL only in Data\SummonersExtention.vdf (NB_UNION_PLUGIN_ALLOWED_01.dll). Required for bars.
$vdfBat = Join-Path (Split-Path $scriptDir -Parent) "vdf_pack\build_vdf.bat"
if (Test-Path $vdfBat) {
    cmd /c "`"$vdfBat`""
    $vdfSrc = Join-Path (Split-Path $scriptDir -Parent) "vdf_pack\SummonersExtention.vdf"
    $gameData = Join-Path (Split-Path $GameAutorun -Parent) "..\Data"
    if ((Test-Path $vdfSrc) -and (Test-Path $gameData)) {
        Copy-Item $vdfSrc (Join-Path $gameData "SummonersExtention.vdf") -Force
        Write-Host "VDF -> $(Join-Path $gameData 'SummonersExtention.vdf')"
    }
}

Write-Host "Done."
