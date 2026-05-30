# Stage .d (CP1251) + prepare Autorun folder for VDF build (does not modify Scripts sources)
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$scripts = Join-Path $root "Scripts"
$autorun = Join-Path $PSScriptRoot "System\Autorun"
$enc1251 = [Text.Encoding]::GetEncoding(1251)
$utf8 = New-Object System.Text.UTF8Encoding $false

if (-not (Test-Path $autorun)) {
    New-Item -ItemType Directory -Path $autorun -Force | Out-Null
}

$mainSrc = Join-Path $scripts "SummonersExtention.d"
$mainDst = Join-Path $autorun "SummonersExtention.d"
& (Join-Path $scripts "fix_strings.ps1") -SourcePath $mainSrc -DestPath $mainDst
$content = [IO.File]::ReadAllText($mainDst, $utf8)
[IO.File]::WriteAllText($mainDst, $content, $enc1251)
Write-Host "Staged: SummonersExtention.d"

$diaSrc = Join-Path $scripts "SummonersExtention_DIA.d"
$diaDst = Join-Path $autorun "SummonersExtention_DIA.d"
& (Join-Path $scripts "fix_dia_strings.ps1") -SourcePath $diaSrc -DestPath $diaDst
$content = [IO.File]::ReadAllText($diaDst, $utf8)
[IO.File]::WriteAllText($diaDst, $content, $enc1251)
Write-Host "Staged: SummersExtention_DIA.d"

Get-ChildItem $scripts -Filter "SummonersExtention*.d" | Where-Object {
    $_.Name -notin @("SummonersExtention.d", "SummonersExtention_DIA.d")
} | ForEach-Object {
    $src = $_.FullName
    $dest = Join-Path $autorun $_.Name
    if ($_.Name -eq "SummonersExtention_WolfPack.d") {
        & (Join-Path $scripts "fix_wolf_pack_strings.ps1") -SourcePath $src -DestPath $dest
        $content = [IO.File]::ReadAllText($dest, $utf8)
    }
    else {
        $content = [IO.File]::ReadAllText($src, $utf8)
    }
    if ($content -match '[\?]{4,}') {
        Write-Error "$($_.Name): broken Cyrillic before VDF staging"
    }
    [IO.File]::WriteAllText($dest, $content, $enc1251)
    Write-Host "Staged: $($_.Name)"
}
