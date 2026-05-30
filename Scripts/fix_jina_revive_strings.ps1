# Cyrillic PrintScreen for SummonersExtention_JinaRevive.d
param(
    [string]$SourcePath,
    [string]$DestPath
)

$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding $false

function U([string]$s) {
    return [System.Text.RegularExpressions.Regex]::Unescape($s)
}

$uiAlive = U "\u0414\u0436\u0438\u043d\u0430: \u0441 \u0432\u0430\u043c\u0438"
$uiNeedSummon = U "\u0410\u0432\u0442\u043e\u043f\u0440\u0438\u0437\u044b\u0432: \u0441\u043d\u0430\u0447\u0430\u043b\u0430 \u043f\u0440\u0438\u0437\u043e\u0432\u0438\u0442\u0435 \u0414\u0436\u0438\u043d\u0443"
$uiReady = U "\u0410\u0432\u0442\u043e\u043f\u0440\u0438\u0437\u044b\u0432: \u0413\u041e\u0422\u041e\u0412\u041e"
$uiNoMana = U "\u0410\u0432\u0442\u043e\u043f\u0440\u0438\u0437\u044b\u0432: \u043d\u0435\u0442 \u043c\u0430\u043d\u044b"
$uiNoRune = U "\u0410\u0432\u0442\u043e\u043f\u0440\u0438\u0437\u044b\u0432: \u043d\u0435\u0442 \u0440\u0443\u043d\u044b"

$text = [IO.File]::ReadAllText($SourcePath, $utf8)
$text = $text.Replace('"SE_UI_JINA_ALIVE"', "`"$uiAlive`"")
$text = $text.Replace('"SE_UI_JINA_NEED_SUMMON"', "`"$uiNeedSummon`"")
$text = $text.Replace('"SE_UI_JINA_READY"', "`"$uiReady`"")
$text = $text.Replace('"SE_UI_JINA_NO_MANA"', "`"$uiNoMana`"")
$text = $text.Replace('"SE_UI_JINA_NO_RUNE"', "`"$uiNoRune`"")

if ($text -match 'SE_UI_JINA_') {
    Write-Error "Failed to patch JinaRevive UI in $SourcePath"
}

[IO.File]::WriteAllText($DestPath, $text, $utf8)
Write-Host "Patched JinaRevive UI: $DestPath"
