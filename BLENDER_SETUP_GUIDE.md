# Connecting Mitsuba to Blender - Complete Setup Guide

This guide explains how to use your successfully built Mitsuba 2 (with Manifold Path Guiding) as a render engine in Blender.

## Overview

Mitsuba 2 integrates with Blender through the **mitsuba-blender** addon, which allows you to:
- Export Blender scenes to Mitsuba format
- Render scenes using Mitsuba's advanced rendering algorithms (including the Manifold Path Guiding integrator)
- Preview renders directly in Blender

## Prerequisites

- ✅ Mitsuba successfully built (as you've done with VS 2022)
- Blender 2.93 or higher (recommended: Blender 3.3 LTS or 3.6 LTS)
- Python 3.x (usually bundled with Blender)

### ⚠️ CRITICAL: Python Version Compatibility

**Your Mitsuba build MUST use the same Python version as your Blender installation!**

| Blender Version | Required Python | Action |
|-----------------|-----------------|--------|
| Blender 4.4 | Python 3.11.11 | Rebuild Mitsuba with Python 3.11 |
| Blender 4.3 | Python 3.11.9 | Rebuild Mitsuba with Python 3.11 |
| Blender 4.2 LTS | Python 3.11.7 | Rebuild Mitsuba with Python 3.11 |
| Blender 4.0-4.1 | Python 3.10.13 | Your current build should work |
| Blender 3.6 LTS | Python 3.10.13 | Your current build should work ✅ |
| Blender 3.3-3.5 | Python 3.10.x | Your current build should work ✅ |

**If you built Mitsuba with Python 3.10 but want to use Blender 4.4:**
👉 **See `PYTHON_VERSION_FIX.md` for complete rebuild instructions**

**Quick alternative:** Use **Blender 3.6 LTS** which matches your Python 3.10 build.

## Step 1: Locate Your Mitsuba Build Directory

After building with Visual Studio 2022, your Mitsuba executable and libraries are in:

```
C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba\cmake-build-release-visual-studio\dist
```

or possibly:

```
C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba\build\dist
```

**Important files to verify:**
- `mitsuba.exe` - The main Mitsuba executable
- `mitsuba.dll` or similar DLL files
- `python/` folder containing Python bindings

## Step 2: Set Up Mitsuba Environment Variables (Optional but Recommended)

Before using Mitsuba with Blender, it's helpful to set up environment variables.

### Option A: Using the Provided Script

Navigate to your Mitsuba directory and run:

```batch
cd C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba
setpath.bat
```

This adds Mitsuba to your PATH and PYTHONPATH for the current session.

### Option B: Manual Environment Setup

Add these to your Windows environment variables (System Properties → Advanced → Environment Variables):

1. Add to **PATH**:
   ```
   C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba\cmake-build-release-visual-studio\dist
   ```

2. Add to **PYTHONPATH** (or create it if it doesn't exist):
   ```
   C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba\cmake-build-release-visual-studio\dist\python
   ```

## Step 3: Download the Mitsuba-Blender Plugin

1. Visit the [mitsuba-blender releases page](https://github.com/mitsuba-renderer/mitsuba-blender/releases)

2. Download the latest **stable release** (not the "Latest" tag unless you need bleeding edge):
   - Look for a file named `mitsuba-blender.zip`
   - Example: `mitsuba-blender-v0.4.2.zip`

3. **Do NOT unzip the file** - Blender installs from the ZIP directly

## Step 4: Install the Plugin in Blender

1. **Open Blender**

2. **Go to Preferences:**
   - Click **Edit** → **Preferences** (or Blender → Preferences on macOS)

3. **Navigate to Add-ons:**
   - Click the **Add-ons** tab on the left

4. **Install the Add-on:**
   - Click the **Install...** button (top right)
   - Browse to your downloaded `mitsuba-blender.zip` file
   - Click **Install Add-on**

5. **Enable the Add-on:**
   - In the Add-ons search bar (top right), type "Mitsuba"
   - Find "**Render: Mitsuba Blender**" in the list
   - **Check the checkbox** to enable it

## Step 5: Configure the Plugin to Use Your Custom Build

This is the critical step to use your built version instead of the pip-installed version.

1. **Expand the Mitsuba-Blender add-on** by clicking the arrow/triangle next to its name

2. **Find Advanced Settings section**

3. **Enable Custom Mitsuba Path:**
   - Check the box labeled **"Use custom Mitsuba path"**

4. **Browse to your build directory:**
   - Click the folder icon to browse
   - Navigate to: `C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba\cmake-build-release-visual-studio\dist`
   - Select this folder

5. **Verify the setup:**
   - You should see a **green checkmark** or success message
   - If you see an error, double-check the path contains `mitsuba.exe`

6. **Save Preferences:**
   - Click the hamburger menu (≡) in the bottom left
   - Select **Save Preferences**

## Step 6: Restart Blender

Close and reopen Blender to ensure all changes take effect.

## Step 7: Verify the Integration

1. **Open or create a new Blender scene**

2. **Switch to Mitsuba render engine:**
   - In the top bar, find the **Render Engine** dropdown (usually shows "Eevee" or "Cycles")
   - Select **"Mitsuba"**

3. **Check render settings:**
   - Press **F12** to test render (or Render → Render Image)
   - In the **Render Properties** panel (camera icon on the right), you should see Mitsuba-specific settings

4. **Test the Manifold Path Guiding integrator:**
   - In Render Properties → Integrator
   - Look for **"MPG"** or "Manifold Path Guiding" option (if available)
   - If not visible, you may need to configure it via exported XML scenes

## Using Mitsuba with Your Scenes

### Method 1: Direct Rendering from Blender

1. Set up your scene in Blender (geometry, materials, lights, camera)
2. Configure Mitsuba settings in the Render Properties panel
3. Press **F12** to render
4. View results in the Render View

### Method 2: Export to XML and Render Manually

For more control, especially to use the Manifold Path Guiding integrator:

1. **Export scene:**
   - File → Export → Mitsuba (.xml)
   - Choose export location

2. **Edit the XML file:**
   - Open the exported `.xml` file in a text editor
   - Change the integrator to use MPG (Manifold Path Guiding):

   ```xml
   <integrator type="MPG">
       <!-- MPG-specific parameters -->
       <integer name="max_depth" value="12"/>
       <!-- Add other parameters as needed -->
   </integrator>
   ```

3. **Render from command line:**
   ```batch
   cd C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba\cmake-build-release-visual-studio\dist
   mitsuba.exe path\to\your\scene.xml
   ```

## Troubleshooting

### ⚠️ Python Version Mismatch (MOST COMMON)

**Error:**
```
The 'mitsuba' native modules could not be imported. You're likely trying to use
Mitsuba within a Python binary that is different from the one for which the
native module was compiled.
```

**Cause:** Your Mitsuba was built with a different Python version than Blender uses.

**Solution:** See **`PYTHON_VERSION_FIX.md`** for complete instructions.

**Quick fix:**
- If using Blender 4.4: Rebuild Mitsuba with Python 3.11
- Or use Blender 3.6 LTS (Python 3.10) instead

### "Failed to load Mitsuba package" Error

**Solution 1:** Make sure you checked "Use custom Mitsuba path" and pointed to the correct `dist` folder

**Solution 2:** Verify your build is complete:
- Check that `mitsuba.exe` exists in the dist folder
- Ensure the `python` subfolder exists with `.pyd` or `.so` files

**Solution 3:** Try running Mitsuba directly first:
```batch
cd C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba\cmake-build-release-visual-studio\dist
mitsuba.exe --help
```

### Blender Hangs on "Install Dependencies"

This is normal! Blender downloads packages in the background. Wait 5-10 minutes before interrupting.

However, since you're using a custom build, you should:
- **Skip** the "Install dependencies" button
- Use "Use custom Mitsuba path" instead

### Mitsuba Doesn't Appear in Render Engine Dropdown

1. Verify the add-on is enabled (checkbox is checked)
2. Restart Blender
3. Check Blender console (Window → Toggle System Console) for error messages

### Custom Integrator (MPG) Not Available in UI

The Manifold Path Guiding integrator may not be exposed in the Blender UI. Use Method 2 (XML export) to access it:

1. Export scene to XML
2. Manually edit the integrator section
3. Render with `mitsuba.exe` from command line

## Advanced: Creating a Windows Shortcut for Easy Access

Create a batch file `launch_mitsuba.bat`:

```batch
@echo off
set MITSUBA_DIR=C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba\cmake-build-release-visual-studio
set PATH=%PATH%;%MITSUBA_DIR%\dist
set PYTHONPATH=%PYTHONPATH%;%MITSUBA_DIR%\dist\python

echo Mitsuba environment configured
echo.
echo Rendering: %1
echo.

if "%1"=="" (
    echo Usage: launch_mitsuba.bat path\to\scene.xml
    pause
) else (
    %MITSUBA_DIR%\dist\mitsuba.exe %1
    pause
)
```

Then you can render scenes by dragging XML files onto this batch file!

## Additional Resources

- **Mitsuba-Blender GitHub:** https://github.com/mitsuba-renderer/mitsuba-blender
- **Installation Wiki:** https://github.com/mitsuba-renderer/mitsuba-blender/wiki/Installation-&-Update-Guide
- **Mitsuba 2 Documentation:** https://mitsuba2.readthedocs.io/
- **Manifold Path Guiding Paper:** https://zhiminfan.work/manifoldPG.html

## Next Steps

After successful integration:

1. **Test with simple scenes** first to verify everything works
2. **Explore the example scenes** in `C:\Users\josep\CLionProjects\manifold-path-guiding\scenes`
3. **Run the experiments** in the `experiments` folder to understand MPG parameters
4. **Create your own scenes** in Blender and export to Mitsuba

## Notes on Manifold Path Guiding

This build includes the **Manifold Path Guiding** integrator, which is specifically designed for:
- Scenes with complex caustics
- Multiple specular reflections/refractions
- Long specular chains

For best results with MPG:
- Use it on scenes with mirrors, glass, or other highly specular materials
- Compare with standard path tracing to see the variance reduction
- Refer to the paper for parameter tuning guidelines

---

**Need Help?** Check the Issues section of the manifold-path-guiding repository or the mitsuba-blender repository.
