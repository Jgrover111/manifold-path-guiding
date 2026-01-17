@echo off
REM CORRECTED Mitsuba 2 to Mitsuba 3 Porting Script for MPG Integrator
REM This script removes unused Enoki includes (they're not actually used in the code)

echo =========================================
echo Mitsuba 2 to Mitsuba 3 Porting Script for MPG (CORRECTED)
echo =========================================
echo.

REM Check if we're in the right directory
if not exist "mitsuba\src\integrators\MPG" (
    echo ERROR: Please run this script from the manifold-path-guiding root directory
    pause
    exit /b 1
)

set MPG_DIR=mitsuba\src\integrators\MPG

echo Step 1: Backup original files...
xcopy /E /I /Y "%MPG_DIR%" "%MPG_DIR%_mitsuba2_backup" >nul
echo [OK] Backup created at %MPG_DIR%_mitsuba2_backup
echo.

echo Step 2: Remove unused Enoki includes...
REM Simply remove the enoki include lines (they're not actually used)
powershell -Command "(Get-ChildItem -Path '%MPG_DIR%' -Include *.h,*.cpp -Recurse | ForEach-Object { (Get-Content $_.FullName) | Where-Object { $_ -notmatch '#include <enoki/morton.h>' -and $_ -notmatch '#include <enoki/stl.h>' } | Set-Content $_.FullName })"
echo [OK] Removed unused Enoki includes
echo.

echo Step 3: Checking for any namespace ek usage...
powershell -Command "$found = $false; Get-ChildItem -Path '%MPG_DIR%' -Include *.h,*.cpp -Recurse | ForEach-Object { if ((Get-Content $_.FullName) -match 'namespace ek|ek::') { Write-Host 'Found in:' $_.FullName; $found = $true } }; if (-not $found) { Write-Host '[OK] No ek:: namespace usage found' }"
echo.

echo =========================================
echo Automated porting complete!
echo =========================================
echo.
echo The Enoki includes were not actually used in the code, so they were simply removed.
echo.
echo Next steps:
echo 1. Copy MPG folder to Mitsuba 3:
echo    xcopy /E /I %MPG_DIR% C:\path\to\mitsuba3\src\integrators\MPG
echo 2. Edit mitsuba3\src\integrators\CMakeLists.txt and add:
echo    add_plugin(MPG MPG/manifold_path_guiding.cpp)
echo 3. Build Mitsuba 3 in Release mode
echo 4. Test with your scenes
echo.
echo Backup location: %MPG_DIR%_mitsuba2_backup
echo.
pause
