$vdf = "d:\Games\Steam\steamapps\common\Gothic II\Data\AB_Scripts.vdf"
$bytes = [IO.File]::ReadAllBytes($vdf)
$sb = New-Object System.Text.StringBuilder
$strings = @()
foreach ($b in $bytes) {
    if ($b -ge 32 -and $b -le 126) { [void]$sb.Append([char]$b) }
    else {
        if ($sb.Length -ge 6) { $strings += $sb.ToString() }
        $sb.Clear() | Out-Null
    }
}
$strings | Where-Object { $_ -match 'TALIASAN' } | Sort-Object -Unique
