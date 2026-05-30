# Fix Cyrillic AI_Print strings (ASCII-only script; strings via Unicode escapes)
param(
    [string]$SourcePath = "",
    [string]$DestPath = ""
)

$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding $false
if (-not $SourcePath) {
    $SourcePath = Join-Path $PSScriptRoot "SummonersExtention.d"
}
$inPlace = (-not $DestPath)
if (-not $DestPath) {
    $DestPath = $SourcePath
}

function U([string]$s) {
    return [System.Text.RegularExpressions.Regex]::Unescape($s)
}

$msgSlot1 = U "\u0412\u044b\u0443\u0447\u0435\u043d\u043e \u0440\u0430\u0441\u0448\u0438\u0440\u0435\u043d\u0438\u0435 \u043f\u0440\u0438\u0437\u044b\u0432\u0430 I. \u041b\u0438\u043c\u0438\u0442 \u043f\u0440\u0438\u0437\u044b\u0432\u0430 \u0443\u0432\u0435\u043b\u0438\u0447\u0435\u043d."
$msgSlot2 = U "\u0412\u044b\u0443\u0447\u0435\u043d\u043e \u0440\u0430\u0441\u0448\u0438\u0440\u0435\u043d\u0438\u0435 \u043f\u0440\u0438\u0437\u044b\u0432\u0430 II. \u041b\u0438\u043c\u0438\u0442 \u043f\u0440\u0438\u0437\u044b\u0432\u0430 \u0443\u0432\u0435\u043b\u0438\u0447\u0435\u043d."
$msgJina  = U "\u041f\u0440\u0438\u0437\u044b\u0432 \u0414\u0436\u0438\u043d\u044b \u0438\u0433\u043d\u043e\u0440\u0438\u0440\u0443\u0435\u0442 \u043b\u0438\u043c\u0438\u0442 \u043f\u0440\u0438\u0437\u0432\u0430\u043d\u043d\u044b\u0445 \u0441\u0443\u0449\u0435\u0441\u0442\u0432."
$msgMana  = U "\u041c\u0430\u0433\u0438\u0447\u0435\u0441\u043a\u0430\u044f \u044d\u043d\u0435\u0440\u0433\u0438\u044f \u043f\u0440\u0438\u0437\u044b\u0432\u0430\u0442\u0435\u043b\u044f \u0443\u0432\u0435\u043b\u0438\u0447\u0435\u043d\u0430 \u043d\u0430 25."
$needLp   = U "\u041d\u0435\u0434\u043e\u0441\u0442\u0430\u0442\u043e\u0447\u043d\u043e \u043e\u0447\u043a\u043e\u0432 \u043e\u0431\u0443\u0447\u0435\u043d\u0438\u044f."
$needGold = U "\u041d\u0435\u0434\u043e\u0441\u0442\u0430\u0442\u043e\u0447\u043d\u043e \u0437\u043e\u043b\u043e\u0442\u0430."
$msgJinaRevive = U "\u0423\u043c\u0435\u043d\u0438\u0435 \u0414\u0436\u0438\u043d\u044b: \u0430\u0432\u0442\u043e\u043f\u0440\u0438\u0437\u044b\u0432 \u043f\u043e\u0441\u043b\u0435 \u0441\u043c\u0435\u0440\u0442\u0438."
$hintJinaReviveNoMana = U "\u041d\u0435\u0445\u0432\u0430\u0442\u043a\u0430 \u043c\u0430\u043d\u044b \u0434\u043b\u044f \u0430\u0432\u0442\u043e\u043f\u0440\u0438\u0437\u044b\u0432\u0430 \u0414\u0436\u0438\u043d\u044b."
$hintJinaReviveNoSlot = U "\u041d\u0435\u0442 \u0441\u0432\u043e\u0431\u043e\u0434\u043d\u043e\u0433\u043e \u0441\u043b\u043e\u0442\u0430 \u043f\u0440\u0438\u0437\u044b\u0432\u0430 \u0434\u043b\u044f \u0414\u0436\u0438\u043d\u044b."
$msgWolfPack = U "\u0421\u0442\u0430\u044f \u0432\u043e\u043b\u043a\u043e\u0432: \u043f\u043e\u043a\u0430 \u0414\u0436\u0438\u043d\u0430 \u0436\u0438\u0432\u0430, \u043f\u043e\u0441\u043b\u0435 \u043f\u0440\u0438\u0437\u044b\u0432\u0430 \u0432\u0430\u0440\u0433\u0438 \u043e\u0441\u0442\u0430\u043b\u044c\u043d\u044b\u0435 \u043f\u0440\u0438\u0437\u044b\u0432\u0430\u044e\u0442\u0441\u044f \u0446\u0435\u043f\u043e\u0447\u043a\u043e\u0439. \u0411\u0435\u0437 \u0414\u0436\u0438\u043d\u044b \u2014 \u043e\u0434\u0438\u043d \u0432\u0430\u0440\u0433, \u043a\u0430\u043a \u043e\u0431\u044b\u0447\u043d\u043e."

$text = [IO.File]::ReadAllText($SourcePath, $utf8)
$text = $text.Replace('AI_Print("SE_MSG_LEARN_SLOT1");', "AI_Print(`"$msgSlot1`");")
$text = $text.Replace('AI_Print("SE_MSG_LEARN_SLOT2");', "AI_Print(`"$msgSlot2`");")
$text = $text.Replace('AI_Print("SE_MSG_LEARN_JINA");', "AI_Print(`"$msgJina`");")
$text = $text.Replace('AI_Print("SE_MSG_LEARN_MANA");', "AI_Print(`"$msgMana`");")
$text = $text.Replace('AI_Print("SE_HINT_NEED_LP");', "AI_Print(`"$needLp`");")
$text = $text.Replace('AI_Print("SE_HINT_NEED_GOLD");', "AI_Print(`"$needGold`");")
$text = $text.Replace('AI_Print("SE_MSG_LEARN_JINA_REVIVE");', "AI_Print(`"$msgJinaRevive`");")
$text = $text.Replace('AI_Print("SE_HINT_JINA_REVIVE_NOMANA");', "AI_Print(`"$hintJinaReviveNoMana`");")
$text = $text.Replace('AI_Print("SE_HINT_JINA_REVIVE_NOSLOT");', "AI_Print(`"$hintJinaReviveNoSlot`");")
$text = $text.Replace('AI_Print("SE_MSG_LEARN_WOLF_PACK");', "AI_Print(`"$msgWolfPack`");")

if ($inPlace -and ($text -match 'SE_MSG_|SE_HINT_NEED_|SE_HINT_JINA_')) {
    Write-Error "Failed to patch SummonersExtention.d message markers"
}

if ($text -match '[\?]{4,}') {
    Write-Error "Broken Cyrillic in output: $DestPath"
}

[IO.File]::WriteAllText($DestPath, $text, $utf8)
Write-Host "Patched: $DestPath"
