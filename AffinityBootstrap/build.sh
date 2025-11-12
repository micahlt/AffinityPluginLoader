#!/bin/bash
# Build script for AffinityBootstrap native DLL
# Requires MinGW-w64 cross-compiler

set -e

echo "Building AffinityBootstrap.dll for Wine..."

# Check if MinGW is installed
if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    echo "Error: MinGW-w64 not found"
    echo "Install with:"
    echo "  Ubuntu/Debian: sudo apt install gcc-mingw-w64-x86-64"
    echo "  Arch: sudo pacman -S mingw-w64-gcc"
    echo "  Fedora: sudo dnf install mingw64-gcc"
    exit 1
fi

# Compile
x86_64-w64-mingw32-gcc \
    -shared \
    -o AffinityBootstrap.dll \
    bootstrap.c \
    -lole32 \
    -loleaut32 \
    -luuid \
    -static-libgcc \
    -Wl,--subsystem,windows

echo "Build successful: AffinityBootstrap.dll"
echo ""
echo "Copy this file to your Affinity installation directory alongside AffinityPluginLoader.dll"
