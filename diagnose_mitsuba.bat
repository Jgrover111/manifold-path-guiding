@echo off
REM Diagnostic script for Mitsuba DLL issues
REM This helps identify missing dependencies

echo ========================================
echo Mitsuba DLL Dependency Diagnostic
echo ========================================
echo.

set DIST_DIR=%~dp0mitsuba\cmake-build-release-visual-studio\dist

if not exist "%DIST_DIR%" (
    echo ERROR: dist directory not found at %DIST_DIR%
    pause
    exit /b 1
)

cd /d "%DIST_DIR%"

echo Current directory: %CD%
echo.

echo ========================================
echo 1. Checking DLLs in dist folder
echo ========================================
dir /b *.dll
echo.

echo ========================================
echo 2. Checking Python extension modules
echo ========================================
dir /b python\mitsuba\*.pyd 2>nul
if errorlevel 1 (
    echo ERROR: No .pyd files found in python\mitsuba\
) else (
    echo Found .pyd files above
)
echo.

echo ========================================
echo 3. Checking for common dependencies
echo ========================================

set MISSING=0

if not exist "tbb.dll" (
    echo [MISSING] tbb.dll - Intel Threading Building Blocks
    set MISSING=1
) else (
    echo [OK] tbb.dll
)

if not exist "tbbmalloc.dll" (
    echo [MISSING] tbbmalloc.dll - TBB memory allocator
    set MISSING=1
) else (
    echo [OK] tbbmalloc.dll
)

if not exist "mitsuba_core.dll" (
    echo [MISSING] mitsuba_core.dll - Mitsuba core library
    set MISSING=1
) else (
    echo [OK] mitsuba_core.dll
)

if not exist "mitsuba_render.dll" (
    echo [MISSING] mitsuba_render.dll - Mitsuba render library
    set MISSING=1
) else (
    echo [OK] mitsuba_render.dll
)

echo.

echo ========================================
echo 4. Testing Python import
echo ========================================
set PATH=%CD%;%PATH%
python -c "import sys; sys.path.insert(0, 'python'); import mitsuba; print('SUCCESS: Mitsuba imported!'); print('Version:', mitsuba.__version__)" 2>&1

echo.
echo ========================================
echo Diagnostic Complete
echo ========================================
echo.

if %MISSING%==1 (
    echo WARNING: Some DLLs are missing from the dist folder.
    echo This suggests the build didn't complete properly.
    echo.
    echo Recommendation: Clean and rebuild in Release mode.
) else (
    echo All expected DLLs found.
    echo If import still fails, there may be hidden dependencies.
    echo Run: dumpbin /dependents python\mitsuba\core_ext.pyd
    echo Or use Dependencies tool: https://github.com/lucasg/Dependencies
)

echo.
pause
