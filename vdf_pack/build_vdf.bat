@echo off
setlocal
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0stage_autorun.ps1"
if errorlevel 1 exit /b 1

set "DLL=..\SummonersExtention\Bin\SummonersExtention.dll"
if not exist "%DLL%" set "DLL=..\Bin\SummonersExtention.dll"
if not exist "%DLL%" (
  echo Build G2A MD Release in Visual Studio first.
  exit /b 1
)

set "AUTORUN=System\Autorun"
set "TARGET=%AUTORUN%\NB_UNION_PLUGIN_ALLOWED_01.dll"
if not exist "%AUTORUN%" mkdir "%AUTORUN%"
copy /Y "%DLL%" "%TARGET%" >nul

set "VB=%~dp0..\tools\vdfsbuilder.exe"
if not exist "%VB%" (
  echo Download vdfsbuilder to ..\tools\vdfsbuilder.exe
  exit /b 1
)

"%VB%" build.vm
if errorlevel 1 exit /b 1

echo Built: %~dp0SummonersExtention.vdf
echo Plugin inside VDF: %TARGET%
endlocal
