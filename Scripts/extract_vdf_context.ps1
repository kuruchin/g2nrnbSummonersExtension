param(
  [string]$VdfPath = 'D:\Games\Steam\steamapps\common\Gothic II_8_0\Data\AB_Scripts.vdf',
  [string]$Needle = 'RX_CHANGENPCBAR',
  [int]$MaxHits = 5,
  [int]$Before = 300,
  [int]$After = 500
)

$enc = [Text.Encoding]::GetEncoding(1251)
$text = $enc.GetString([IO.File]::ReadAllBytes($VdfPath))
$idx = 0
$n = 0
while (($pos = $text.IndexOf($Needle, $idx)) -ge 0 -and $n -lt $MaxHits) {
  $start = [Math]::Max(0, $pos - $Before)
  $len = [Math]::Min($Before + $After + $Needle.Length, $text.Length - $start)
  $frag = $text.Substring($start, $len) -replace '[\x00-\x1f]', '.'
  Write-Output "=== $Needle #$n @ $pos ==="
  Write-Output $frag
  $idx = $pos + $Needle.Length
  $n++
}
