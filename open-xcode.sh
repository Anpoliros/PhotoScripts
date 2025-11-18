#!/bin/bash

# Script Hub - Open in Xcode
# Opens the project in Xcode

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Opening Script Hub in Xcode..."
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or xcodebuild is not in PATH"
    echo ""
    echo "Please install Xcode from the Mac App Store:"
    echo "https://apps.apple.com/app/xcode/id497799835"
    exit 1
fi

# Check if .xcodeproj exists
if [ ! -d "$SCRIPT_DIR/ScriptHub.xcodeproj" ]; then
    echo "❌ Error: ScriptHub.xcodeproj not found"
    echo ""
    echo "The Xcode project file is missing. Please regenerate it."
    exit 1
fi

# Open in Xcode
open "$SCRIPT_DIR/ScriptHub.xcodeproj"

echo "✅ Xcode project opened!"
echo ""
echo "📝 Tips:"
echo "  • Press ⌘R to build and run"
echo "  • Select 'ScriptHub' scheme from the top bar"
echo "  • Set your development team in Signing & Capabilities"
echo ""
