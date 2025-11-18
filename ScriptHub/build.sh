#!/bin/bash

# Script Hub - Build Script
# This script builds the macOS application

set -e

echo "🔨 Building Script Hub..."

# Navigate to script directory
cd "$(dirname "$0")"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build

# Build release version
echo "📦 Building release version..."
swift build -c release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "To run the app:"
    echo "  ./.build/release/ScriptHub"
    echo ""
    echo "Or open in Xcode:"
    echo "  open Package.swift"
else
    echo "❌ Build failed!"
    exit 1
fi
