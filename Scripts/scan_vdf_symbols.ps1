param(
  [string]$VdfPath = 'D:\Games\Steam\steamapps\common\Gothic II_8_0\Data\AB_Scripts.vdf',
  [string]$Filter = 'JINAWOLF'
)

$bytes = [IO.File]::ReadAllBytes($VdfPath)
$text = [Text.Encoding]::GetEncoding(28591).GetString($bytes)
$re = [regex]'[A-Za-z][A-Za-z0-9_]{2,}'
$names = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($m in $re.Matches($text)) {
  [void]$names.Add($m.Value)
}
$names | Where-Object { $_ -match $Filter } | Sort-Object
