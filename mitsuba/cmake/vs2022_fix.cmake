# Workaround for pybind11 ssize_t issue with Visual Studio 2022
# This fix is needed for older versions of pybind11 (< 2.9.1) that don't properly
# support the Visual Studio 2022 C++ standard library.
#
# The issue: VS 2022's standard library (_MSVC_STL_VERSION >= 143) changed how
# ssize_t is defined, causing compilation errors in pybind11's numpy.h
#
# Reference: https://github.com/pybind/pybind11/pull/3497

if(MSVC AND MSVC_VERSION GREATER_EQUAL 1930)
    # VS 2022 or later (MSVC_VERSION 1930+)
    message(STATUS "Detected Visual Studio 2022 or later")
    message(STATUS "Applying pybind11 ssize_t workaround for older pybind11 versions")

    # Add compile definitions to ensure ssize_t is properly defined
    add_compile_definitions(
        HAVE_SSIZE_T=1
    )

    # Note: This is a temporary workaround. The proper solution is to update
    # pybind11 to version 2.9.1 or later, which includes native VS 2022 support.
    message(STATUS "  Note: Consider updating pybind11 to v2.9.1+ for native VS 2022 support")
endif()
