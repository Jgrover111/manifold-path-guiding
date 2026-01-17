#!/bin/bash
# Mitsuba 2 to Mitsuba 3 Porting Script for MPG Integrator
# This script automates the main changes needed to port the Manifold Path Guiding code

echo "========================================="
echo "Mitsuba 2 → 3 Porting Script for MPG"
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

echo "Step 2: Replace Enoki with Dr.Jit includes..."
# Replace enoki includes with drjit
find "$MPG_DIR" -type f \( -name "*.h" -o -name "*.cpp" \) -exec sed -i 's/#include <enoki\//#include <drjit\//g' {} +
echo "✓ Updated include statements"
echo

echo "Step 3: Replace Enoki namespace with Dr.Jit..."
# Replace namespace ek = enoki with namespace dr = drjit
find "$MPG_DIR" -type f \( -name "*.h" -o -name "*.cpp" \) -exec sed -i 's/namespace ek = enoki/namespace dr = drjit/g' {} +
# Replace ek:: with dr::
find "$MPG_DIR" -type f \( -name "*.h" -o -name "*.cpp" \) -exec sed -i 's/ek::/dr::/g' {} +
echo "✓ Updated namespace references"
echo

echo "Step 4: Check for common API changes..."
# List files that might need manual review for camelCase → underscore_case
echo "Files that may need manual review for naming convention changes:"
grep -r "sampler->next" "$MPG_DIR" | cut -d: -f1 | sort -u
echo

echo "========================================="
echo "Automated porting complete!"
echo "========================================="
echo
echo "Next steps:"
echo "1. Review the changes: diff -r ${MPG_DIR}_mitsuba2_backup $MPG_DIR"
echo "2. Manually check for camelCase → underscore_case changes if needed"
echo "3. Copy MPG folder to Mitsuba 3: cp -r $MPG_DIR /path/to/mitsuba3/src/integrators/"
echo "4. Update Mitsuba 3 CMakeLists.txt to include MPG"
echo "5. Build and test"
echo
echo "Backup location: ${MPG_DIR}_mitsuba2_backup"
