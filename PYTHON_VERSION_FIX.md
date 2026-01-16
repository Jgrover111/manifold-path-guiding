# Fixing Python Version Mismatch for Blender Integration

## The Problem

When enabling the Mitsuba-Blender plugin, you get this error:

```
The 'mitsuba' native modules could not be imported. You're likely trying to use
Mitsuba within a Python binary (C:\Program Files\Blender Foundation\Blender 4.4\4.4\python\bin\python.exe)
that is different from the one for which the native module was compiled
(C:\Users\josep\AppData\Local\Programs\Python\Python310\python.exe).
```

## Root Cause

**Version Mismatch:**
- Your Mitsuba was built with **Python 3.10**
- Blender 4.4 uses **Python 3.11.11**

Python native modules (`.pyd` files on Windows) are **not binary-compatible** across different Python versions. You must rebuild Mitsuba with the exact Python version that Blender uses.

## Solution Overview

You have **3 options**:

1. **Option A (Recommended):** Rebuild Mitsuba with Python 3.11 to match Blender 4.4
2. **Option B:** Use an older Blender version that uses Python 3.10
3. **Option C:** Use Blender's bundled Python directly (advanced)

---

## Option A: Rebuild Mitsuba with Python 3.11 (Recommended)

This is the **best long-term solution** for Blender 4.4 compatibility.

### Step 1: Install Python 3.11

1. **Download Python 3.11.11:**
   - Visit: https://www.python.org/downloads/
   - Download "Python 3.11.11" (or latest 3.11.x) for Windows
   - Choose the **64-bit installer**

