$vdf = "d:\Games\Steam\steamapps\common\Gothic II\Data\AB_Scripts.vdf"
$text = [Text.Encoding]::GetEncoding(1251).GetString([IO.File]::ReadAllBytes($vdf))
foreach ($sym in @('DIA_TALIASAN_EXPLAINCIRCLES', 'EXPLAINCIRCLES', 'DIA_TALIASAN_SUMMONER', 'DIA_TALIASAN_TRADE')) {
    Write-Output "$sym at $($text.IndexOf($sym))"
}
$bytes = [IO.File]::ReadAllBytes($vdf)
$idx = $text.IndexOf('DIA_TALIASAN_EXPLAINCIRCLES_INFO')
if ($idx -lt 0) { $idx = $text.IndexOf('DIA_TALIASAN_EXPLAINCIRCLES') }
$cur = ''
$out = @()
for ($i = $idx; $i -lt [Math]::Min($bytes.Length, $idx + 20000); $i++) {
    $b = $bytes[$i]
    if ($b -ge 32 -and $b -le 126) { $cur += [char]$b }
    else { if ($cur.Length -ge 3) { $out += $cur }; $cur = '' }
}
Write-Output '--- EXPLAINCIRCLES area ---'
$out | Select-Object -First 35
# RX_FORM area - what choices lead to CIRCLE
$idx2 = $text.IndexOf('RX_FORM_GALLAHADPOTIONSSELECT')
$cur = ''
$out2 = @()
for ($i = $idx2; $i -lt [Math]::Min($bytes.Length, $idx2 + 25000); $i++) {
    $b = $bytes[$i]
    if ($b -ge 32 -and $b -le 126) { $cur += [char]$b }
    else { if ($cur.Length -ge 3) { $out2 += $cur }; $cur = '' }
}
Write-Output '--- RX_FORM choices ---'
$out2 | Where-Object { $_ -match 'DIA_TALIASAN|EXPLAIN|CIRCLE|RUNEN|TRADE|TEACH|212' } | Select-Object -First 30
