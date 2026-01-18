#!/bin/bash
# Script to update MPG code from Mitsuba 2 to Mitsuba 3 API

echo "========================================="
echo "Mitsuba 2 → 3 API Update Script"
echo "========================================="
echo

MPG_DIR="mitsuba/src/integrators/MPG"

if [ ! -d "$MPG_DIR" ]; then
    echo "ERROR: MPG directory not found at $MPG_DIR"
    exit 1
fi

echo "Step 1: Replacing MTS_* macros with MI_* macros..."

# Find all .h and .cpp files
find "$MPG_DIR" -type f \( -name "*.h" -o -name "*.cpp" \) | while read file; do
    echo "  Processing: $file"

    # Replace all MTS_ macros with MI_ equivalents
    sed -i 's/MTS_IMPORT_TYPES/MI_IMPORT_TYPES/g' "$file"
    sed -i 's/MTS_IMPORT_RENDER_BASIC_TYPES/MI_IMPORT_RENDER_BASIC_TYPES/g' "$file"
    sed -i 's/MTS_IMPORT_BASE/MI_IMPORT_BASE/g' "$file"
    sed -i 's/MTS_INLINE/MI_INLINE/g' "$file"
    sed -i 's/MTS_MASKED_FUNCTION/MI_MASKED_FUNCTION/g' "$file"
    sed -i 's/MTS_DECLARE_CLASS/MI_DECLARE_CLASS/g' "$file"
    sed -i 's/MTS_IMPLEMENT_CLASS_VARIANT/MI_IMPLEMENT_CLASS_VARIANT/g' "$file"
    sed -i 's/MTS_EXPORT_PLUGIN/MI_EXPORT_PLUGIN/g' "$file"
done

echo "✓ Macro replacement complete!"
echo

echo "Step 2: Verifying changes..."
echo "Checking for remaining MTS_ macros:"
if grep -r "MTS_" "$MPG_DIR" --include="*.h" --include="*.cpp" 2>/dev/null; then
    echo "⚠ WARNING: Some MTS_ macros remain"
else
    echo "✓ All MTS_ macros successfully replaced with MI_"
fi
echo

echo "Step 3: Checking MI_ macro usage:"
echo "MI_IMPORT_TYPES: $(grep -r "MI_IMPORT_TYPES" "$MPG_DIR" --include="*.h" --include="*.cpp" | wc -l) occurrences"
echo "MI_IMPORT_RENDER_BASIC_TYPES: $(grep -r "MI_IMPORT_RENDER_BASIC_TYPES" "$MPG_DIR" --include="*.h" --include="*.cpp" | wc -l) occurrences"
echo "MI_IMPORT_BASE: $(grep -r "MI_IMPORT_BASE" "$MPG_DIR" --include="*.h" --include="*.cpp" | wc -l) occurrences"
echo "MI_INLINE: $(grep -r "MI_INLINE" "$MPG_DIR" --include="*.h" --include="*.cpp" | wc -l) occurrences"
echo

echo "========================================="
echo "API Update Complete!"
echo "========================================="
echo
echo "Next steps:"
echo "1. Review the changes: git diff $MPG_DIR"
echo "2. Copy to Mitsuba 3: cp -r $MPG_DIR /path/to/mitsuba3/src/integrators/"
echo "3. Build and test"
echo
