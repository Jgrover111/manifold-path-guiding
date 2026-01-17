# Porting Manifold Path Guiding to Mitsuba 3

This guide walks you through porting the MPG integrator from Mitsuba 2 to Mitsuba 3.

## Overview

**Estimated time:** 2-3 hours
**Difficulty:** Medium
**Prerequisites:**
- Basic understanding of C++
- Mitsuba 2 build working
- Python 3.10.13 installed (for Blender 4.0 compatibility)

## Why Port to Mitsuba 3?

✅ **Pros:**
- Modern Blender plugin works perfectly
- Active development and support
- Better performance with Dr.Jit backend
- Future-proof solution
- Clean Python 3.10+ support

❌ **Mitsuba 2 Drawbacks:**
- Deprecated (no updates)
- No modern Blender plugin
- Uses outdated Enoki backend

## Main Changes Required

According to the [official Mitsuba 3 migration guide](https://mitsuba.readthedocs.io/en/stable/src/key_topics/differences.html):

### 1. Replace Enoki with Dr.Jit

**Before (Mitsuba 2):**
```cpp
#include <enoki/morton.h>
#include <enoki/stl.h>
namespace ek = enoki;
```

**After (Mitsuba 3):**
```cpp
#include <drjit/morton.h>
#include <drjit/stl.h>
namespace dr = drjit;
```

### 2. Namespace Changes

**Find and replace:**
- `ek::` → `dr::`
- `enoki::` → `drjit::`

### 3. Naming Convention (Less Common)

Some APIs changed from camelCase → underscore_case:
- `next_1d()` stays the same ✅
- Most MPG code shouldn't need changes here

### 4. Scene Compatibility

✅ **Good news:** Mitsuba 3 maintains XML scene compatibility with Mitsuba 2!
- Your test scenes will work as-is
- No scene file changes needed

---

## Step-by-Step Porting Process

### Step 1: Clone Mitsuba 3

```batch
cd C:\Users\josep\CLionProjects
git clone --recursive https://github.com/mitsuba-renderer/mitsuba3
cd mitsuba3
```

**Note:** The `--recursive` flag is important! It clones all submodules (including Dr.Jit).

### Step 2: Run Automated Porting Script

From your `manifold-path-guiding` directory:

```batch
cd C:\Users\josep\CLionProjects\manifold-path-guiding
port_to_mitsuba3.bat
```

This script automatically:
- ✅ Backs up original MPG code
- ✅ Replaces `enoki` → `drjit` includes
- ✅ Updates namespace references
- ✅ Creates a backup at `mitsuba/src/integrators/MPG_mitsuba2_backup`

### Step 3: Copy MPG to Mitsuba 3

```batch
xcopy /E /I mitsuba\src\integrators\MPG C:\Users\josep\CLionProjects\mitsuba3\src\integrators\MPG
```

### Step 4: Update Mitsuba 3 CMakeLists.txt

Add MPG to the integrators build:

**Edit:** `C:\Users\josep\CLionProjects\mitsuba3\src\integrators\CMakeLists.txt`

**Add this line** (near other integrator entries):
```cmake
add_plugin(MPG MPG/manifold_path_guiding.cpp)
```

Example location (add after other integrators):
```cmake
add_plugin(path         path/path.cpp)
add_plugin(volpath      volpath/volpath.cpp)
add_plugin(MPG          MPG/manifold_path_guiding.cpp)  # ← Add this
```

### Step 5: Configure Mitsuba 3 Variants

**Edit:** `C:\Users\josep\CLionProjects\mitsuba3\mitsuba.conf`

Make sure you have the variants you need enabled (MPG works with these):

```python
"enabled": [
    "scalar_rgb",
    "scalar_spectral"
]
```

### Step 6: Configure CMake for Mitsuba 3

In CLion, create a new CMake profile for Mitsuba 3:

**CMake options:**
```
-G "Visual Studio 17 2022" -T v142 -A x64
```

**CMakeLists.txt path:**
```
C:\Users\josep\CLionProjects\mitsuba3\CMakeLists.txt
```

CMake will automatically find your Python 3.10.13 (since it's in PATH).

### Step 7: Build Mitsuba 3

```
Build → Build Project (Release)
```

**Expected build time:** 20-40 minutes (first build)

### Step 8: Copy DLLs (Same as Mitsuba 2)

After build completes:

```batch
cd C:\Users\josep\CLionProjects\mitsuba3\build\dist
copy *.dll python\mitsuba\
copy C:\Python31013\python310.dll python\mitsuba\
```

### Step 9: Test MPG Import

```batch
set PATH=%CD%;C:\Python31013;%PATH%
python -c "import mitsuba; mitsuba.set_variant('scalar_rgb'); from mitsuba.integrators import MPG; print('SUCCESS - MPG loaded!')"
```

### Step 10: Test with Cornell Box

Use one of your test scenes:

```batch
cd C:\Users\josep\CLionProjects\manifold-path-guiding\scenes
C:\Users\josep\CLionProjects\mitsuba3\build\dist\mitsuba.exe <scene.xml>
```

---

## Troubleshooting

### Build Error: "drjit/morton.h not found"

**Cause:** Dr.Jit submodule not initialized

**Solution:**
```batch
cd C:\Users\josep\CLionProjects\mitsuba3
git submodule update --init --recursive
```

### Build Error: "namespace dr has no member..."

**Cause:** Incomplete Enoki → Dr.Jit replacement

**Solution:**
- Check for remaining `ek::` references
- Search for `enoki` in MPG files
- Use find/replace in your IDE

### Python Import Error

**Cause:** DLLs not copied or wrong PATH

**Solution:**
```batch
cd C:\Users\josep\CLionProjects\mitsuba3\build\dist
copy *.dll python\mitsuba\
copy C:\Python31013\python310.dll python\mitsuba\
```

### Scene Rendering Different Results

**Expected:** Minor differences due to Dr.Jit vs Enoki floating point operations

**Action:** Compare variance, not exact pixel values

---

## Verification Checklist

After porting, verify:

- [ ] Mitsuba 3 builds successfully
- [ ] No build warnings related to MPG
- [ ] Python can import `mitsuba` module
- [ ] MPG integrator loads: `from mitsuba.integrators import MPG`
- [ ] Test scene renders without errors
- [ ] Output looks correct (compare with Mitsuba 2 render)
- [ ] Blender plugin can connect to build
- [ ] Can render from Blender

---

## Integration with Blender

Once Mitsuba 3 with MPG builds successfully:

### Install mitsuba-blender Plugin

1. Download latest release: https://github.com/mitsuba-renderer/mitsuba-blender/releases
2. Install in Blender: Edit → Preferences → Add-ons → Install
3. Enable "Mitsuba-Blender"
4. Point to: `C:\Users\josep\CLionProjects\mitsuba3\build\dist`
5. Restart Blender

### Test in Blender

1. Create a simple scene (cube + light)
2. Switch to Mitsuba render engine
3. Press F12 to render
4. Should work! ✅

### Use MPG Integrator

Currently, MPG might not appear in Blender UI. Use XML export workflow:

1. Export scene: File → Export → Mitsuba (.xml)
2. Edit XML, change integrator to:
   ```xml
   <integrator type="MPG">
       <integer name="max_depth" value="12"/>
   </integrator>
   ```
3. Render: `mitsuba.exe scene.xml`

---

## Performance Comparison

Expected performance with Mitsuba 3:

- ✅ **Faster:** Dr.Jit is more optimized than Enoki
- ✅ **Better memory usage:** Improved garbage collection
- ✅ **Same quality:** MPG algorithm unchanged

---

## Code Size Summary

| Component | Lines of Code | Changes Needed |
|-----------|---------------|----------------|
| manifold_path_guiding.cpp | ~950 | Minimal (includes only) |
| manifold_path_guiding.h | ~1,400 | Minimal (includes only) |
| ann.h | ~5,500 | Enoki → Dr.Jit (2 lines) |
| util.h | ~130 | Enoki → Dr.Jit (2 lines) |
| chain_distribution.h | ~450 | Minimal |
| dtree.h | ~460 | Minimal |
| spatial_structure.h | ~630 | Minimal |
| **Total** | **~9,600** | **~10 lines changed** |

**Main work:** Only ~10 lines of actual code changes! Rest is CMake setup and testing.

---

## References

- [Mitsuba 3 Official Documentation](https://mitsuba.readthedocs.io/)
- [Mitsuba 2 → 3 Migration Guide](https://mitsuba.readthedocs.io/en/stable/src/key_topics/differences.html)
- [Dr.Jit Documentation](https://drjit.readthedocs.io/)
- [Manifold Path Guiding Paper](https://zhiminfan.work/manifoldPG.html)
- [mitsuba-blender Plugin](https://github.com/mitsuba-renderer/mitsuba-blender)

---

## Next Steps

After successful porting:

1. ✅ Test thoroughly with your scenes
2. ✅ Compare results with Mitsuba 2 renders
3. ✅ Integrate with Blender
4. ✅ Consider contributing back to the community!

---

## Need Help?

If you encounter issues:

1. Check the Mitsuba 3 documentation
2. Search Mitsuba GitHub issues
3. Compare with other Mitsuba 3 integrators (e.g., `path.cpp`)
4. Review the Dr.Jit migration examples

**Happy porting!** 🚀
