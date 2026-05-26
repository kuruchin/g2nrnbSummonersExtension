param(
  [string]$VdfPath = 'D:\Games\Steam\steamapps\common\Gothic II_8_0\Data\AB_Scripts.vdf',
  [string]$Anchor = 'JINAWOLFEXPLVL_NEXT',
  [int]$Window = 32000,
  [string[]]$Needles = @('CALC', 'EXPLVL', 'LEVEL', 'PERC', 'PERCENT', 'BAR_', 'JINAWOLF', 'CRAIT', 'SKELETONUNIQ', 'UPDATE', 'LVL')
)

$enc = [Text.Encoding]::GetEncoding(1251)
$text = $enc.GetString([IO.File]::ReadAllBytes($VdfPath))
$re = [regex]'[A-Za-z][A-Za-z0-9_]{2,}'
$idx = 0
$hit = 0
while (($pos = $text.IndexOf($Anchor, $idx)) -ge 0 -and $hit -lt 30) {
  $start = [Math]::Max(0, $pos - $Window)
  $len = [Math]::Min($Window * 2, $text.Length - $start)
  $chunk = $text.Substring($start, $len)
  $names = New-Object 'System.Collections.Generic.HashSet[string]'
  foreach ($m in $re.Matches($chunk)) { [void]$names.Add($m.Value) }
  $interesting = $names | Where-Object {
    $n = $_
    ($Needles | Where-Object { $n -like "*$_*" }).Count -gt 0
  } | Sort-Object
  Write-Output "=== chunk around $Anchor @ $pos (hit $hit) ==="
  $interesting
  $idx = $pos + $Anchor.Length
  $hit++
}
