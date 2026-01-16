@echo off
REM Script to update pybind11 submodule to a version with VS 2022 support
REM
REM This script updates the pybind11 submodule to version 2.11.1 (or later),
REM which includes native support for Visual Studio 2022.
REM
REM Usage: update_pybind11.bat [version]
REM   If no version is specified, defaults to v2.11.1

setlocal

set PYBIND11_VERSION=%1
if "%PYBIND11_VERSION%"=="" set PYBIND11_VERSION=v2.11.1

set SCRIPT_DIR=%~dp0
set PYBIND11_DIR=%SCRIPT_DIR%mitsuba\ext\pybind11

echo ==========================================
echo Updating pybind11 to %PYBIND11_VERSION%
echo ==========================================
echo.

REM Check if the submodule directory exists
if not exist "%PYBIND11_DIR%" (
    echo Error: pybind11 directory not found at %PYBIND11_DIR%
    echo You may need to initialize submodules first:
    echo   cd mitsuba ^&^& git submodule update --init --recursive
    exit /b 1
)

REM Navigate to pybind11 directory
cd /d "%PYBIND11_DIR%"

echo Current pybind11 location: %CD%
echo.

REM Fetch latest tags
echo Fetching latest pybind11 versions...
git fetch --all --tags
echo.

REM Check if the requested version exists
git rev-parse %PYBIND11_VERSION% >nul 2>&1
if errorlevel 1 (
    echo Warning: Version %PYBIND11_VERSION% not found!
    echo Available recent versions:
    git tag | findstr "^v2\."
    exit /b 1
)

REM Checkout the requested version
echo Checking out pybind11 %PYBIND11_VERSION%...
git checkout %PYBIND11_VERSION%
echo.

REM Show the current version
for /f "delims=" %%i in ('git rev-parse HEAD') do set CURRENT_COMMIT=%%i
echo Successfully updated to:
echo   Version: %PYBIND11_VERSION%
echo   Commit: %CURRENT_COMMIT%
echo.

REM Go back to repository root
cd /d "%SCRIPT_DIR%"

REM Check git status
echo Git status:
git status mitsuba\ext\pybind11
echo.

echo ==========================================
echo Update complete!
echo ==========================================
echo.
echo Next steps:
echo   1. Review the changes: git diff mitsuba/ext/pybind11
echo   2. Test the build with Visual Studio 2022
echo   3. Commit the change: git add mitsuba/ext/pybind11
echo      git commit -m "Update pybind11 to %PYBIND11_VERSION% for VS 2022 support"
echo.

endlocal
