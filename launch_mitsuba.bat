@echo off
REM ================================================================
REM Mitsuba Launcher for Manifold Path Guiding
REM ================================================================
REM This script sets up the Mitsuba environment and renders scenes
REM
REM Usage:
REM   launch_mitsuba.bat                  - Show help
REM   launch_mitsuba.bat scene.xml        - Render a scene
REM   launch_mitsuba.bat --gui            - Launch Mitsuba GUI
REM ================================================================

setlocal enabledelayedexpansion

REM Detect build directory
set SCRIPT_DIR=%~dp0
set MITSUBA_SRC=%SCRIPT_DIR%mitsuba

REM Check for different possible build locations
if exist "%MITSUBA_SRC%\cmake-build-release-visual-studio\dist\mitsuba.exe" (
    set MITSUBA_BUILD=%MITSUBA_SRC%\cmake-build-release-visual-studio
) else if exist "%MITSUBA_SRC%\build\dist\mitsuba.exe" (
    set MITSUBA_BUILD=%MITSUBA_SRC%\build
) else if exist "%MITSUBA_SRC%\dist\mitsuba.exe" (
    set MITSUBA_BUILD=%MITSUBA_SRC%
) else (
    echo ERROR: Could not find Mitsuba executable!
    echo.
    echo Please ensure Mitsuba is built and the executable exists in one of:
    echo   - %MITSUBA_SRC%\cmake-build-release-visual-studio\dist\mitsuba.exe
    echo   - %MITSUBA_SRC%\build\dist\mitsuba.exe
    echo   - %MITSUBA_SRC%\dist\mitsuba.exe
    echo.
    pause
    exit /b 1
)

set MITSUBA_DIST=%MITSUBA_BUILD%\dist

REM Set up environment
set PATH=%MITSUBA_DIST%;%PATH%
set PYTHONPATH=%MITSUBA_DIST%\python;%PYTHONPATH%

echo ================================================================
echo Mitsuba Manifold Path Guiding - Launcher
echo ================================================================
echo Build directory: %MITSUBA_BUILD%
echo Executable:      %MITSUBA_DIST%\mitsuba.exe
echo ================================================================
echo.

REM Check what command to run
if "%1"=="" goto :show_help
if "%1"=="--help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="--gui" goto :launch_gui
if "%1"=="--version" goto :show_version
if "%1"=="--test" goto :test_install

REM Default: render the provided scene
echo Rendering: %1
echo.
"%MITSUBA_DIST%\mitsuba.exe" %*
goto :end

:show_help
echo Usage:
echo   launch_mitsuba.bat [options] [scene.xml]
echo.
echo Options:
echo   --help              Show this help message
echo   --gui               Launch Mitsuba GUI (if available)
echo   --version           Show Mitsuba version
echo   --test              Test Mitsuba installation
echo.
echo Examples:
echo   launch_mitsuba.bat scene.xml                     Render a scene
echo   launch_mitsuba.bat -o output.exr scene.xml       Render with custom output
echo   launch_mitsuba.bat --test                        Test installation
echo.
echo For Blender integration, see BLENDER_SETUP_GUIDE.md
echo.
goto :end

:launch_gui
echo Launching Mitsuba GUI...
if exist "%MITSUBA_DIST%\mitsuba-gui.exe" (
    start "" "%MITSUBA_DIST%\mitsuba-gui.exe"
) else (
    echo ERROR: mitsuba-gui.exe not found!
    echo The GUI may not be built in this version.
)
goto :end

:show_version
"%MITSUBA_DIST%\mitsuba.exe" --version
goto :end

:test_install
echo Testing Mitsuba installation...
echo.
echo 1. Checking executable...
if exist "%MITSUBA_DIST%\mitsuba.exe" (
    echo    [OK] mitsuba.exe found
) else (
    echo    [ERROR] mitsuba.exe not found!
)
echo.

echo 2. Checking Python bindings...
if exist "%MITSUBA_DIST%\python" (
    echo    [OK] Python bindings directory found
) else (
    echo    [WARNING] Python bindings directory not found
)
echo.

echo 3. Running Mitsuba version check...
"%MITSUBA_DIST%\mitsuba.exe" --version
echo.

echo 4. Checking for MPG integrator source...
if exist "%MITSUBA_SRC%\src\integrators\MPG" (
    echo    [OK] Manifold Path Guiding integrator source found
) else (
    echo    [WARNING] MPG integrator source not found
)
echo.

echo Test complete! If all checks passed, Mitsuba is ready to use.
echo.
echo Next steps:
echo   - See BLENDER_SETUP_GUIDE.md to integrate with Blender
echo   - Check the 'scenes' folder for example scenes
echo   - Run experiments in the 'experiments' folder
echo.
goto :end

:end
pause
endlocal
