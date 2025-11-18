# PhotoScripts - Universal Script Management Platform

A comprehensive photo processing toolkit with a powerful macOS application for managing and automating scripts.

## 🚀 Script Hub v2.0

**Script Hub** is a modern macOS application that provides comprehensive script management, organization, and automation capabilities - similar to Apple Automator but more universal and open!

### ✨ Key Features

- 🎯 **Intelligent Script Recognition** - Auto-analyzes Java, Python, and Shell scripts
- 📁 **Script Groups** - Organize scripts with custom groups, icons, and colors
- 🔄 **Visual Workflows** - Chain scripts together like Automator to create powerful automations
- 💾 **Data Persistence** - Auto-saves everything, supports import/export
- 🚀 **Multi-Language Support** - Java, Python, Shell, extensible to more

### Quick Start

#### Option 1: Open in Xcode (Recommended) 🎯

Double-click `ScriptHub.xcodeproj` or run:
```bash
./open-xcode.sh
# Then press ⌘R to build and run
```

#### Option 2: Command Line Build

```bash
./build.sh
./.build/release/ScriptHub
```

#### Option 3: Swift Package

```bash
open Package.swift
```

📖 **Documentation**:
- [Xcode Setup Guide](XCODE.md) - How to use the Xcode project
- [Full Documentation](Documentation/README_v2.md) - Complete feature guide

## 📂 Project Structure

```
PhotoScripts/
├── ScriptHubApp/              # macOS Application (Swift)
│   ├── App/                   # Application entry point
│   ├── Models/                # Data models
│   ├── Views/                 # SwiftUI views
│   ├── Controllers/           # View models and controllers
│   ├── Services/              # Business logic
│   └── Resources/             # App resources (Info.plist, assets)
│
├── Scripts/                   # Example Scripts
│   ├── PhotoProcessing/       # Photo manipulation scripts
│   ├── FileManagement/        # File organization scripts
│   └── Utilities/             # General utilities
│
├── Build/                     # Build output
│   └── Classes/               # Compiled Java classes
│
├── Documentation/             # Project documentation
├── Archived/                  # Legacy code and old versions
│
├── ScriptHub.xcodeproj/       # Xcode Project (double-click to open!)
├── Package.swift              # Swift Package definition
├── build.sh                   # Build script
├── open-xcode.sh              # Open in Xcode helper
├── XCODE.md                   # Xcode setup guide
└── README.md                  # This file
```

## 🛠️ Included Scripts

### Photo Processing

**Date Modifier** - Synchronizes file modification dates with creation dates
```bash
java -cp Build/Classes DateModifier "*" true /path/to/photos
```

**PNG to JPEG Converter** - Batch converts PNG images to JPEG
```bash
java -cp Build/Classes PngToJpegConverter reserve cascade /path/to/images
```

**Wallpaper Picker** - Extracts landscape-oriented images
```bash
java -cp Build/Classes WallpaperPicker reserve cascade /output /input
```

**Wallpaper Picker (Metadata)** - Uses EXIF metadata for accurate detection
```bash
java -cp Build/Classes WallpaperPickerMetadata reserve cascade null /input
```

### File Management

**File Grouper** - Partitions files into groups of specified sizes
```bash
java -cp Build/Classes FileGrouper 200 true /path/to/files
```

**Batch Zip** - Batch compress subdirectories with 7zip
```bash
java -cp Build/Classes BatchZip /usr/local/bin/7z /path/to/dirs
```

## 🎯 Using Script Hub

### 1. Import Scripts

**Scan Directory:**
1. Open "Management" tab
2. Click + → "Scan Directory"
3. Select folder containing scripts
4. Review detected scripts and import

**Import Files:**
1. Open "Management" tab
2. Click + → "Import Script Files"
3. Select one or more script files
4. Import

### 2. Organize with Groups

1. Navigate to "Scripts" tab
2. Click + in left sidebar to create group
3. Set name, icon, and color
4. Right-click scripts to add to groups

### 3. Create Workflows

1. Switch to "Workflows" tab
2. Click + to create new workflow
3. Add script nodes from your library
4. Configure parameter mappings
5. Run workflow and watch automation in action

