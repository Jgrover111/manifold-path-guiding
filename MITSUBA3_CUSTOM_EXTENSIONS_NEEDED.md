# Mitsuba 3 Custom Extensions Required for MPG

## Overview

The MPG (Manifold Path Guiding) integrator requires custom extensions that were added to Mitsuba 2 but don't exist in standard Mitsuba 3. These extensions enable caustic classification for efficient specular manifold sampling.

## Custom Extensions in Mitsuba 2 (This Repository)

### 1. Shape Class Extensions

**File:** `mitsuba/include/mitsuba/render/shape.h` (lines 333-343, 428-431)

Added caustic classification flags:

```cpp
// Getter methods (lines 333-343)
bool is_caustic_receiver() const { return m_caustic_receiver; }
bool is_caustic_caster_single_scatter() const { return m_caustic_caster_single; }
bool is_caustic_caster_multi_scatter() const { return m_caustic_caster_multi; }
bool is_caustic_bouncer() const { return m_caustic_bouncer; }

// Member variables (lines 428-431)
bool m_caustic_receiver = false;
bool m_caustic_caster_single = false;
bool m_caustic_caster_multi = false;
bool m_caustic_bouncer = false;
```

**Initialization:** `mitsuba/src/librender/shape.cpp` (lines 79-82)

```cpp
m_caustic_receiver = props.bool_("caustic_receiver", false);
m_caustic_caster_single = props.bool_("caustic_caster_single", false);
m_caustic_caster_multi = props.bool_("caustic_caster_multi", false);
m_caustic_bouncer = props.bool_("caustic_bouncer", false);
```

### 2. Emitter Class Extensions

**File:** `mitsuba/include/mitsuba/render/emitter.h` (lines 71-74)

Added caustic emitter classification:

```cpp
bool is_caustic_emitter_single_scatter() const { return m_caustic_emitter_single; }
bool is_caustic_emitter_multi_scatter() const { return m_caustic_emitter_multi; }
```

### 3. Scene Class Extensions

**File:** `mitsuba/include/mitsuba/render/scene.h` (lines 140-165, 218-223)

Added caustic object lists:

```cpp
// Getter methods
std::vector<ref<Emitter>> &caustic_emitters_single_scatter();
const std::vector<ref<Emitter>> &caustic_emitters_single_scatter() const;
std::vector<ref<Emitter>> &caustic_emitters_multi_scatter();
const std::vector<ref<Emitter>> &caustic_emitters_multi_scatter() const;
std::vector<ref<Shape>> &caustic_casters_single_scatter();
const std::vector<ref<Shape>> &caustic_casters_single_scatter() const;
std::vector<ref<Shape>> &caustic_casters_multi_scatter();
const std::vector<ref<Shape>> &caustic_casters_multi_scatter() const;

// Member variables
std::vector<ref<Emitter>> m_caustic_emitters_single;
std::vector<ref<Emitter>> m_caustic_emitters_multi;
std::vector<ref<Shape>> m_caustic_casters_single;
std::vector<ref<Shape>> m_caustic_casters_multi;
```

**Initialization:** `mitsuba/src/librender/scene.cpp` (lines 100-112)

```cpp
// Populate caustic casters
for (Shape *shape: m_shapes) {
    if (shape->is_caustic_caster_single_scatter())
        m_caustic_casters_single.push_back(shape);
    if (shape->is_caustic_caster_multi_scatter())
        m_caustic_casters_multi.push_back(shape);
}

// Populate caustic emitters
for (Emitter *emitter: m_emitters) {
    if (emitter->is_caustic_emitter_single_scatter())
        m_caustic_emitters_single.push_back(emitter);
    if (emitter->is_caustic_emitter_multi_scatter())
        m_caustic_emitters_multi.push_back(emitter);
}
```

## Required Porting to Mitsuba 3

To fully port MPG to Mitsuba 3, you need to add these same extensions to your Mitsuba 3 installation. Here's how:

