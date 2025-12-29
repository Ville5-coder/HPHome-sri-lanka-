# Claude Collaboration Guidelines for HPHome

## Quick Context Summary
- **Swift 5.9+ with SwiftUI**
- **iOS 16.0 minimum, MVVM architecture**
- **No backend, local data only**
- **Swedish text for all UI strings**
- **Portrait-only iPhone app**

## Claude Should Always:
✅ Write complete Swift files (not snippets)
✅ Include proper imports
✅ Use async/await patterns (NOT completion handlers)
✅ Provide SwiftUI previews when applicable
✅ Handle errors gracefully
✅ Comment complex logic only (not obvious code)
✅ Use SwiftData with @Model macro
✅ Use NavigationStack (not NavigationView)
✅ Use Swedish for all user-facing strings
✅ Support portrait orientation only

## Claude Should Never:
❌ Add UIKit code (unless absolutely necessary)
❌ Use completion handlers (use async/await instead)
❌ Add external dependencies without asking
❌ Write backend/API code
❌ Include authentication code
❌ Add networking/URLSession code
❌ Suggest third-party libraries
❌ Write landscape-specific UI code
❌ Add iPad-specific code (iPhone only for now)

## Code Examples Format

### SwiftData Model Example:
```swift
import SwiftData

@Model
final class Exercise: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    
    init(id: UUID = UUID(), title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
    }
}
```

### ViewModel Example:
```swift
import SwiftUI

@MainActor
final class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    
    func loadExercises() async {
        // Load from SwiftData
    }
}
```

### View Example:
```swift
import SwiftUI

struct ExerciseListView: View {
    @StateObject private var viewModel = ExerciseViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.exercises) { exercise in
                Text(exercise.title)
            }
            .navigationTitle("Övningar") // Swedish
            .task {
                await viewModel.loadExercises()
            }
        }
    }
}

#Preview {
    ExerciseListView()
}
```

## Swedish UI Text Examples
- "Övningar" (Exercises)
- "Start" (Start)
- "Resultat" (Results)
- "Inställningar" (Settings)
- "Tillbaka" (Back)
- "Nästa" (Next)
- "Spara" (Save)
- "Avbryt" (Cancel)

## Error Handling Pattern
```swift
do {
    try await someAsyncOperation()
} catch {
    print("Error: \(error.localizedDescription)")
    // Handle error appropriately
}
```

## Important Reminders
1. **100% Local**: No server calls, no API endpoints, no backend
2. **100% SwiftUI**: No UIKit unless absolutely necessary
3. **Swedish First**: All user-facing text in Swedish
4. **Portrait Only**: No landscape layouts
5. **iPhone Only**: No iPad-specific code yet
6. **No Auth**: No login/signup screens
7. **No External Deps**: Keep it native and lightweight
