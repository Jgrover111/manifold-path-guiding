# Blender Integration - Quick Start

## 5-Minute Setup

### 1. Download Mitsuba-Blender Plugin

   🔗 https://github.com/mitsuba-renderer/mitsuba-blender/releases

   Download: `mitsuba-blender.zip` (latest stable version)

### 2. Install in Blender

   ```
   Edit → Preferences → Add-ons → Install
   ```

   - Select the ZIP file
   - Search for "Mitsuba"
   - Enable the checkbox

### 3. Point to Your Build

   In the Mitsuba-Blender addon preferences:

   - ✅ Check "Use custom Mitsuba path"
   - 📁 Browse to: `C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba\cmake-build-release-visual-studio\dist`
   - ✅ Look for green checkmark

### 4. Restart Blender

### 5. Test Render

   - Switch render engine to "Mitsuba" (top bar dropdown)
   - Press **F12** to render
   - Done! 🎉

## Using Manifold Path Guiding (MPG)

The MPG integrator works best with scenes containing:
- 🪞 Mirrors
- 🔮 Glass/transparent objects
- 💎 Caustics
- ⛓️ Multiple specular bounces

### Method 1: Export to XML

```
File → Export → Mitsuba (.xml)
```

Edit the XML file and change the integrator:

```xml
<integrator type="MPG">
    <integer name="max_depth" value="12"/>
</integrator>
```

Render with:
```batch
launch_mitsuba.bat scene.xml
```

### Method 2: Use Example Scenes

Check the `scenes/` folder for ready-to-render examples with MPG configured.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Failed to load Mitsuba" | Verify the dist folder path contains `mitsuba.exe` |
| Mitsuba not in dropdown | Restart Blender after enabling addon |
| Blender hangs | Skip "Install dependencies" - use custom path instead |
| MPG not in UI | Export to XML and edit integrator manually |

## Your Build Location

Based on your CLion setup:

```
📂 C:\Users\josep\CLionProjects\manifold-path-guiding\mitsuba\cmake-build-release-visual-studio\dist
   ├── mitsuba.exe          ← Renderer executable
   ├── *.dll                ← Required libraries
   └── python/              ← Python bindings for Blender
```

## Useful Commands

**Test Mitsuba installation:**
```batch
launch_mitsuba.bat --test
```

**Render a scene:**
```batch
launch_mitsuba.bat scene.xml
```

**Get help:**
```batch
launch_mitsuba.bat --help
```

## Full Documentation

For detailed instructions, see: **`BLENDER_SETUP_GUIDE.md`**

## Resources

- 📖 [Mitsuba-Blender Plugin](https://github.com/mitsuba-renderer/mitsuba-blender)
- 📖 [Installation Wiki](https://github.com/mitsuba-renderer/mitsuba-blender/wiki/Installation-&-Update-Guide)
- 📄 [MPG Paper](https://zhiminfan.work/manifoldPG.html)
- 📚 [Mitsuba 2 Docs](https://mitsuba2.readthedocs.io/)

---

**Happy Rendering!** 🎨✨
