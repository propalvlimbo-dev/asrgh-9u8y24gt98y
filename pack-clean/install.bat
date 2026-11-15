@echo off
chcp 65001 >nul
setlocal
title PvP Clean 1.21.11 - installer
echo.
echo  ============================================================
echo   PvP Clean 1.21.11 - ustanovshchik sborki
echo   (hitcolor + malenkiy shchit + bez tryaski + optimizatsiya)
echo  ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
set EXITCODE=%ERRORLEVEL%
echo.
if "%EXITCODE%"=="0" (
  echo  Gotovo. Otkroy Prism Launcher.
) else (
  echo  Est oshibki - sm. soobshcheniya vyshe.
)
echo.
pause
exit /b %EXITCODE%
