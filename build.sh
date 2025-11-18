#!/bin/bash

# Script Hub - Build Script
# Builds the macOS application and compiles example scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔨 Building Script Hub..."
echo ""

# Create build directories
echo "📁 Creating build directories..."
mkdir -p Build/Classes
mkdir -p Build/Release

# Compile Java example scripts if they exist
if [ -d "Scripts/PhotoProcessing" ]; then
    echo "☕ Compiling Java scripts..."
    for java_file in Scripts/PhotoProcessing/*.java; do
        if [ -f "$java_file" ]; then
            filename=$(basename "$java_file")
            echo "  Compiling $filename..."
            javac -d Build/Classes "$java_file" 2>&1 || echo "    ⚠️  Warning: Failed to compile $filename"
        fi
    done
    echo "✅ Java scripts compiled"
    echo ""
fi

# Legacy support: compile from src if it exists
if [ -d "src" ] && [ ! -z "$(ls -A src/*.java 2>/dev/null)" ]; then
    echo "☕ Compiling legacy Java scripts from src/..."
    mkdir -p out/production/Scripts
    for java_file in src/*.java; do
        if [ -f "$java_file" ]; then
            filename=$(basename "$java_file")
            echo "  Compiling $filename..."
            javac -d out/production/Scripts "$java_file" 2>&1 || echo "    ⚠️  Warning: Failed to compile $filename"
        fi
    done
    echo "✅ Legacy scripts compiled"
    echo ""
fi

# Build Swift application
echo "🔷 Building Swift application..."
swift build -c release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📦 Application built at: .build/release/ScriptHub"
    echo ""
    echo "To run the application:"
    echo "  ./.build/release/ScriptHub"
    echo ""
    echo "To open in Xcode:"
    echo "  open Package.swift"
    echo ""
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi
