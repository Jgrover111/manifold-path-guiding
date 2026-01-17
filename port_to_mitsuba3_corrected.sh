#!/bin/bash
# CORRECTED Mitsuba 2 to Mitsuba 3 Porting Script for MPG Integrator
# This script removes unused Enoki includes (they're not actually used in the code)

echo "========================================="
echo "Mitsuba 2 → 3 Porting Script for MPG (CORRECTED)"
echo "========================================="
echo

# Check if we're in the right directory
if [ ! -d "mitsuba/src/integrators/MPG" ]; then
    echo "ERROR: Please run this script from the manifold-path-guiding root directory"
    exit 1
fi

MPG_DIR="mitsuba/src/integrators/MPG"

echo "Step 1: Backup original files..."
cp -r "$MPG_DIR" "${MPG_DIR}_mitsuba2_backup"
echo "✓ Backup created at ${MPG_DIR}_mitsuba2_backup"
echo

echo "Step 2: Remove unused Enoki includes..."
# Simply remove the enoki include lines (they're not actually used)
find "$MPG_DIR" -type f \( -name "*.h" -o -name "*.cpp" \) -exec sed -i '/#include <enoki\/morton.h>/d' {} +
find "$MPG_DIR" -type f \( -name "*.h" -o -name "*.cpp" \) -exec sed -i '/#include <enoki\/stl.h>/d' {} +
echo "✓ Removed unused Enoki includes"
echo

echo "Step 3: Checking for any namespace ek usage..."
if grep -r "namespace ek\|ek::" "$MPG_DIR" 2>/dev/null; then
    echo "⚠ WARNING: Found ek:: or namespace ek usage"
    echo "These need manual review and replacement with dr::"
else
    echo "✓ No ek:: namespace usage found"
fi
echo

echo "========================================="
echo "Automated porting complete!"
echo "========================================="
echo
echo "The Enoki includes were not actually used in the code, so they were simply removed."
echo
echo "Next steps:"
echo "1. Copy MPG folder to Mitsuba 3: cp -r $MPG_DIR /path/to/mitsuba3/src/integrators/"
echo "2. Update Mitsuba 3's src/integrators/CMakeLists.txt to add:"
echo "   add_plugin(MPG MPG/manifold_path_guiding.cpp)"
echo "3. Build and test"
echo
echo "Backup location: ${MPG_DIR}_mitsuba2_backup"
