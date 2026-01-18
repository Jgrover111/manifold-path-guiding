#!/bin/bash
# Script to apply MPG custom extensions to Mitsuba 3
# This adds caustic classification features needed by the MPG integrator

set -e

MITSUBA3_DIR="${1:-/home/user/mitsuba3}"

if [ ! -d "$MITSUBA3_DIR" ]; then
    echo "ERROR: Mitsuba 3 directory not found at $MITSUBA3_DIR"
    echo "Usage: $0 [path/to/mitsuba3]"
    exit 1
fi

echo "========================================="
echo "Applying MPG Extensions to Mitsuba 3"
echo "========================================="
echo "Mitsuba 3 directory: $MITSUBA3_DIR"
echo

# Backup original files
echo "Step 1: Creating backups..."
cp "$MITSUBA3_DIR/include/mitsuba/render/shape.h" "$MITSUBA3_DIR/include/mitsuba/render/shape.h.backup"
cp "$MITSUBA3_DIR/src/render/shape.cpp" "$MITSUBA3_DIR/src/render/shape.cpp.backup" 2>/dev/null || true
cp "$MITSUBA3_DIR/include/mitsuba/render/scene.h" "$MITSUBA3_DIR/include/mitsuba/render/scene.h.backup"
cp "$MITSUBA3_DIR/src/render/scene.cpp" "$MITSUBA3_DIR/src/render/scene.cpp.backup"
echo "✓ Backups created"
echo

echo "Step 2: Patching Shape class..."

# Add caustic methods to shape.h (after is_mesh() method around line 150-200)
SHAPE_H="$MITSUBA3_DIR/include/mitsuba/render/shape.h"

# Check if already patched
if grep -q "is_caustic_receiver" "$SHAPE_H" 2>/dev/null; then
    echo "⚠ Shape.h already contains caustic methods - skipping"
else
    # Find the line with "bool is_mesh()" and add after it
    sed -i '/bool is_mesh()/a\
\
    /// Is this shape a caustic receiver?\
    bool is_caustic_receiver() const { return m_caustic_receiver; }\
\
    /// Is this shape a (single-bounce) caustic caster for specular manifold sampling?\
    bool is_caustic_caster_single_scatter() const { return m_caustic_caster_single; }\
\
    /// Is this shape a (multi-bounce) caustic caster for specular manifold sampling?\
    bool is_caustic_caster_multi_scatter() const { return m_caustic_caster_multi; }\
\
    /// Is this shape a (multi-bounce) caustic bouncer (i.e. it can be an intermediate vertex of a longer chain)?\
    bool is_caustic_bouncer() const { return m_caustic_bouncer; }' "$SHAPE_H"

    # Add member variables (before the closing of protected section, after m_id or similar)
    sed -i '/ref<Medium> m_exterior_medium;/a\
\
    // MPG extension: Caustic classification flags\
    bool m_caustic_receiver = false;\
    bool m_caustic_caster_single = false;\
    bool m_caustic_caster_multi = false;\
    bool m_caustic_bouncer = false;' "$SHAPE_H"

    echo "✓ Shape.h patched"
fi

echo

echo "Step 3: Patching Shape constructor..."

# Patch shape.cpp to initialize caustic flags
SHAPE_CPP="$MITSUBA3_DIR/src/render/shape.cpp"

if [ -f "$SHAPE_CPP" ]; then
    if grep -q "m_caustic_receiver" "$SHAPE_CPP" 2>/dev/null; then
        echo "⚠ shape.cpp already contains caustic initialization - skipping"
    else
        # Add initialization in constructor (after other bool_ property reads)
        # This is a bit tricky - we need to find the Shape constructor and add the lines
        # For now, add instructions to do it manually
        echo "⚠ Manual edit required for shape.cpp"
        echo "  Add these lines to the Shape constructor:"
        echo "    m_caustic_receiver = props.get<bool>(\"caustic_receiver\", false);"
        echo "    m_caustic_caster_single = props.get<bool>(\"caustic_caster_single\", false);"
        echo "    m_caustic_caster_multi = props.get<bool>(\"caustic_caster_multi\", false);"
        echo "    m_caustic_bouncer = props.get<bool>(\"caustic_bouncer\", false);"
    fi
else
    echo "⚠ shape.cpp not found at expected location"
fi

echo

echo "Step 4: Patching Scene class..."