2. **Install Python 3.11:**
   - Run the installer
   - ✅ **Check "Add Python 3.11 to PATH"**
   - Choose "Customize installation"
   - Make note of the installation path (e.g., `C:\Python311\`)
   - **Important:** Install for all users or remember your installation path

3. **Verify installation:**
   ```batch
   python --version
   ```
   Should show: `Python 3.11.11` (or similar 3.11.x)

### Step 2: Clean Previous Build

In CLion or manually:

```batch
cd C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba
rmdir /s /q cmake-build-release-visual-studio
```

Or in CLion:
- File → Invalidate Caches / Restart
- Tools → CMake → Reset Cache and Reload Project

### Step 3: Reconfigure CMake with Python 3.11

**In CLion:**

1. **Open Settings:**
   - File → Settings → Build, Execution, Deployment → CMake

2. **Update CMake Options:**

   Change your CMake options from:
   ```
   -G "Visual Studio 17 2022" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -T v142 -A x64
   ```

   To:
   ```
   -G "Visual Studio 17 2022" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -T v142 -A x64 -DPython3_EXECUTABLE=C:\Python311\python.exe
   ```

   **Or**, if you want to use Blender's Python directly:
   ```
   -G "Visual Studio 17 2022" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -T v142 -A x64 -DPython3_EXECUTABLE="C:\Program Files\Blender Foundation\Blender 4.4\4.4\python\bin\python.exe"
   ```

3. **Click OK** and let CMake reconfigure

**From Command Line (Alternative):**

```batch
cd C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba
mkdir build-blender44
cd build-blender44

cmake -G "Visual Studio 17 2022" ^
      -A x64 ^
      -T v142 ^
      -DPython3_EXECUTABLE="C:\Python311\python.exe" ^
      ..
```

### Step 4: Rebuild Mitsuba

**In CLion:**
- Build → Build Project (or Ctrl+F9)
- Select **Release** configuration
- Build

**From Command Line:**
```batch
cmake --build . --config Release
```

### Step 5: Verify Python Version in Build

After building, verify the correct Python was used:

```batch
cd dist\python
python -c "import mitsuba; print(mitsuba.__file__)"
```

This should work without errors if built correctly.

### Step 6: Update Blender Plugin Path

In Blender:
1. Edit → Preferences → Add-ons → Mitsuba-Blender
2. Update "Custom Mitsuba path" to the new build:
   ```
   C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba\cmake-build-release-visual-studio\dist
   ```
   (or `build-blender44\dist` if you used command line)
3. Restart Blender

### Step 7: Test

- Switch to Mitsuba render engine
- Press F12 to render
- Should work without Python errors! ✅

---

## Option B: Use Compatible Blender Version

If you can't rebuild or want a quicker solution, use a Blender version with Python 3.10.

### Blender Versions with Python 3.10:

- **Blender 3.3 LTS** - Python 3.10.2
- **Blender 3.4** - Python 3.10.8
- **Blender 3.5** - Python 3.10.9
- **Blender 3.6 LTS** - Python 3.10.13

**Recommendation:** Download **Blender 3.6 LTS** from:
- https://www.blender.org/download/lts/3-6/

Then follow the normal Blender setup from `BLENDER_SETUP_GUIDE.md`.

### Blender-Python Version Reference

| Blender Version | Python Version |
|-----------------|----------------|
| 4.4             | 3.11.11        |
| 4.3             | 3.11.9         |
| 4.2 LTS         | 3.11.7         |
| 4.1             | 3.11.7         |
| 4.0             | 3.10.13        |
| 3.6 LTS         | 3.10.13        |
| 3.5             | 3.10.9         |
| 3.4             | 3.10.8         |
| 3.3 LTS         | 3.10.2         |

---

## Option C: Use Blender's Python for Building (Advanced)

Point CMake directly to Blender's bundled Python:

```cmake
-DPython3_EXECUTABLE="C:\Program Files\Blender Foundation\Blender 4.4\4.4\python\bin\python.exe"
-DPython3_INCLUDE_DIR="C:\Program Files\Blender Foundation\Blender 4.4\4.4\python\include"
-DPython3_LIBRARY="C:\Program Files\Blender Foundation\Blender 4.4\4.4\python\libs\python311.lib"
```

**Pros:** Perfect version matching
**Cons:** Tied to Blender installation, more complex

---

## Troubleshooting

### "Python3 not found" during CMake

**Solution:** Explicitly set all Python paths:

```cmake
-DPython3_ROOT_DIR=C:\Python311
-DPython3_EXECUTABLE=C:\Python311\python.exe
-DPython3_INCLUDE_DIR=C:\Python311\include
-DPython3_LIBRARY=C:\Python311\libs\python311.lib
```

### Build succeeds but still getting version error

**Verify you're pointing to the new build:**
1. Check the dist folder contains `python/` subdirectory
2. Verify the path in Blender preferences is correct
3. Restart Blender completely (close all instances)

### Multiple Python versions causing issues

**Set Python3_FIND_REGISTRY to NEVER:**

```cmake
-DPython3_FIND_REGISTRY=NEVER -DPython3_EXECUTABLE=C:\Python311\python.exe
```

This prevents CMake from finding other Python installations.

### DLL errors after rebuild

**Ensure Python 3.11 is in your PATH:**

```batch
set PATH=C:\Python311;%PATH%
```

Or add permanently via System Environment Variables.

---

## Quick Reference Commands

### Check Blender's Python version:
```batch
"C:\Program Files\Blender Foundation\Blender 4.4\4.4\python\bin\python.exe" --version
```

### Check your system Python version:
```batch
python --version
```

### Clean CMake cache in CLion:
```
Tools → CMake → Reset Cache and Reload Project
```

### Reconfigure with specific Python:
```batch
cmake -G "Visual Studio 17 2022" -A x64 -T v142 ^
      -DPython3_EXECUTABLE=C:\Python311\python.exe ^
      ..
```

---

## Recommended Workflow

For Blender 4.4 integration, the recommended setup is:

1. ✅ Install Python 3.11.11 standalone
2. ✅ Rebuild Mitsuba with `-DPython3_EXECUTABLE=C:\Python311\python.exe`
3. ✅ Point Blender to the new build
4. ✅ Test and verify

This ensures:
- Version compatibility
- Independence from Blender updates
- Ability to use Mitsuba standalone
- Better debugging capabilities

---

## Why This Happens

Python extension modules (`.pyd` files on Windows, `.so` on Linux) are compiled to a specific Python version's **ABI (Application Binary Interface)**. Each Python version has a different ABI:

- Python 3.10 → `python310.dll` / `cp310` ABI
- Python 3.11 → `python311.dll` / `cp311` ABI

When you try to import a module compiled for Python 3.10 into Python 3.11, the module loader detects the ABI mismatch and raises an error.

**The solution:** Always compile Python extensions with the same Python version as the target application (Blender in this case).

---

## Related Resources

- [FindPython3 CMake Documentation](https://cmake.org/cmake/help/latest/module/FindPython3.html)
- [Blender 4.4 Python API](https://developer.blender.org/docs/release_notes/4.4/python_api/)
- [Python Downloads](https://www.python.org/downloads/)
- [Blender LTS Versions](https://www.blender.org/download/lts/)

---

## Summary

The error occurs because of **Python version mismatch**:
- Mitsuba: Built with Python 3.10
- Blender 4.4: Uses Python 3.11.11

**Fix:** Rebuild Mitsuba with Python 3.11 or use Blender 3.6 LTS (Python 3.10).

**Recommended:** Install Python 3.11, rebuild with `-DPython3_EXECUTABLE=C:\Python311\python.exe`
