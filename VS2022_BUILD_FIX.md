# Visual Studio 2022 Build Fix for Mitsuba

## Problem

When building with Visual Studio 2022 and the v142 (VS 2019) toolset, you encounter this error:

```
error C2065: 'ssize_t': undeclared identifier
error C2338: ssize_t != Py_intptr_t
```

in `pybind11/include/pybind11/numpy.h`

## Root Cause

This project uses an older version of pybind11 (pre-2.9.1) that does not properly support the Visual Studio 2022 C++ standard library (`_MSVC_STL_VERSION >= 143`). The fix for VS 2022 was merged in [pybind11 PR #3497](https://github.com/pybind/pybind11/pull/3497) and released in version 2.9.1 (February 2022).

## Solution Options

### Option 1: Update pybind11 Submodule (Recommended)

Update the pybind11 submodule to version 2.9.1 or later:

```bash
cd mitsuba/ext/pybind11
git fetch --all
git checkout v2.11.1  # or latest stable version
cd ../../..
git add mitsuba/ext/pybind11
git commit -m "Update pybind11 to v2.11.1 for VS 2022 support"
```

### Option 2: CMake Workaround

If you cannot update pybind11, add this workaround to your CMake configuration.

Create a file `mitsuba/cmake/vs2022_fix.cmake` with:

```cmake
# Workaround for pybind11 ssize_t issue with Visual Studio 2022
if(MSVC AND MSVC_VERSION GREATER_EQUAL 1930)
    # VS 2022 or later
    add_compile_definitions(
        HAVE_SSIZE_T=1
        ssize_t=intptr_t
    )
    message(STATUS "Applied VS 2022 ssize_t workaround for pybind11")
endif()
```

Then add this line to `mitsuba/CMakeLists.txt` after line 120:

```cmake
# Include VS 2022 fix if needed
if(MSVC AND MSVC_VERSION GREATER_EQUAL 1930)
    include(cmake/vs2022_fix.cmake)
endif()
```

### Option 3: Manual Header Patch

Create a wrapper header that defines `ssize_t` before including pybind11.

Create file `mitsuba/include/mitsuba/python/python_compat.h`:

```cpp
#pragma once

// Fix for pybind11 with MSVC 2022
#if defined(_MSC_VER) && _MSC_VER >= 1930
    #include <yvals.h>
    #if defined(_MSVC_STL_VERSION) && _MSVC_STL_VERSION >= 143
        #include <crtdefs.h>
        // Ensure ssize_t is defined
        #ifndef _SSIZE_T_DEFINED
            #define _SSIZE_T_DEFINED
            typedef intptr_t ssize_t;
        #endif
    #endif
#endif

// Now safe to include pybind11
#include <pybind11/pybind11.h>
```

Then update all files that include pybind11 to include this header instead.

### Option 4: Use Native VS 2022 Generator (Quick Test)

The project documentation specifies VS 2019, but you could try using VS 2022 natively:

```bash
cmake -G "Visual Studio 17 2022" -A x64 -T v143
```

This uses the VS 2022 toolset (v143) instead of v142, which might have better compatibility.

## Recommended Approach

**For immediate fix:** Use Option 1 (update pybind11 submodule)

**For long-term:** After updating pybind11, also update the documentation in `mitsuba/docs/src/getting_started/compiling.rst` to indicate VS 2022 is supported.

## Verification

After applying any fix, clean your build directory and reconfigure:

```bash
# In CLion: File > Invalidate Caches / Restart
# Or manually:
cd cmake-build-release-visual-studio
rm -rf *
cmake -G "Visual Studio 17 2022" -A x64 -T v142 ..
cmake --build . --config Release
```

## Additional Notes

- The v142 toolset (VS 2019 compiler) running under VS 2022 still uses the VS 2022 C++ standard library headers, which is why this issue occurs
- pybind11 versions 2.9.1+ properly detect `_MSVC_STL_VERSION` instead of just compiler version
- If you continue to have issues, ensure Python 3.6+ is properly detected by CMake

## References

- [pybind11 PR #3497: VS 2022 compilation fix](https://github.com/pybind/pybind11/pull/3497)
- [pybind11 Changelog](https://pybind11.readthedocs.io/en/stable/changelog.html)
