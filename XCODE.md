# Opening Script Hub in Xcode

This project includes a native Xcode project file that you can open directly in Xcode.

## Quick Start

### Method 1: Double-Click (Easiest)

Simply double-click `ScriptHub.xcodeproj` in Finder, and it will open in Xcode.

### Method 2: Use the Script

```bash
./open-xcode.sh
```

### Method 3: Command Line

```bash
open ScriptHub.xcodeproj
```

### Method 4: From Xcode

1. Open Xcode
2. File → Open
3. Navigate to the project folder
4. Select `ScriptHub.xcodeproj`
5. Click "Open"

## First-Time Setup

When you first open the project in Xcode:

### 1. Select Your Development Team

1. Click on the project in the navigator (blue ScriptHub icon)
2. Select the "ScriptHub" target
3. Go to "Signing & Capabilities" tab
4. Under "Team", select your Apple Developer account
   - If you don't have one, select "Add an Account..."
   - Or choose "Sign to Run Locally" for personal use

### 2. Select a Scheme

Make sure "ScriptHub" is selected in the scheme dropdown at the top of Xcode (next to the play/stop buttons).

### 3. Build and Run

Press `⌘R` or click the Play button to build and run the app.

## Project Structure in Xcode

```
ScriptHub
├── App
│   └── ScriptHubApp.swift          # Application entry point
├── Models
│   └── Models.swift                # Data models
├── Views
│   ├── NewContentView.swift        # Main tabbed interface
│   ├── ScriptDetailView.swift      # Script details and execution
│   ├── ScriptManagementView.swift  # Script management
│   ├── WorkflowEditorView.swift    # Workflow editor
│   └── ContentView.swift           # Legacy view
├── Controllers
│   └── DataStore.swift             # State management
├── Services
│   ├── ScriptScanner.swift         # Script auto-detection
│   ├── ScriptExecutor.swift        # Script execution
│   ├── WorkflowExecutor.swift      # Workflow execution
│   └── ConfigLoader.swift          # Configuration loading
└── Resources
    └── Info.plist                  # App metadata
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘R | Build and run |
| ⌘B | Build only |
| ⌘. | Stop running |
| ⌘K | Clean build folder |
| ⌘⇧K | Clean build folder (with confirmation) |
| ⌘1-9 | Navigate between panels |
| ⌘0 | Show/hide navigator |
| ⌘⌥0 | Show/hide inspector |

## Building for Distribution

### Debug Build (for development)

```bash
# Build from command line
xcodebuild -project ScriptHub.xcodeproj -scheme ScriptHub -configuration Debug
```

### Release Build (optimized)

```bash
# Build from command line
xcodebuild -project ScriptHub.xcodeproj -scheme ScriptHub -configuration Release
```

### Creating an Archive (for distribution)

1. In Xcode, select Product → Archive
2. When the build completes, the Organizer will open
3. Click "Distribute App"
4. Choose distribution method:
   - **Development**: For personal use or testing
   - **App Store**: For App Store submission
   - **Developer ID**: For distribution outside App Store
   - **Copy App**: Create a standalone .app file

## Build Settings

The project is configured with:

- **Deployment Target**: macOS 13.0 (Ventura)
- **Swift Version**: 5.0
- **Architecture**: Universal (Apple Silicon + Intel)
- **Hardened Runtime**: Enabled
- **SwiftUI Previews**: Enabled

## Troubleshooting

### "ScriptHub.xcodeproj cannot be opened"

Make sure you're on macOS and have Xcode installed:
```bash
xcode-select --install
```

### Build Errors

1. Clean the build folder: `⌘⇧K`
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/ScriptHub-*
   ```
3. Restart Xcode

### Code Signing Issues

If you see signing errors:

1. Go to Signing & Capabilities
2. Enable "Automatically manage signing"
3. Select your team
4. Or disable signing for local development:
   - Set "Code Signing Identity" to "Sign to Run Locally"

### Swift Version Mismatch

If you see Swift version errors, the project requires:
- Xcode 15.0 or later
- Swift 5.9 or later

Update Xcode from the Mac App Store if needed.

## Working with the Code

### Adding New Files

1. Right-click on the appropriate group (App/Models/Views/Controllers/Services)
2. Select "New File..."
3. Choose "Swift File"
4. Add your code
5. The file will automatically be added to the target

### SwiftUI Previews

Most views have preview code at the bottom:

```swift
#Preview {
    NewContentView()
}
```

Click "Resume" in the canvas to see live previews while coding.

### Debugging

1. Set breakpoints by clicking the line number gutter
2. Run with `⌘R`
3. Use the debug console at the bottom
4. Inspect variables in the Variables View

## Integration with Build System

The Xcode project works alongside the command-line build system:

```bash
# Build with command line
./build.sh

# Run the built app
./.build/release/ScriptHub

# Or build and run in Xcode with ⌘R
```

Both methods produce working applications!

## Additional Resources

- [Xcode Documentation](https://developer.apple.com/documentation/xcode)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [App Distribution Guide](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

## Support

For issues with the Xcode project:

1. Make sure you're using Xcode 15.0+
2. Try cleaning and rebuilding
3. Check the build logs for specific errors
4. Verify your team/signing settings

---

Happy coding! 🚀