### Example Workflow

```
Photo Processing Pipeline:

DateModifier → PngToJpegConverter → WallpaperPicker → BatchZip

Result: Automatically fixes dates, converts formats, filters images, and archives
```

## 🏗️ Architecture

### MVC Pattern

The application follows Model-View-Controller architecture:

**Models** - Data structures (Script, Workflow, ScriptGroup)
**Views** - SwiftUI interfaces (NewContentView, WorkflowEditorView, etc.)
**Controllers** - State management (DataStore)
**Services** - Business logic (ScriptScanner, ScriptExecutor, WorkflowExecutor)

See [ScriptHubApp/README.md](ScriptHubApp/README.md) for detailed architecture documentation.

## 🔧 Development

### Building

#### Using Xcode (Recommended)

```bash
# Open the Xcode project
./open-xcode.sh

# Or double-click ScriptHub.xcodeproj in Finder
# Then press ⌘R to build and run
```

See [XCODE.md](XCODE.md) for complete Xcode setup instructions.

#### Using Command Line

```bash
# Build and compile scripts
./build.sh

# Run application
./.build/release/ScriptHub
```

#### Using Swift Package

```bash
# Open as Swift Package
open Package.swift

# Build from command line
swift build -c release
```

### Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Java JDK 18+ (for Java scripts)
- Python 3.x (for Python scripts)

### Adding New Scripts

Script Hub automatically detects scripts with:
- **Java**: Public main method, command-line args
- **Python**: argparse or sys.argv
- **Shell**: Positional parameters ($1, $2, ...)

Just place your script in `Scripts/` and scan!

### Working with Xcode

The project includes a native **ScriptHub.xcodeproj** file ready to use:

```bash
# Open in Xcode
./open-xcode.sh

# Or double-click ScriptHub.xcodeproj in Finder
```

**First-time setup:**
1. Select your development team in Signing & Capabilities
2. Press ⌘R to build and run
3. See [XCODE.md](XCODE.md) for detailed instructions

**Alternative:** You can also use `open Package.swift` to work with the Swift Package directly.

## 📚 Documentation

- **[Xcode Setup Guide](XCODE.md)** - Complete guide to using Xcode with this project
- [Full v2.0 Documentation](Documentation/README_v2.md) - All features explained
- [Quick Start Guide](Documentation/QUICKSTART.md) - Get started quickly
- [App Architecture](ScriptHubApp/README.md) - MVC architecture details

## 🎨 Script Hub Features

### Intelligent Script Recognition
- Automatically detects entry points
- Extracts parameter definitions
- Infers parameter types
- Reads descriptions from comments

### Script Management
- Add, edit, delete scripts via GUI
- Import files or scan directories
- Duplicate scripts
- Export/import configurations

### Visual Workflow Editor
- Drag-and-drop script nodes
- Visual connection display
- Parameter mapping system
- Topological execution ordering
- Real-time output from each node

### Data Persistence
- Auto-saves all configurations
- Import/export JSON
- Workflow versioning

## 🗺️ Migration from v1.0

If you're upgrading from v1.0:

1. Old `src/` scripts → Now in `Scripts/PhotoProcessing/` and `Scripts/FileManagement/`
2. Old `out/production/Scripts/` → Now in `Build/Classes/`
3. Old config location supported for backward compatibility
4. Run `./build.sh` to compile scripts in new location

## 🚀 Future Plans

- [ ] Visual node connections (drag-to-connect)
- [ ] Conditional branching (if/else)
- [ ] Loop execution (for/while)
- [ ] Variable system
- [ ] Script marketplace
- [ ] Remote execution
- [ ] Scheduled tasks
- [ ] Git integration
- [ ] More language support (Ruby, Go, Rust)
- [ ] Performance profiling

## 📄 License

Open source - feel free to use and modify!

## 🙏 Acknowledgments

- Inspired by Apple Automator
- Built with Swift and SwiftUI
- Thanks to all contributors!

---

**Script Hub - Make script management simple, automation powerful!** 🚀
