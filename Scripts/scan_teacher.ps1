$vdf = "d:\Games\Steam\steamapps\common\Gothic II\Data\AB_Scripts.vdf"
$text = [Text.Encoding]::GetEncoding(1251).GetString([IO.File]::ReadAllBytes($vdf))
$idx = $text.IndexOf('TALIASANTEACHMAGIC')
Write-Output "TALIASANTEACHMAGIC at $idx"
$bytes = [IO.File]::ReadAllBytes($vdf)
$cur = ''
$out = @()
for ($i = [Math]::Max(0, $idx - 5000); $i -lt [Math]::Min($bytes.Length, $idx + 20000); $i++) {
    $b = $bytes[$i]
    if ($b -ge 32 -and $b -le 126) { $cur += [char]$b }
    else { if ($cur.Length -ge 3) { $out += $cur }; $cur = '' }
}
$out | Where-Object { $_ -match 'DIA_TALIASAN|RX_FORM|Info_|GALLAHAD|TEACH|CIRCLE|HI' } | Select-Object -First 60
# search DIA that links to CIRCLE
[regex]::Matches($text, 'DIA_TALIASAN_[A-Z0-9_]+') | ForEach-Object Value | Where-Object { $_ -match 'TEACH|GALLAHAD|MAGIC|MAIN|HELLO|HI[^_]|START' } | Sort-Object -Unique
