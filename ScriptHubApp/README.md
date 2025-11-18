# Script Hub - macOS Application

A modern macOS application for managing and automating scripts, built with Swift and SwiftUI.

## Project Structure

```
ScriptHubApp/
├── App/                    # Application entry point
│   └── ScriptHubApp.swift
├── Models/                 # Data models
│   └── Models.swift
├── Views/                  # SwiftUI views
│   ├── NewContentView.swift
│   ├── ScriptDetailView.swift
│   ├── ScriptManagementView.swift
│   ├── WorkflowEditorView.swift
│   └── ContentView.swift
├── Controllers/            # View models and controllers
│   └── DataStore.swift
├── Services/              # Business logic services
│   ├── ScriptScanner.swift
│   ├── ScriptExecutor.swift
│   ├── WorkflowExecutor.swift
│   └── ConfigLoader.swift
├── Resources/             # Application resources
│   └── Info.plist
└── Supporting Files/      # Additional support files
```

## Architecture

### MVC Pattern

The application follows the Model-View-Controller pattern:

**Models** (`Models/`)
- Data structures and business entities
- `Script`, `ScriptGroup`, `Workflow`, `WorkflowNode`
- Pure Swift structs and enums

**Views** (`Views/`)
- SwiftUI view components
- User interface layouts
- Presentation logic only

**Controllers** (`Controllers/`)
- `DataStore` - Manages application state
- Coordinates between models and views
- Handles user interactions

**Services** (`Services/`)
- Business logic layer
- Script scanning, execution, workflow management
- Independent, reusable components

## Building

### Command Line
```bash
swift build -c release
./.build/release/ScriptHub
```

### Xcode
```bash
open Package.swift
```

Then press ⌘R to build and run.

### Creating Xcode Project

To create a full `.xcodeproj` file:

1. Open Terminal in project directory
2. Run: `swift package generate-xcodeproj`
3. Open the generated `.xcodeproj` file

Or use Xcode directly:
1. File → Open
2. Select `Package.swift`
3. Xcode will automatically create the project

## Development

### Adding New Views

1. Create new Swift file in `Views/`
2. Import SwiftUI
3. Add to the view hierarchy in `NewContentView.swift`

### Adding New Models

1. Create new struct/class in `Models/Models.swift`
2. Make it `Codable` if it needs persistence
3. Update `DataStore` if needed

### Adding New Services

1. Create new Swift file in `Services/`
2. Implement the service logic
3. Use from Controllers or Views

## Code Organization

### Naming Conventions

- **Files**: PascalCase (e.g., `ScriptScanner.swift`)
- **Types**: PascalCase (e.g., `struct Script`, `class DataStore`)
- **Variables**: camelCase (e.g., `scriptPath`, `isRunning`)
- **Constants**: camelCase (e.g., `let maxRetries = 3`)

### File Headers

Each file should have a header comment:
```swift
//
//  FileName.swift
//  ScriptHub
//
//  Brief description of what this file does
//

import Foundation
```

### MARK Comments

Use MARK comments to organize code:
```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
```

## Testing

Run tests with:
```bash
swift test
```

## Deployment

To create a distributable app:

1. Open in Xcode
2. Product → Archive
3. Distribute App → Copy App
4. Copy to `/Applications`

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9 or later

## License

Same as PhotoScripts project.
