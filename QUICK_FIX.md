# Quick Fix for Visual Studio 2022 Build Error

## The Error You're Seeing

```
error C2065: 'ssize_t': undeclared identifier
error C2338: ssize_t != Py_intptr_t
```

## Fastest Solution (Choose One)

### Option A: Update pybind11 (Recommended - Permanent Fix)

**On Windows (PowerShell or Git Bash):**
```powershell
cd mitsuba\ext\pybind11
git fetch --all --tags
git checkout v2.11.1
cd ..\..\..
git add mitsuba/ext/pybind11
```

**Or use the provided script:**
```batch
update_pybind11.bat
```

### Option B: Apply CMake Workaround (Quick Temporary Fix)

Add this ONE line to `mitsuba/CMakeLists.txt` at line 121 (right after `list(APPEND CMAKE_MODULE_PATH...`):

```cmake
include(cmake/apply_vs2022_fix.cmake)
```

That's it! The fix files are already created in `mitsuba/cmake/`.

### Option C: Change Toolset

In CLion CMake options, change from `-T v142` to `-T v143`:

```
-G "Visual Studio 17 2022" -A x64 -T v143
```

## After Applying Any Fix

1. In CLion: **File → Invalidate Caches / Restart**
2. Or manually clean build: Delete `cmake-build-release-visual-studio` folder
3. Reconfigure and rebuild

## Need More Details?

See `VS2022_BUILD_FIX.md` for comprehensive documentation.

## Why Does This Happen?

The VS 2019 toolset (v142) running under VS 2022 still uses VS 2022's standard library headers. Older pybind11 versions don't handle this correctly. The fix was added in pybind11 v2.9.1 (Feb 2022).
