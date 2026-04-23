@echo off
title JSON Schema Tree Viewer (GUI)

REM -----------------------------------------
REM Run PowerShell GUI script
REM -----------------------------------------

set SCRIPT_DIR=%~dp0
set PS_SCRIPT=%SCRIPT_DIR%JsonSchemaTree.ps1

if not exist "%PS_SCRIPT%" (
    echo ERROR: Cannot find JsonSchemaTree.ps1 in:
    echo %SCRIPT_DIR%
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -STA -File "%PS_SCRIPT%"

echo.
echo -----------------------------------------
echo Done. If a file was selected, tree.txt
echo was written next to the JSON file.
echo -----------------------------------------
pause