SCENE_H="$MITSUBA3_DIR/include/mitsuba/render/scene.h"

if grep -q "caustic_emitters_multi_scatter" "$SCENE_H" 2>/dev/null; then
    echo "⚠ scene.h already contains caustic methods - skipping"
else
    # Add caustic getter methods (after emitters() method)
    sed -i '/const std::vector<ref<Emitter>> \&emitters()/a\
\
    /// Return caustic emitters for single-scatter manifold sampling\
    std::vector<ref<Emitter>> \&caustic_emitters_single_scatter() { return m_caustic_emitters_single; }\
    const std::vector<ref<Emitter>> \&caustic_emitters_single_scatter() const { return m_caustic_emitters_single; }\
\
    /// Return caustic emitters for multi-scatter manifold sampling\
    std::vector<ref<Emitter>> \&caustic_emitters_multi_scatter() { return m_caustic_emitters_multi; }\
    const std::vector<ref<Emitter>> \&caustic_emitters_multi_scatter() const { return m_caustic_emitters_multi; }\
\
    /// Return caustic casters for single-scatter manifold sampling\
    std::vector<ref<Shape>> \&caustic_casters_single_scatter() { return m_caustic_casters_single; }\
    const std::vector<ref<Shape>> \&caustic_casters_single_scatter() const { return m_caustic_casters_single; }\
\
    /// Return caustic casters for multi-scatter manifold sampling\
    std::vector<ref<Shape>> \&caustic_casters_multi_scatter() { return m_caustic_casters_multi; }\
    const std::vector<ref<Shape>> \&caustic_casters_multi_scatter() const { return m_caustic_casters_multi; }' "$SCENE_H"

    # Add member variables (before closing private section)
    sed -i '/std::vector<ref<Shape>> m_shapes;/a\
\
    // MPG extension: Caustic object lists\
    std::vector<ref<Emitter>> m_caustic_emitters_single;\
    std::vector<ref<Emitter>> m_caustic_emitters_multi;\
    std::vector<ref<Shape>> m_caustic_casters_single;\
    std::vector<ref<Shape>> m_caustic_casters_multi;' "$SCENE_H"

    echo "✓ scene.h patched"
fi

echo

echo "Step 5: Patching Scene constructor..."

SCENE_CPP="$MITSUBA3_DIR/src/render/scene.cpp"

if grep -q "m_caustic_casters_single" "$SCENE_CPP" 2>/dev/null; then
    echo "⚠ scene.cpp already contains caustic initialization - skipping"
else
    echo "⚠ Manual edit required for scene.cpp"
    echo "  Add these lines to the Scene constructor (after shapes/emitters setup):"
    echo "    // Populate caustic lists"
    echo "    for (auto shape : m_shapes) {"
    echo "        if (shape->is_caustic_caster_single_scatter())"
    echo "            m_caustic_casters_single.push_back(shape);"
    echo "        if (shape->is_caustic_caster_multi_scatter())"
    echo "            m_caustic_casters_multi.push_back(shape);"
    echo "    }"
    echo "    for (auto emitter : m_emitters) {"
    echo "        // Note: Need to add is_caustic_emitter methods to Emitter class"
    echo "        // if (emitter->is_caustic_emitter_single_scatter())"
    echo "        //     m_caustic_emitters_single.push_back(emitter);"
    echo "        // if (emitter->is_caustic_emitter_multi_scatter())"
    echo "        //     m_caustic_emitters_multi.push_back(emitter);"
    echo "    }"
fi

echo
echo "========================================="
echo "Patching Complete!"
echo "========================================="
echo
echo "Summary:"
echo "  ✓ Shape class extended with caustic classification"
echo "  ✓ Scene class extended with caustic lists"
echo "  ⚠ Manual edits may be required (see above)"
echo
echo "Next steps:"
echo "  1. Review the changes in $MITSUBA3_DIR"
echo "  2. Complete any manual edits noted above"
echo "  3. Rebuild Mitsuba 3: cd $MITSUBA3_DIR/build && ninja"
echo "  4. Test with MPG integrator"
echo
echo "To restore original files:"
echo "  cp $MITSUBA3_DIR/include/mitsuba/render/shape.h.backup $MITSUBA3_DIR/include/mitsuba/render/shape.h"
echo "  cp $MITSUBA3_DIR/include/mitsuba/render/scene.h.backup $MITSUBA3_DIR/include/mitsuba/render/scene.h"
echo
