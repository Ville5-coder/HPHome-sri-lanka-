# HPHome - Project Configuration Reference

## Basic Information
- **App Name**: HPHome
- **Purpose**: Swedish högskoleprovet training app
- **Bundle ID**: com.villesandgren.hphome
- **Platform**: iOS (iPhone only)
- **Minimum iOS**: 16.0
- **Orientation**: Portrait only

## Technical Stack
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI (100% - no UIKit)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Storage**: SwiftData (primary), CoreData (fallback for iOS 16)
- **Data Format**: JSON files for exercise content
- **Persistence**: Local only (NO backend/cloud)

## State Management
- `@State` - view-local state
- `@StateObject` - ViewModels
- `@EnvironmentObject` - shared app state
- NO external state management libraries

## Navigation
- Primary: `NavigationStack` (iOS 16+)
- Secondary: `TabView` for main sections
- NO UIKit navigation

## Async Patterns
- Use `async/await` (NOT completion handlers)
- Use `Task` for calling async code
- Use `.task` modifier in SwiftUI views

## Dependencies
- **Package Manager**: Swift Package Manager (SPM)
- **Required Packages**: None for MVP
- **External Libraries**: None - keep native frameworks only

## Localization
- **Primary Language**: Swedish (sv)
- **Text Direction**: LTR
- **Region Format**: Swedish number/date formatting

## Testing Targets
- iPhone SE (smallest screen)
- iPhone 14/15 Pro (standard)
- iPhone 15 Pro Max (largest)

## Code Style
- Indentation: 4 spaces (not tabs)
- Line Length: 120 characters max
- Prefer `let` over `var`
- Use type inference where clear
- Explicit types when ambiguous

## CRITICAL CONSTRAINTS
❌ **NO Backend/API integration**
❌ **NO User authentication**
❌ **NO Cloud sync (iCloud, Firebase, etc.)**
❌ **NO Payment/in-app purchases**
❌ **NO Analytics frameworks**
❌ **NO External networking libraries**
❌ **NO UIKit** (unless absolutely necessary)
❌ **NO completion handlers** (use async/await)

## Build Configuration
- Debug: Enable SwiftUI preview support
- Release: Optimize for speed, strip debug symbols
- Enable bitcode: No (deprecated)