### Option 1: Direct Modification (Recommended for Testing)

1. **Modify `/home/user/mitsuba3/include/mitsuba/render/shape.h`:**
   - Add the 4 caustic flag member variables
   - Add the 4 getter methods
   - Update constructor to read from Properties

2. **Modify `/home/user/mitsuba3/src/librender/shape.cpp`:**
   - Initialize caustic flags from XML properties in Shape constructor

3. **Modify `/home/user/mitsuba3/include/mitsuba/render/emitter.h`:**
   - Add caustic emitter flags and getters
   - Initialize from Properties

4. **Modify `/home/user/mitsuba3/include/mitsuba/render/scene.h`:**
   - Add caustic object list member variables
   - Add getter methods

5. **Modify `/home/user/mitsuba3/src/librender/scene.cpp`:**
   - Populate caustic lists during scene construction

### Option 2: Fork Mitsuba 3 (Recommended for Production)

Create a fork of Mitsuba 3 with these extensions permanently integrated.

## XML Scene Configuration

With these extensions, you can configure caustic properties in scene XML:

```xml
<shape type="obj">
    <string name="filename" value="glass_sphere.obj"/>

    <!-- Mark as caustic receiver (can receive caustics) -->
    <boolean name="caustic_receiver" value="true"/>

    <!-- Mark as single-bounce caustic caster -->
    <boolean name="caustic_caster_single" value="false"/>

    <!-- Mark as multi-bounce caustic caster -->
    <boolean name="caustic_caster_multi" value="true"/>

    <!-- Mark as caustic bouncer (intermediate vertex) -->
    <boolean name="caustic_bouncer" value="true"/>

    <bsdf type="dielectric">
        <float name="int_ior" value="1.5"/>
    </bsdf>
</shape>

<emitter type="point">
    <point name="position" value="0, 5, 0"/>

    <!-- Mark emitter for caustic rendering -->
    <boolean name="caustic_emitter_single" value="false"/>
    <boolean name="caustic_emitter_multi" value="true"/>

    <rgb name="intensity" value="100, 100, 100"/>
</emitter>
```

## Current Status in MPG Code

The MPG integrator code has been updated to:

1. ✅ Use `dr::` namespace for all Dr.Jit functions
2. ✅ Fix API compatibility issues (DirectionSample, BSDFContext, etc.)
3. ⚠️ **Caustic features temporarily disabled** (lines 837-852 in manifold_path_guiding.cpp)

```cpp
// Temporarily disabled until Mitsuba 3 extensions are added:
bool on_caustic_caster = false; // was: si.shape->is_caustic_caster_multi_scatter()

if (false && !on_caustic_caster && ...) {  // Disabled caustic block
    EmitterInteraction ei = SpecularManifold<Float, Spectrum>::sample_emitter_interaction(
        si, nullptr, sampler);  // was: scene->caustic_emitters_multi_scatter()
    // ...
}
```

## Next Steps

1. **Apply custom extensions to Mitsuba 3** using Option 1 or 2 above
2. **Re-enable caustic features** in MPG code by:
   - Changing `bool on_caustic_caster = false;` to use actual method calls
   - Changing `if (false && ...)` to `if (si.shape->is_caustic_receiver() && ...)`
   - Restoring `scene->caustic_emitters_multi_scatter()` call
3. **Test build** to ensure all extensions work correctly
4. **Configure scene XML** with appropriate caustic flags

## References

- Original MPG Paper: Manifold Next Event Estimation (SIGGRAPH 2020)
- Custom extensions were added to support efficient caustic path classification
- These extensions allow MPG to selectively apply specular manifold sampling only where needed

## Alternative: Simplified Port Without Caustic Classification

If you want MPG to work immediately without modifying Mitsuba 3:

1. Keep caustic detection disabled (current state)
2. Apply manifold sampling to **all** shapes (less efficient but functional)
3. Modify MPG code to remove caustic-specific logic entirely

This would give you a working but less optimized version of MPG.
