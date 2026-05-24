$vdf = "d:\Games\Steam\steamapps\common\Gothic II\Data\AB_Scripts.vdf"
$text = [Text.Encoding]::GetEncoding(1251).GetString([IO.File]::ReadAllBytes($vdf))
foreach ($sym in @('DIA_FORM_GALLAHAD_SCROLLS','PC_PSIONICQUEST_TEMPLATEDIALOG_212','DIA_TALIASAN_EXPLAINCIRCLES')) {
    $i = $text.IndexOf($sym)
    Write-Output "$sym at $i"
}
$idx = $text.IndexOf('RX_FORM_GALLAHADPOTIONSSELECT')
$bytes = [IO.File]::ReadAllBytes($vdf)
$cur = ''
$out = @()
for ($i = $idx; $i -lt [Math]::Min($bytes.Length, $idx + 25000); $i++) {
    $b = $bytes[$i]
    if ($b -ge 32 -and $b -le 126) { $cur += [char]$b }
    else { if ($cur.Length -ge 3) { $out += $cur }; $cur = '' }
}
$out | Where-Object { $_ -match 'Info_|FORM_GALLAHAD|SCROLLS|TEMPLATE|AddChoice|ClearChoices' } | Select-Object -First 30
