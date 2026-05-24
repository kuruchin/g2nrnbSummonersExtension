$vdf = "d:\Games\Steam\steamapps\common\Gothic II\Data\AB_Scripts.vdf"
$text = [Text.Encoding]::GetEncoding(1251).GetString([IO.File]::ReadAllBytes($vdf))
foreach ($sym in @(
    'DIA_FORM_GALLAHAD_SCROLLS',
    'PC_PSIONICQUEST_TEMPLATEDIALOG_212',
    'DIA_TALIASAN_HI',
    'DIA_TALIASAN_CIRCLE',
    'DIA_TALIASAN_RUNEN'
)) {
    Write-Output "$sym : $($text.IndexOf($sym))"
}
# strings near RX_FORM - look for Info_AddChoice first arg
$bytes = [IO.File]::ReadAllBytes($vdf)
$idx = $text.IndexOf('RX_FORM_GALLAHADPOTIONSSELECT')
$cur = ''
$out = @()
for ($i = $idx; $i -lt [Math]::Min($bytes.Length, $idx + 40000); $i++) {
    $b = $bytes[$i]
    if ($b -ge 32 -and $b -le 126) { $cur += [char]$b }
    else { if ($cur.Length -ge 3) { $out += $cur }; $cur = '' }
}
$out | Where-Object { $_ -match 'Info_|AddChoice|ClearChoices|TEMPLATE|SCROLLS|212' } | Select-Object -First 25
