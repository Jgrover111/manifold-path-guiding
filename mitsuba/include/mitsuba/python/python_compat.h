#pragma once

/**
 * Python compatibility header for Visual Studio 2022
 *
 * This header works around ssize_t definition issues with older versions of
 * pybind11 (< 2.9.1) when compiling with Visual Studio 2022's C++ standard library.
 *
 * Usage: Include this header instead of <pybind11/pybind11.h> in your Python binding code.
 *
 * Background:
 * - VS 2022 changed how ssize_t is handled in the standard library
 * - Older pybind11 versions check _MSC_VER instead of _MSVC_STL_VERSION
 * - This causes ssize_t to be undefined when including pybind11/numpy.h
 *
 * Solution:
 * - This header ensures ssize_t is properly defined before including pybind11
 * - For long-term fix, update pybind11 to version 2.9.1 or later
 *
 * Reference: https://github.com/pybind/pybind11/pull/3497
 */

// Fix for pybind11 with MSVC 2022
#if defined(_MSC_VER) && _MSC_VER >= 1930
    // Include yvals.h to get _MSVC_STL_VERSION
    #include <yvals.h>

    // Check if we're using VS 2022's standard library
    #if defined(_MSVC_STL_VERSION) && _MSVC_STL_VERSION >= 143
        #include <crtdefs.h>

        // Ensure ssize_t is defined for pybind11
        // VS 2022's STL expects this to be defined
        #ifndef _SSIZE_T_DEFINED
            #define _SSIZE_T_DEFINED
            typedef intptr_t ssize_t;
        #endif

        // Also ensure Py_ssize_t compatibility
        #ifndef PY_SSIZE_T_CLEAN
            #define PY_SSIZE_T_CLEAN
        #endif
    #endif
#endif

// Now it's safe to include Python and pybind11 headers
#include <Python.h>
#include <pybind11/pybind11.h>
