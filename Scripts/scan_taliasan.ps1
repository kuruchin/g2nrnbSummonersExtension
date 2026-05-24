$vdf = "d:\Games\Steam\steamapps\common\Gothic II\Data\AB_Scripts.vdf"
$text = [Text.Encoding]::GetEncoding(1251).GetString([IO.File]::ReadAllBytes($vdf))
$symbols = @(
    'DIA_TALIASAN_HI_INFO',
    'DIA_TALIASAN_RUNEN_INFO',
    'DIA_TALIASAN_RUNEN_Info',
    'RX_FORM_GALLAHADPOTIONSSELECT',
    'RX_FORM_GALLAHAD_WOLVES',
    'DIA_FORM_GALLAHAD_SCROLLS'
)
foreach ($sym in $symbols) {
    Write-Output "$sym -> $($text.IndexOf($sym))"
}

$idx = $text.IndexOf('RX_FORM_GALLAHADPOTIONSSELECT')
if ($idx -ge 0) {
    $bytes = [IO.File]::ReadAllBytes($vdf)
    $cur = ''
    $out = @()
    for ($i = $idx; $i -lt [Math]::Min($bytes.Length, $idx + 60000); $i++) {
        $b = $bytes[$i]
        if ($b -ge 32 -and $b -le 126) { $cur += [char]$b }
        else { if ($cur.Length -ge 4) { $out += $cur }; $cur = '' }
    }
    $out | Where-Object { $_ -match 'Info_AddChoice|DIA_TALIASAN|GALLAHAD|RUNEN|CIRCLE|FORM|Summon' } | Select-Object -First 40
}
