@echo off
REM Mitsuba 2 to Mitsuba 3 Porting Script for MPG Integrator
REM This script automates the main changes needed to port the Manifold Path Guiding code

echo =========================================
echo Mitsuba 2 to Mitsuba 3 Porting Script for MPG
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

echo Step 2: Replace Enoki with Dr.Jit includes...
REM Use PowerShell for sed-like functionality
powershell -Command "(Get-ChildItem -Path '%MPG_DIR%' -Filter *.h -Recurse | ForEach-Object { (Get-Content $_.FullName) -replace '#include <enoki/', '#include <drjit/' | Set-Content $_.FullName })"
powershell -Command "(Get-ChildItem -Path '%MPG_DIR%' -Filter *.cpp -Recurse | ForEach-Object { (Get-Content $_.FullName) -replace '#include <enoki/', '#include <drjit/' | Set-Content $_.FullName })"
echo [OK] Updated include statements
echo.

echo Step 3: Replace Enoki namespace with Dr.Jit...
powershell -Command "(Get-ChildItem -Path '%MPG_DIR%' -Filter *.h -Recurse | ForEach-Object { (Get-Content $_.FullName) -replace 'namespace ek = enoki', 'namespace dr = drjit' | Set-Content $_.FullName })"
powershell -Command "(Get-ChildItem -Path '%MPG_DIR%' -Filter *.cpp -Recurse | ForEach-Object { (Get-Content $_.FullName) -replace 'namespace ek = enoki', 'namespace dr = drjit' | Set-Content $_.FullName })"
powershell -Command "(Get-ChildItem -Path '%MPG_DIR%' -Filter *.h -Recurse | ForEach-Object { (Get-Content $_.FullName) -replace 'ek::', 'dr::' | Set-Content $_.FullName })"
powershell -Command "(Get-ChildItem -Path '%MPG_DIR%' -Filter *.cpp -Recurse | ForEach-Object { (Get-Content $_.FullName) -replace 'ek::', 'dr::' | Set-Content $_.FullName })"
echo [OK] Updated namespace references
echo.

echo =========================================
echo Automated porting complete!
echo =========================================
echo.
echo Next steps:
echo 1. Clone Mitsuba 3: git clone --recursive https://github.com/mitsuba-renderer/mitsuba3
echo 2. Copy MPG folder: xcopy /E /I %MPG_DIR% C:\path\to\mitsuba3\src\integrators\MPG
echo 3. Update mitsuba3\src\integrators\CMakeLists.txt to add MPG
echo 4. Build Mitsuba 3 with Python 3.10.13
echo 5. Test with sample scenes
echo.
echo Backup location: %MPG_DIR%_mitsuba2_backup
echo.
pause
