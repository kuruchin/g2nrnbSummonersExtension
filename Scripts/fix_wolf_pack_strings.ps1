# Cyrillic for SummonersExtention_WolfPack.d (item tooltip suffix)
param(
    [string]$SourcePath = "",
    [string]$DestPath = ""
)

$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding $false
if (-not $SourcePath) {
    $SourcePath = Join-Path $PSScriptRoot "SummonersExtention_WolfPack.d"
}
$inPlace = (-not $DestPath)
if (-not $DestPath) {
    $DestPath = $SourcePath
}

function U([string]$s) {
    return [System.Text.RegularExpressions.Regex]::Unescape($s)
}

$upgradeSuffix = U " (\u0423\u043b\u0443\u0447\u0448\u0435\u043d\u0430)"
$sumWolfName = U "\u041f\u0440\u0438\u0437\u044b\u0432 \u0432\u0430\u0440\u0433\u0430"

$text = [IO.File]::ReadAllText($SourcePath, $utf8)
$text = $text.Replace('"SE_WOLF_PACK_UPGRADE_SUFFIX"', "`"$upgradeSuffix`"")
$text = $text.Replace('"SE_SUMWOLF_ITEM_NAME"', "`"$sumWolfName`"")
$text = $text.Replace('"SE_SUMWOLF_SPELL_NAME"', "`"$sumWolfName`"")

if ($inPlace -and ($text -match 'SE_WOLF_PACK_UPGRADE_SUFFIX|SE_SUMWOLF_ITEM_NAME|SE_SUMWOLF_SPELL_NAME')) {
    Write-Error "Failed to patch WolfPack message markers"
}

if ($text -match '[\?]{4,}') {
    Write-Error "Broken Cyrillic in output: $DestPath"
}

[IO.File]::WriteAllText($DestPath, $text, $utf8)
Write-Host "Patched: $DestPath"
