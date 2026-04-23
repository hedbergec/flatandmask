@echo off
REM Launcher for flatandmask GUI wrapper — double-click to run the GUI
set SCRIPT_DIR=%~dp0
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%flatandmask_gui.ps1"
exit /b 0
