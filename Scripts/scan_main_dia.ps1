$vdf = "d:\Games\Steam\steamapps\common\Gothic II\Data\AB_Scripts.vdf"
$text = [Text.Encoding]::GetEncoding(1251).GetString([IO.File]::ReadAllBytes($vdf))
# search cyrillic fragments for magic essence menu
$patterns = @('postig', 'POSTIG', 'sut mag', 'SUT MAG', 'TALIASAN_HI', 'TALIASAN_CIRCLE')
foreach ($p in $patterns) {
    $c = ([regex]::Matches($text, $p, 'IgnoreCase')).Count
    Write-Output "$p : $c"
}
# all DIA_TALIASAN at start of teacher flow
[regex]::Matches($text, 'DIA_TALIASAN_[A-Z0-9_]+') | ForEach-Object Value | Sort-Object -Unique | Select-Object -First 50
# strings near DIA_TALIASAN_HI_INFO in binary
$bytes = [IO.File]::ReadAllBytes($vdf)
$idx = $text.IndexOf('DIA_TALIASAN_HI_INFO')
$cur = ''
$out = @()
for ($i = $idx; $i -lt [Math]::Min($bytes.Length, $idx + 15000); $i++) {
    $b = $bytes[$i]
    if ($b -ge 32 -and $b -le 126) { $cur += [char]$b }
    else { if ($cur.Length -ge 3) { $out += $cur }; $cur = '' }
}
Write-Output '--- after HI_INFO ---'
$out | Select-Object -First 40
$idx2 = $text.IndexOf('DIA_TALIASAN_CIRCLE_INFO')
$cur = ''
$out2 = @()
for ($i = $idx2; $i -lt [Math]::Min($bytes.Length, $idx2 + 15000); $i++) {
    $b = $bytes[$i]
    if ($b -ge 32 -and $b -le 126) { $cur += [char]$b }
    else { if ($cur.Length -ge 3) { $out2 += $cur }; $cur = '' }
}
Write-Output '--- after CIRCLE_INFO ---'
$out2 | Select-Object -First 40
