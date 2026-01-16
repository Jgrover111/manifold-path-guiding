#!/bin/bash
# Script to update pybind11 submodule to a version with VS 2022 support
#
# This script updates the pybind11 submodule to version 2.11.1 (or later),
# which includes native support for Visual Studio 2022.
#
# Usage: ./update_pybind11.sh [version]
#   If no version is specified, defaults to v2.11.1

set -e

PYBIND11_VERSION="${1:-v2.11.1}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PYBIND11_DIR="${SCRIPT_DIR}/mitsuba/ext/pybind11"

echo "=========================================="
echo "Updating pybind11 to ${PYBIND11_VERSION}"
echo "=========================================="
echo ""

# Check if the submodule directory exists
if [ ! -d "${PYBIND11_DIR}" ]; then
    echo "Error: pybind11 directory not found at ${PYBIND11_DIR}"
    echo "You may need to initialize submodules first:"
    echo "  cd mitsuba && git submodule update --init --recursive"
    exit 1
fi

# Navigate to pybind11 directory
cd "${PYBIND11_DIR}"

echo "Current pybind11 location: $(pwd)"
echo ""

# Fetch latest tags
echo "Fetching latest pybind11 versions..."
git fetch --all --tags
echo ""

# Check if the requested version exists
if ! git rev-parse "${PYBIND11_VERSION}" >/dev/null 2>&1; then
    echo "Warning: Version ${PYBIND11_VERSION} not found!"
    echo "Available recent versions:"
    git tag | grep "^v2\." | tail -10
    exit 1
fi

# Checkout the requested version
echo "Checking out pybind11 ${PYBIND11_VERSION}..."
git checkout "${PYBIND11_VERSION}"
echo ""

# Show the current version
CURRENT_COMMIT=$(git rev-parse HEAD)
echo "Successfully updated to:"
echo "  Version: ${PYBIND11_VERSION}"
echo "  Commit: ${CURRENT_COMMIT}"
echo ""

# Go back to repository root
cd "${SCRIPT_DIR}"

# Check git status
echo "Git status:"
git status mitsuba/ext/pybind11
echo ""

echo "=========================================="
echo "Update complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff mitsuba/ext/pybind11"
echo "  2. Test the build with Visual Studio 2022"
echo "  3. Commit the change: git add mitsuba/ext/pybind11"
echo "     git commit -m 'Update pybind11 to ${PYBIND11_VERSION} for VS 2022 support'"
echo ""
