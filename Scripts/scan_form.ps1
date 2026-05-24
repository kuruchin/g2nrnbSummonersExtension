$vdf = "d:\Games\Steam\steamapps\common\Gothic II\Data\AB_Scripts.vdf"
$bytes = [IO.File]::ReadAllBytes($vdf)
$idx = [Text.Encoding]::GetEncoding(1251).GetString($bytes).IndexOf('RX_FORM_GALLAHADPOTIONSSELECT')
$cur = ''
$out = @()
for ($i = $idx; $i -lt [Math]::Min($bytes.Length, $idx + 8000); $i++) {
    $b = $bytes[$i]
    if ($b -ge 32 -and $b -le 126) { $cur += [char]$b }
    else { if ($cur.Length -ge 3) { $out += $cur }; $cur = '' }
}
$out | Select-Object -First 80

$idx2 = [Text.Encoding]::GetEncoding(1251).GetString($bytes).IndexOf('DIA_TALIASAN_HI_INFO')
$cur = ''
$out2 = @()
for ($i = $idx2; $i -lt [Math]::Min($bytes.Length, $idx2 + 8000); $i++) {
    $b = $bytes[$i]
    if ($b -ge 32 -and $b -le 126) { $cur += [char]$b }
    else { if ($cur.Length -ge 3) { $out2 += $cur }; $cur = '' }
}
Write-Output '--- HI_INFO ---'
$out2 | Select-Object -First 40
