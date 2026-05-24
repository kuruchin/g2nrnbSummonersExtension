# Enable zParser OU compile so AI_Output works for injected C_INFO lines.
param(
    [string]$SystemPackIni = "d:\Games\Steam\steamapps\common\Gothic II\system\SystemPack.ini"
)

$ErrorActionPreference = "Stop"
if (-not (Test-Path $SystemPackIni)) {
    Write-Warning "SystemPack.ini not found: $SystemPackIni"
    return
}

$text = [IO.File]::ReadAllText($SystemPackIni)
if ($text -notmatch '\[ZPARSE_EXTENDER\]') {
    Write-Warning "No [ZPARSE_EXTENDER] section in SystemPack.ini"
    return
}

$newText = $text -replace '(?m)^CompileOU\s*=\s*false\s*$', 'CompileOU = true'
if ($newText -eq $text) {
    if ($text -match 'CompileOU\s*=\s*true') {
        Write-Host "CompileOU already true"
    } else {
        Write-Warning "CompileOU line not found"
    }
    return
}

[IO.File]::WriteAllText($SystemPackIni, $newText)
Write-Host "Patched CompileOU = true in $SystemPackIni"
