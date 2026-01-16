# Apply VS 2022 Fix to Mitsuba Build
#
# This file can be included in the main CMakeLists.txt to automatically apply
# the VS 2022 compatibility fix when building with Visual Studio 2022.
#
# To use this fix, add the following line to mitsuba/CMakeLists.txt after
# line 120 (after the include(CheckCXXSourceRuns) line):
#
#   include(cmake/apply_vs2022_fix.cmake)
#

if(MSVC)
    message(STATUS "Checking Visual Studio version...")
    message(STATUS "  MSVC_VERSION: ${MSVC_VERSION}")

    if(MSVC_VERSION GREATER_EQUAL 1930)
        # Visual Studio 2022 or later
        message(STATUS "")
        message(STATUS "**********************************************************************")
        message(STATUS "* Detected Visual Studio 2022 (MSVC ${MSVC_VERSION})")
        message(STATUS "* Applying compatibility fix for pybind11 ssize_t issue")
        message(STATUS "**********************************************************************")
        message(STATUS "")

        # Include the VS 2022 specific fixes
        include(${CMAKE_CURRENT_LIST_DIR}/vs2022_fix.cmake)

        # Also add the python compatibility header to the include path
        include_directories(BEFORE ${CMAKE_CURRENT_SOURCE_DIR}/include/mitsuba/python)

    elseif(MSVC_VERSION GREATER_EQUAL 1920)
        # Visual Studio 2019
        message(STATUS "  Detected Visual Studio 2019 - no additional fixes needed")
    else()
        message(STATUS "  Detected older Visual Studio version")
    endif()
endif()
