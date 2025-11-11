@echo off
:: ==========================================
:: NuGet Backup Manager Launcher
:: Author: Mehdi Dimyadi (MEHDIMYADI)
:: ==========================================
title NuGet Backup & Restore Manager
echo Running PowerShell script...
echo.

:: Run PowerShell and keep the window open even if an error occurs
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { & '%~dp0NugetBackupManager.ps1' } catch { Write-Host '❌ Error: ' $_.Exception.Message; pause }"

echo.
pause
