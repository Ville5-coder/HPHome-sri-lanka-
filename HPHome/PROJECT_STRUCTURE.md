# HPHome - Project Structure Reference

## Folder Structure
```
HPHome/
├── App/                    # App entry point (HPHomeApp.swift)
├── Models/                 # Data models (@Model, Codable, Identifiable)
├── ViewModels/            # Business logic (ObservableObject classes)
├── Views/                 # SwiftUI views
├── Services/              # Data management (SwiftData/CoreData)
├── Utilities/             # Helpers & extensions
└── Resources/             # Assets, JSON files (exercises.json)
```

## Minimum Required Files
- `HPHomeApp.swift` - App entry point
- `ContentView.swift` - Main view
- `exercises.json` - Sample data (in Resources/)

## Data Models
- Use `@Model` macro for SwiftData
- Conform to `Codable` for JSON parsing
- Conform to `Identifiable` for SwiftUI lists

## Assets Configuration
In `Assets.xcassets`, create:
- AppIcon (1024x1024 required)
- Color Sets (for theme colors)
- Image Sets (for icons if needed)

## Capabilities
- None required for MVP
- Future: iCloud, Push Notifications (when adding backend)

## Info.plist
- No special permissions needed for MVP
- Default settings are fine

## Git Ignore (if using Git)
```
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
*.xcworkspace/*
!*.xcworkspace/xcshareddata/
DerivedData/
*.xcuserstate
.DS_Store

# SwiftPM
.build/
Packages/
*.swiftpm
```

## Development Workflow
1. Create project + folder structure
2. Set up data models
3. Create data manager/service layer
4. Build ViewModels
5. Create views
6. Test with sample data
7. Polish UI
