# CLion Setup Guide for Manifold Path Guiding

This guide will help you set up and build the Manifold Path Guiding project in CLion.

## Prerequisites

The following tools are already installed and verified:
- **Python 3.11.14** at `/usr/local/bin/python3`
- **CMake 3.28.3**
- **g++ 13.3.0** (Ubuntu)

## Project Overview

This project implements Manifold Path Guiding, a rendering technique for importance sampling specular chains in Monte Carlo rendering. It's built on top of Mitsuba 2, a research-oriented rendering system.

- **Main integrator code**: `mitsuba/src/integrators/MPG/`
- **Build system**: CMake
- **Language**: C++17

## Setup Steps

### 1. Initial Setup (Already Completed)

The following setup steps have already been completed:

1. ✅ Repository cloned
2. ✅ `ext.zip` extracted to `mitsuba/ext/` (external dependencies)
3. ✅ `mitsuba.conf` created from template (configures build variants)
4. ✅ Build directory created and CMake configured

### 2. Open Project in CLion

#### Method 1: Open as CMake Project (Recommended)

1. Launch CLion
2. Click **File → Open**
3. Navigate to `/home/user/manifold-path-guiding/mitsuba`
4. Select the `CMakeLists.txt` file and click **OK**
5. When prompted, choose **Open as Project**

CLion will automatically detect the CMake configuration and use the existing build directory.

#### Method 2: Import from Existing Build

1. Launch CLion
2. Click **File → Open**
3. Navigate to `/home/user/manifold-path-guiding/mitsuba`
4. Open the folder

### 3. Configure CLion CMake Settings

Once the project is open:

1. Go to **File → Settings → Build, Execution, Deployment → CMake**
2. You should see a **Release** profile (or create one if it doesn't exist)
3. Verify/set the following:
   - **Build type**: `Release`
   - **Build directory**: `build` (relative path)
   - **CMake options**: `-DCMAKE_BUILD_TYPE=Release`
   - **Build options**: `-j$(nproc)` (for parallel builds)

### 4. Configure Toolchain

1. Go to **File → Settings → Build, Execution, Deployment → Toolchains**
2. Ensure the default toolchain uses:
   - **CMake**: `/usr/bin/cmake` (version 3.28.3)
   - **C Compiler**: `/usr/bin/gcc`
   - **C++ Compiler**: `/usr/bin/g++`

### 5. Build the Project

#### Full Build

1. Click **Build → Build Project** (or press Ctrl+F9)
2. The first build will take significant time (10-30 minutes depending on your system)
3. Build output will appear in the **Build** tab at the bottom

#### Build Specific Targets

CLion will show available CMake targets in the build configuration dropdown (top-right):
- **ALL_BUILD** - Builds everything (default)
- **mitsuba** - Main Mitsuba executable
- **MPG** - The Manifold Path Guiding integrator plugin
- Various other plugins and libraries

You can select specific targets from the dropdown and build them individually.

### 6. Build from Terminal (Alternative)

If you prefer to build from the command line:

```bash
cd /home/user/manifold-path-guiding/mitsuba/build
make -j$(nproc)
```

For Release mode with maximum optimization:
```bash
cmake --build . --config Release -j$(nproc)
```

## Mitsuba Configuration

The build is configured via `mitsuba/mitsuba.conf`. Currently enabled variants:
- **scalar_rgb**: CPU-based RGB rendering (required)
- **scalar_spectral**: CPU-based spectral rendering (default)

You can modify this configuration to enable other variants like:
- `packet_rgb` - Vectorized SIMD rendering
- `gpu_rgb` - GPU-based rendering (requires CUDA/OptiX)

After modifying `mitsuba.conf`, re-run CMake configuration in CLion.

## Running Mitsuba

### From CLion

1. After building, you can create a **Run Configuration**:
   - Go to **Run → Edit Configurations**
   - Click **+** → **CMake Application**
   - Select the **mitsuba** target
   - Set **Program arguments** as needed (e.g., path to scene file)
   - Click **OK**

2. Run with **Run → Run** (Shift+F10)

### From Terminal

The built executable will be in:
```bash
/home/user/manifold-path-guiding/mitsuba/build/dist/mitsuba
```

You can run experiments using the Python scripts in the `experiments/` folder:
```bash
cd /home/user/manifold-path-guiding/experiments
python fig07_plane.py  # Example experiment
```

## Useful CLion Features

### Code Navigation
- **Ctrl+Click** or **Ctrl+B** - Go to definition
- **Ctrl+Alt+B** - Go to implementation
- **Alt+F7** - Find usages
- **Ctrl+Shift+F** - Find in files

### Debugging
1. Set breakpoints by clicking in the gutter next to line numbers
2. Select **Debug** instead of **Run** (Shift+F9)
3. Use the Debug panel to step through code, inspect variables, etc.

### CMake Integration
- **Tools → CMake → Reload CMake Project** - Refresh after config changes
- **Tools → CMake → Reset Cache and Reload Project** - Full CMake rebuild

## Project Structure

```
manifold-path-guiding/
├── mitsuba/                    # Mitsuba 2 renderer
│   ├── src/
│   │   ├── integrators/
│   │   │   └── MPG/           # ⭐ Main Manifold Path Guiding code
│   │   ├── bsdfs/             # Material models
│   │   ├── emitters/          # Light sources
│   │   ├── shapes/            # Geometric shapes
│   │   └── ...
│   ├── include/               # Header files
│   ├── ext/                   # External dependencies
│   ├── build/                 # Build output directory
│   └── mitsuba.conf          # Build configuration
└── experiments/               # Test scenes and scripts
    ├── fig07_plane.py
    ├── fig08_living.py
    └── ...
```

## Troubleshooting

### CMake fails to configure
- Ensure all dependencies are properly extracted from `ext.zip`
- Check that Python 3.x is found correctly
- Try deleting the `build/` directory and re-running CMake

### Build errors
- Make sure you're building in **Release** mode (Debug builds may have issues)
- Check that you have enough disk space (~5-10 GB for full build)
- Try building with fewer parallel jobs: `make -j4` instead of `make -j$(nproc)`

### Python import errors
- Ensure the Python bindings are built (they should be by default)
- Source the environment setup script:
  ```bash
  source /home/user/manifold-path-guiding/mitsuba/setpath.sh
  ```

## Additional Resources

- **Project Page**: https://zhiminfan.work/manifoldPG.html
- **Paper**: https://zhiminfan.work/paper/ManifoldPG_Sept28.pdf
- **Mitsuba 2 Documentation**: https://mitsuba2.readthedocs.io/en/latest/
- **Original Project**: https://github.com/tizian/specular-manifold-sampling (SMS)

## Next Steps

1. Build the project in CLion
2. Explore the MPG integrator code in `mitsuba/src/integrators/MPG/`
3. Run the example experiments in the `experiments/` folder
4. Read the paper to understand the algorithm
5. Modify and experiment with the implementation

---

**Note**: The first build will take considerable time as it compiles all of Mitsuba 2 and its dependencies. Subsequent incremental builds will be much faster.
