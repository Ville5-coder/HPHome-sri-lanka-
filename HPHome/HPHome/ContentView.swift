//
//  ContentView.swift
//  HPHome
//
//  Created by Ville Sandgren on 2025-12-27.
//

import SwiftUI
import SwiftData

// DESIGN GUIDELINE: All future question boxes throughout the app must visually match the 'Gamla Högskoleprov' boxes in layout and appearance (same corner radius, outline color, shadow, padding, and font).
// DESIGN GUIDELINE: All confirmation popups and overlays must follow the pattern of ExitConfirmationOverlay and GameOverOverlay - with semi-transparent black background (0.4 opacity), white card with rounded corners (24pt radius), shadow, proper spacing (24pt between elements), and consistent button styling.
// DESIGN GUIDELINE: All screens must have a "Tillbaka" (back) button in the top-left corner with blue color (RGB: 0.1, 0.25, 0.55) as the standard. Game-specific screens (like Ordsviten) should use their game's accent color instead (e.g., green RGB: 0.2, 0.78, 0.35 for Ordsviten).

// DATABASE IMAGE STRUCTURE FOR KVANT ALTERNATIVES:
// When importing questions from the database, KVANT alternatives can have images instead of text.
// Image naming convention: "{testType}_{year}_{semester}_q{questionNumber}_option{letter}.png"
// Examples:
//   - "kvant_2025_ht_q5_optionA.png"  (Historical test: KVANT, HT 2025, Question 5, Option A)
//   - "kvant_generated_0_q12_optionC.png"  (Generated test, Question 12, Option C)
//
// Database schema should include:
//   - Question table: id, testType, year (nullable), semester (nullable), provpassNumber, questionNumber, questionText, questionImageName (nullable for DTK)
//   - Alternative table: id, questionId (FK), letter (A/B/C/D/E), alternativeText (nullable), alternativeImageName (nullable)
//
// Usage in code:
//   AnswerButton(option: "A", isSelected: true, text: "Text alternative", imageName: nil)
//   AnswerButton(option: "B", isSelected: false, text: nil, imageName: "kvant_2025_ht_q5_optionB.png")

// MARK: - SwiftData Models for Progress Saving

// SAMPLE QUESTION DATABASE MODELS (for reference when implementing):
// These models show the structure needed to support images in alternatives
/*
@Model
final class Question {
    var id: UUID
    var testType: String  // "KVANT" or "VERB"
    var year: String?  // e.g., "2025" (nil for generated)
    var semester: String?  // "HT" or "VT" (nil for generated)
    var provpassNumber: Int  // 0 for generated, 1-5 for historical
    var questionNumber: Int  // 1-40
    var sectionCode: String  // "XYZ", "KVA", "NOG", "DTK", "ORD", "LÄS", "MEK", "ELF"
    var questionText: String
    var questionImageName: String?  // For DTK questions with diagrams
    var correctAnswerLetter: String  // "A", "B", "C", "D", or "E"
    
    @Relationship(deleteRule: .cascade)
    var alternatives: [QuestionAlternative]
    
    init(testType: String, year: String? = nil, semester: String? = nil, 
         provpassNumber: Int, questionNumber: Int, sectionCode: String,
         questionText: String, questionImageName: String? = nil, correctAnswerLetter: String) {
        self.id = UUID()
        self.testType = testType
        self.year = year
        self.semester = semester
        self.provpassNumber = provpassNumber
        self.questionNumber = questionNumber
        self.sectionCode = sectionCode
        self.questionText = questionText
        self.questionImageName = questionImageName
        self.correctAnswerLetter = correctAnswerLetter
        self.alternatives = []
    }
}

@Model
final class QuestionAlternative {
    var id: UUID
    var letter: String  // "A", "B", "C", "D", or "E"
    var alternativeText: String?  // Text for the alternative (nullable if image is used)
    var alternativeImageName: String?  // Image filename (nullable if text is used)
    
    var question: Question?
    
    init(letter: String, alternativeText: String? = nil, alternativeImageName: String? = nil) {
        self.id = UUID()
        self.letter = letter
        self.alternativeText = alternativeText
        self.alternativeImageName = alternativeImageName
    }
}
*/

@Model
final class TestSession {
    var id: UUID
    var testType: String  // "KVANT" or "VERB"
    var provpassNumber: Int  // 0 for generated, 1-5 for historical
    var historicalTestYear: String?  // e.g., "2025"
    var historicalTestSemester: String?  // "HT" or "VT"
    var currentQuestionNumber: Int
    var timeRemaining: TimeInterval
    var timerEnabled: Bool
    var startedAt: Date
    var lastUpdated: Date
    var isCompleted: Bool
    
    @Relationship(deleteRule: .cascade)
    var answers: [TestAnswer]
    
    init(testType: String, provpassNumber: Int, historicalTestYear: String? = nil, historicalTestSemester: String? = nil, timerEnabled: Bool) {
        self.id = UUID()
        self.testType = testType
        self.provpassNumber = provpassNumber
        self.historicalTestYear = historicalTestYear
        self.historicalTestSemester = historicalTestSemester
        self.currentQuestionNumber = 1
        self.timeRemaining = 55 * 60  // 55 minutes
        self.timerEnabled = timerEnabled
        self.startedAt = Date()
        self.lastUpdated = Date()
        self.isCompleted = false
        self.answers = []
    }
}

@Model
final class TestAnswer {
    var questionNumber: Int
    var selectedOption: String  // "A", "B", "C", "D", or "E"
    var answeredAt: Date
    
    var testSession: TestSession?
    
    init(questionNumber: Int, selectedOption: String) {
        self.questionNumber = questionNumber
        self.selectedOption = selectedOption
        self.answeredAt = Date()
    }
}

// MARK: - Section Data Model
struct HPSection: Identifiable {
    let id: Int
    let code: String
    let iconName: String
}

// MARK: - Reusable Confirmation Overlay Component
// This component provides a consistent design for all confirmation dialogs
struct ConfirmationOverlay: View {
    let title: String
    let message: String
    let iconName: String
    let iconColor: Color
    let confirmButtonText: String
    let confirmButtonColor: Color
    let cancelButtonText: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Card
            VStack(spacing: 24) {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(iconColor)
                
                // Title
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    .multilineTextAlignment(.center)
                
                // Message
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                // Buttons
                VStack(spacing: 12) {
                    // Cancel button (primary action - on top)
                    Button(action: onCancel) {
                        Text(cancelButtonText)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                            )
                    }
                    
                    // Confirm button (destructive action - on bottom)
                    Button(action: onConfirm) {
                        Text(confirmButtonText)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(confirmButtonColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(confirmButtonColor, lineWidth: 2)
                            )
                    }
                }
            }
            .padding(32)
            .frame(width: 340)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
        }
        .transition(.opacity)
    }
}

// MARK: - Reusable Game Over Overlay Component
// This component can be used across all games in the app
struct GameOverOverlay: View {
    let score: Int
    let scoreLabel: String  // e.g., "Din streak", "Ditt resultat"
    let scoreIcon: String  // e.g., "flame.fill", "star.fill"
    let accentColor: Color  // Main color for the score
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Card
            VStack(spacing: 24) {
                // Celebration icon
                Image(systemName: "star.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))  // Gold
                    .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.5), radius: 10)
                
                // Title
                Text("Spel slut!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                
                // Score info
                VStack(spacing: 8) {
                    Text(scoreLabel)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.6))
                    
                    HStack(spacing: 8) {
                        Image(systemName: scoreIcon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.0))
                        Text("\(score)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(accentColor)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.97, green: 0.97, blue: 0.97))
                )
                
                // Close button
                Button(action: onDismiss) {
                    Text("Avsluta")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.2, green: 0.78, blue: 0.35))
                        )
                }
            }
            .padding(32)
            .frame(width: 320)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
        }
        .transition(.opacity)
    }
}

struct ContentView: View {
    @State private var selectedTab = 0  // Start on Hem (first tab)
    
    init() {
        // Keep it transparent - this was working!
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Blue color for selected items
        let blueColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        
        // Create item appearance
        let itemAppearance = UITabBarItemAppearance()
        
        // Normal (unselected) state
        itemAppearance.normal.iconColor = .systemGray
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 10)
        ]
        
        // Selected state
        itemAppearance.selected.iconColor = blueColor
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: blueColor,
            .font: UIFont.systemFont(ofSize: 10)
        ]
        
        // Apply to all layout types
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        // Set appearance for all states
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Keep translucent
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().tintColor = blueColor
        UITabBar.appearance().unselectedItemTintColor = .systemGray
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1 - Hem
            HemView()
                .tabItem {
                    Label("Hem", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tab 2 - Spela
            SpelaView()
                .tabItem {
                    Label("Spela", systemImage: "arcade.stick.console")
                }
                .tag(1)
            
            // Tab 3 - Öva
            OvaView()
                .tabItem {
                    Label("Öva", systemImage: "books.vertical")
                }
                .tag(2)
            
            // Tab 4 - Prov
            ProvView()
                .tabItem {
                    Label("Prov", systemImage: "doc.text.fill")
                }
                .tag(3)
        }
        .tint(Color(red: 0.0, green: 0.48, blue: 1.0))
        .onAppear {
            // Additional runtime fix to remove selection indicator
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBar = window.rootViewController?.view.subviews.first(where: { $0 is UITabBar }) as? UITabBar {
                tabBar.selectionIndicatorImage = UIImage()
            }
        }
    }
    
    // Return the appropriate color based on selected tab
    private func tabColor(for tab: Int) -> Color {
        // Always return the same blue color for consistency
        return Color(red: 0.0, green: 0.48, blue: 1.0)  // Primary blue for all tabs
    }
}

// MARK: - Tab Views
struct SpelaView: View {
    @State private var navigateToOrdsviten = false
    @State private var navigateToFinnFelet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header section - left aligned
                    HStack {
                        Text("Spela")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                    
                    // Two games in a row
                    HStack(spacing: 16) {
                        // Game 1: Ordsviten (Green) - Trains ORD
                        GameCard(
                            title: "Ordsviten",
                            iconName: "text.word.spacing",
                            color: Color(red: 0.2, green: 0.78, blue: 0.35),  // Nice green
                            sectionCode: "ORD",
                            sectionIcon: "lightbulb"
                        ) {
                            navigateToOrdsviten = true
                        }
                        
                        // Game 2: Finn felet (Black) - Trains MEK
                        GameCard(
                            title: "Finn felet",
                            iconName: "xmark.circle.fill",
                            color: Color(red: 0.11, green: 0.11, blue: 0.118),  // Black
                            sectionCode: "MEK",
                            sectionIcon: "puzzlepiece"
                        ) {
                            navigateToFinnFelet = true
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 24)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToOrdsviten) {
                OrdsvitenIntroView()
            }
            .navigationDestination(isPresented: $navigateToFinnFelet) {
                FinnFeletIntroView()
            }
        }
    }
}

// MARK: - Game Card Component
struct GameCard: View {
    let title: String
    let iconName: String
    let color: Color
    let sectionCode: String
    let sectionIcon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                VStack(spacing: 16) {
                    // Large icon
                    Image(systemName: iconName)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.white)
                    
                    // Title text below icon
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(color)
                )
                
                // Section badge in top right corner
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: sectionIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(12)
                    }
                    Spacer()
                }
            }
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Difficulty Button Component
struct DifficultyButton: View {
    let time: Double
    let label: String
    let sublabel: String
    let isSelected: Bool
    let action: () -> Void
    
    // Emoji and color based on difficulty
    private var emoji: String {
        switch label {
        case "Lätt": return "🌱"
        case "Medium": return "⚡️"
        case "Svår": return "🔥"
        default: return "⭐️"
        }
    }
    
    private var accentColor: Color {
        switch label {
        case "Lätt": return Color(red: 0.2, green: 0.78, blue: 0.35)  // Green
        case "Medium": return Color(red: 1.0, green: 0.6, blue: 0.0)  // Orange
        case "Svår": return Color(red: 0.95, green: 0.27, blue: 0.27)  // Red
        default: return Color(red: 0.2, green: 0.78, blue: 0.35)
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Emoji icon
                Text(emoji)
                    .font(.system(size: 32))
                
                Text(label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                Text(sublabel)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? accentColor : Color(red: 0.898, green: 0.898, blue: 0.898), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Heart Button Component
struct HeartButton: View {
    let hearts: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ForEach(0..<hearts, id: \.self) { _ in
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(red: 0.2, green: 0.78, blue: 0.35) : Color(red: 0.898, green: 0.898, blue: 0.898), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ordsviten Intro View
// TUTORIAL STRUCTURE PATTERN:
// This tutorial structure can be replicated for all games in the app.
// Key components:
// 1. @AppStorage for persisting tutorial completion (e.g., "hasCompleted[GameName]Tutorial")
// 2. Step-based tutorial flow (0=title/buttons, 1-N=interactive steps, final=completion)
// 3. Interactive demonstrations with hand gesture hints
// 4. After completion, return to step 0 (title/buttons) so user can press "Spela" when ready
// 5. Tutorial is skipped on subsequent visits - goes straight to step 0 (title/buttons)
// 6. Manual start via "Spela" button that also marks tutorial as complete
// 7. Use GameOverOverlay component for consistent game ending across all games
struct OrdsvitenIntroView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedOrdsvitenTutorial") private var hasCompletedTutorial = false
    @State private var startGame = false
    @State private var skipTutorial = false  // Track if user wants to skip to game
    @State private var currentStep = 0  // 0 = title, 1 = first card, 2 = second card, 3 = done
    @State private var cardOffset = CGSize.zero
    @State private var showCheckmark = false
    @State private var showXmark = false
    @State private var hintOffset: CGFloat = 0  // For animated hint
    
    // Game settings
    @State private var selectedTimePerWord: Double = 5.0  // Default: 5 seconds (Medium)
    @State private var selectedHearts: Int = 3  // Default: 3 hearts
    
    // Tutorial words
    let tutorialWords = [
        (word: "Hund", left: "djur", right: "möbel", correctSide: "left"),
        (word: "Stol", left: "fordon", right: "möbel", correctSide: "right")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button (green for Ordsviten game)
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                        Text("Tillbaka")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.2, green: 0.78, blue: 0.35))  // Green for Ordsviten
                    )
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Spacer()
            
            // Interactive tutorial area
            ZStack {
                if currentStep == 0 {
                    // Show title and settings
                    VStack(spacing: 32) {
                        // Title
                        Text("Ordsviten")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                            .padding(.bottom, 16)
                        
                        // Settings section
                        VStack(spacing: 32) {
                            // Time per word setting
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Tid per ord")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                
                                HStack(spacing: 12) {
                                    // 10 sec - Lätt
                                    DifficultyButton(
                                        time: 10.0,
                                        label: "Lätt",
                                        sublabel: "10 sek",
                                        isSelected: selectedTimePerWord == 10.0
                                    ) {
                                        selectedTimePerWord = 10.0
                                    }
                                    
                                    // 5 sec - Medium
                                    DifficultyButton(
                                        time: 5.0,
                                        label: "Medium",
                                        sublabel: "5 sek",
                                        isSelected: selectedTimePerWord == 5.0
                                    ) {
                                        selectedTimePerWord = 5.0
                                    }
                                    
                                    // 2 sec - Svår
                                    DifficultyButton(
                                        time: 2.0,
                                        label: "Svår",
                                        sublabel: "2 sek",
                                        isSelected: selectedTimePerWord == 2.0
                                    ) {
                                        selectedTimePerWord = 2.0
                                    }
                                }
                            }
                            
                            // Hearts setting
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Antal liv")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                
                                HStack(spacing: 12) {
                                    // 1 heart
                                    HeartButton(hearts: 1, isSelected: selectedHearts == 1) {
                                        selectedHearts = 1
                                    }
                                    
                                    // 3 hearts
                                    HeartButton(hearts: 3, isSelected: selectedHearts == 3) {
                                        selectedHearts = 3
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                } else if currentStep == 3 {
                    // Show completion message
                    VStack(spacing: 24) {
                        Image(systemName: "party.popper.fill")
                            .font(.system(size: 64, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))  // Green
                        
                        Text("Grymt!")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        
                        Text("Dags att spela på riktigt")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                            .multilineTextAlignment(.center)
                    }
                    .onAppear {
                        // Mark tutorial as completed
                        hasCompletedTutorial = true
                        
                        // After 2 seconds, go back to title/button view
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                currentStep = 0
                            }
                        }
                    }
                } else if currentStep <= 2 {
                    // Show interactive card
                    let cardIndex = currentStep - 1
                    if cardIndex < tutorialWords.count {
                        let card = tutorialWords[cardIndex]
                        
                        VStack(spacing: 0) {
                            Spacer()
                            
                            // Instruction text above word
                            Text("Dra kortet åt det håll som matchar alternativet")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                                .padding(.bottom, 16)
                                .opacity(cardOffset == .zero ? 1.0 : 0.3)
                                .animation(.easeInOut(duration: 0.2), value: cardOffset)
                            
                            // Word
                            Text(card.word)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                .padding(.bottom, 60)
                            
                            // Swipeable card
                            ZStack {
                                VStack(spacing: 32) {
                                    // Left option
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.left")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                        Text(card.left)
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                        Spacer()
                                    }
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                    
                                    // Right option
                                    HStack(spacing: 12) {
                                        Spacer()
                                        Text(card.right)
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                    }
                                }
                                .padding(32)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(red: 0.97, green: 0.97, blue: 0.97))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(red: 0.898, green: 0.898, blue: 0.898), lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
                                
                                // Hand drag hint icon - only show when card is not being dragged
                                if cardOffset == .zero {
                                    Image(systemName: "hand.draw")
                                        .font(.system(size: 40, weight: .semibold))
                                        .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.5))
                                        .offset(x: hintOffset)
                                        .transition(.opacity)
                                }
                            }
                            .offset(x: cardOffset.width + (cardOffset == .zero ? hintOffset : 0), y: cardOffset.height)
                            .rotationEffect(.degrees(Double((cardOffset.width + (cardOffset == .zero ? hintOffset : 0)) / 20)))
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        cardOffset = gesture.translation
                                    }
                                    .onEnded { gesture in
                                        handleSwipe(gesture: gesture, correctSide: card.correctSide)
                                    }
                            )
                            .padding(.horizontal, 20)
                            
                            Spacer()
                        }
                    }
                }
                
                // Feedback overlays
                if showCheckmark {
                    Color.green.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 100, weight: .bold))
                                .foregroundColor(.green)
                        )
                }
                
                if showXmark {
                    Color.red.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 100, weight: .bold))
                                .foregroundColor(.red)
                        )
                }
            }


            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
            
            // Action button
            Button(action: {
                hasCompletedTutorial = true
                startGame = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Spela")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.2, green: 0.78, blue: 0.35))
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $startGame) {
            OrdsvitenGameView(timePerWord: selectedTimePerWord, maxHearts: selectedHearts)
        }
        .onAppear {
            // Only show tutorial if not completed
            if !hasCompletedTutorial {
                // Show title for 1 second, then first card
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        currentStep = 1
                    }
                    // Start the hint animation
                    startHintAnimation()
                }
            }
            // If tutorial is completed, just show the title and buttons (currentStep = 0)
        }
    }
    
    private func startHintAnimation() {
        // Determine the correct direction based on the current tutorial card
        let cardIndex = currentStep - 1
        guard cardIndex < tutorialWords.count else { return }
        let card = tutorialWords[cardIndex]
        let direction: CGFloat = card.correctSide == "left" ? -30 : 30
        
        // Animate the hint offset back and forth
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            hintOffset = direction
        }
    }
    
    private func stopHintAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            hintOffset = 0
        }
    }
    
    private func handleSwipe(gesture: DragGesture.Value, correctSide: String) {
        let swipeThreshold: CGFloat = 100
        
        if abs(gesture.translation.width) > swipeThreshold {
            stopHintAnimation()
            let swipedLeft = gesture.translation.width < 0
            let isCorrect = (swipedLeft && correctSide == "left") || (!swipedLeft && correctSide == "right")
            
            if isCorrect {
                // Show correct feedback
                showCheckmark = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCheckmark = false
                    
                    // Move to next step
                    currentStep += 1
                    cardOffset = .zero
                    
                    // Restart hint animation for the new card if still in tutorial
                    if currentStep <= 2 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            startHintAnimation()
                        }
                    }
                }
            } else {
                // Show wrong feedback, reset card
                showXmark = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showXmark = false
                    withAnimation(.spring()) {
                        cardOffset = .zero
                    }
                    // Restart hint animation after error
                    startHintAnimation()
                }
            }
        } else {
            // Reset card position
            withAnimation(.spring()) {
                cardOffset = .zero
            }
        }
    }
}

// MARK: - Ordsviten Game View
struct OrdsvitenGameView: View {
    @Environment(\.dismiss) private var dismiss
    
    let timePerWord: Double  // Time per word from settings
    let maxHearts: Int  // Max hearts from settings
    
    @State private var hearts: Int
    @State private var streak = 0
    @State private var currentQuestionIndex = 0
    @State private var offset = CGSize.zero
    @State private var showingCorrectFeedback = false
    @State private var showingWrongFeedback = false
    @State private var gameOver = false
    @State private var timeRemaining: Double
    @State private var timer: Timer?
    @State private var heartBounce = false
    @State private var streakBounce = false
    
    // Initialize with settings
    init(timePerWord: Double = 5.0, maxHearts: Int = 3) {
        self.timePerWord = timePerWord
        self.maxHearts = maxHearts
        self._hearts = State(initialValue: maxHearts)
        self._timeRemaining = State(initialValue: timePerWord)
    }
    
    // Sample questions (in real app, this would come from a database)
    let questions = [
        WordQuestion(word: "Hund", leftOption: "djur", rightOption: "möbel", correctSide: .left),
        WordQuestion(word: "Stol", leftOption: "fordon", rightOption: "möbel", correctSide: .right),
        WordQuestion(word: "Bil", leftOption: "fordon", rightOption: "frukt", correctSide: .left),
        WordQuestion(word: "Äpple", leftOption: "verktyg", rightOption: "frukt", correctSide: .right),
        WordQuestion(word: "Hammare", leftOption: "verktyg", rightOption: "väder", correctSide: .left),
        WordQuestion(word: "Katt", leftOption: "djur", rightOption: "verktyg", correctSide: .left),
        WordQuestion(word: "Bord", leftOption: "frukt", rightOption: "möbel", correctSide: .right),
        WordQuestion(word: "Cykel", leftOption: "fordon", rightOption: "kläder", correctSide: .left),
        WordQuestion(word: "Banan", leftOption: "instrument", rightOption: "frukt", correctSide: .right),
        WordQuestion(word: "Såg", leftOption: "verktyg", rightOption: "djur", correctSide: .left),
        WordQuestion(word: "Häst", leftOption: "djur", rightOption: "väder", correctSide: .left),
        WordQuestion(word: "Soffa", leftOption: "fordon", rightOption: "möbel", correctSide: .right),
        WordQuestion(word: "Tåg", leftOption: "fordon", rightOption: "mat", correctSide: .left),
        WordQuestion(word: "Apelsin", leftOption: "verktyg", rightOption: "frukt", correctSide: .right),
        WordQuestion(word: "Skruvmejsel", leftOption: "verktyg", rightOption: "kläder", correctSide: .left),
        WordQuestion(word: "Mus", leftOption: "djur", rightOption: "möbel", correctSide: .left),
        WordQuestion(word: "Lampa", leftOption: "djur", rightOption: "möbel", correctSide: .right),
        WordQuestion(word: "Motorcykel", leftOption: "fordon", rightOption: "mat", correctSide: .left),
        WordQuestion(word: "Päron", leftOption: "kläder", rightOption: "frukt", correctSide: .right),
        WordQuestion(word: "Tång", leftOption: "verktyg", rightOption: "väder", correctSide: .left)
    ]
    
    var currentQuestion: WordQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with hearts and streak
                HStack {
                    // Hearts
                    HStack(spacing: 8) {
                        ForEach(0..<maxHearts, id: \.self) { index in
                            Image(systemName: index < hearts ? "heart.fill" : "heart")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(index < hearts ? .red : Color.gray.opacity(0.3))
                        }
                    }
                    .scaleEffect(heartBounce ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: heartBounce)
                    
                    Spacer()
                    
                    // Streak counter
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.0))
                        Text("\(streak)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    }
                    .scaleEffect(streakBounce ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: streakBounce)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Timer bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                timeRemaining > 2.0 ? Color(red: 0.2, green: 0.78, blue: 0.35) :
                                timeRemaining > 1.0 ? Color.orange : Color.red
                            )
                            .frame(width: geometry.size.width * CGFloat(timeRemaining / timePerWord), height: 8)
                            .animation(.linear(duration: 0.1), value: timeRemaining)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                Spacer()
                
                if let question = currentQuestion {
                    // Main word in center
                    Text(question.word)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        .padding(.bottom, 60)
                    
                    // Swipe card with options
                    ZStack {
                        // Card
                        VStack(spacing: 32) {
                            // Left option
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                                Text(question.leftOption)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                Spacer()
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            // Right option
                            HStack(spacing: 12) {
                                Spacer()
                                Text(question.rightOption)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                            }
                        }
                        .padding(32)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.97, green: 0.97, blue: 0.97))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(red: 0.898, green: 0.898, blue: 0.898), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
                        .offset(offset)
                        .rotationEffect(.degrees(Double(offset.width / 20)))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    offset = gesture.translation
                                }
                                .onEnded { gesture in
                                    handleSwipe(translation: gesture.translation)
                                }
                        )
                    }
                    .padding(.horizontal, 20)
                } else {
                    // Game complete
                    Text("Spelet slut!")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                }
                
                Spacer()
            }
            
            // Feedback overlays
            if showingCorrectFeedback {
                Color.green.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 100, weight: .bold))
                            .foregroundColor(.green)
                    )
            }
            
            if showingWrongFeedback {
                Color.red.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay(
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 100, weight: .bold))
                            .foregroundColor(.red)
                    )
            }
        }
        .navigationBarHidden(true)
        .overlay {
            // Custom game over overlay using reusable component
            if gameOver {
                GameOverOverlay(
                    score: streak,
                    scoreLabel: "Din streak",
                    scoreIcon: "flame.fill",
                    accentColor: Color(red: 0.2, green: 0.78, blue: 0.35)
                ) {
                    dismiss()
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timeRemaining = timePerWord
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                // Time's up - lose a heart
                timer?.invalidate()
                handleTimeout()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleTimeout() {
        hearts -= 1
        triggerHeartBounce()
        showWrongFeedback()
        
        if hearts <= 0 {
            stopTimer()
            gameOver = true
        } else {
            // Move to next question
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentQuestionIndex += 1
                offset = .zero
                
                if currentQuestion == nil {
                    // All questions completed
                    stopTimer()
                    gameOver = true
                } else {
                    startTimer()
                }
            }
        }
    }
    
    private func handleSwipe(translation: CGSize) {
        let swipeThreshold: CGFloat = 100
        
        if abs(translation.width) > swipeThreshold {
            stopTimer()
            let swipedLeft = translation.width < 0
            checkAnswer(swipedLeft: swipedLeft)
        } else {
            // Reset card position
            withAnimation(.spring()) {
                offset = .zero
            }
        }
    }
    
    private func checkAnswer(swipedLeft: Bool) {
        guard let question = currentQuestion else { return }
        
        let isCorrect = (swipedLeft && question.correctSide == .left) ||
                       (!swipedLeft && question.correctSide == .right)
        
        if isCorrect {
            // Correct answer
            streak += 1
            triggerStreakBounce()
            showCorrectFeedback()
        } else {
            // Wrong answer
            hearts -= 1
            triggerHeartBounce()
            showWrongFeedback()
            
            // Check if game over AFTER showing feedback
            if hearts <= 0 {
                stopTimer()  // Stop timer immediately
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    gameOver = true
                }
                return
            }
        }
        
        // Move to next question (only if hearts > 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentQuestionIndex += 1
            offset = .zero
            
            if currentQuestion == nil {
                // All questions completed
                stopTimer()  // Stop timer when all questions done
                gameOver = true
            } else {
                startTimer()
            }
        }
    }
    
    private func showCorrectFeedback() {
        showingCorrectFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingCorrectFeedback = false
        }
    }
    
    private func showWrongFeedback() {
        showingWrongFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingWrongFeedback = false
        }
    }
    
    private func triggerHeartBounce() {
        heartBounce = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            heartBounce = false
        }
    }
    
    private func triggerStreakBounce() {
        streakBounce = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            streakBounce = false
        }
    }
}

// MARK: - Word Question Model
struct WordQuestion {
    let word: String
    let leftOption: String
    let rightOption: String
    let correctSide: Side
    
    enum Side {
        case left, right
    }
}

// MARK: - Finn Felet Intro View
struct FinnFeletIntroView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedFinnFeletTutorial") private var hasCompletedTutorial = false
    @State private var startGame = false
    @State private var currentStep = 0  // 0 = title/settings, 1-2 = tutorial, 3 = completion
    
    // Game settings
    @State private var selectedTimePerSentence: Double = 10.0  // Default: 10 seconds (Medium)
    @State private var selectedHearts: Int = 3  // Default: 3 hearts
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button (black for Finn felet game)
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                        Text("Tillbaka")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.11, green: 0.11, blue: 0.118))  // Black for Finn felet
                    )
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Spacer()
            
            // Main content area
            ZStack {
                if currentStep == 0 {
                    // Show title and settings
                    VStack(spacing: 32) {
                        // Title
                        VStack(spacing: 12) {
                            Text("Finn felet")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                            
                            Text("Hitta grammatikfelet i texten")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.6))
                        }
                        .padding(.bottom, 16)
                        
                        // Settings section
                        VStack(spacing: 32) {
                            // Time per sentence setting
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Tid per mening")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                
                                HStack(spacing: 12) {
                                    // 15 sec - Lätt
                                    DifficultyButton(
                                        time: 15.0,
                                        label: "Lätt",
                                        sublabel: "15 sek",
                                        isSelected: selectedTimePerSentence == 15.0
                                    ) {
                                        selectedTimePerSentence = 15.0
                                    }
                                    
                                    // 10 sec - Medium
                                    DifficultyButton(
                                        time: 10.0,
                                        label: "Medium",
                                        sublabel: "10 sek",
                                        isSelected: selectedTimePerSentence == 10.0
                                    ) {
                                        selectedTimePerSentence = 10.0
                                    }
                                    
                                    // 5 sec - Svår
                                    DifficultyButton(
                                        time: 5.0,
                                        label: "Svår",
                                        sublabel: "5 sek",
                                        isSelected: selectedTimePerSentence == 5.0
                                    ) {
                                        selectedTimePerSentence = 5.0
                                    }
                                }
                            }
                            
                            // Hearts setting
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Antal liv")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                
                                HStack(spacing: 12) {
                                    // 1 heart
                                    HeartButton(hearts: 1, isSelected: selectedHearts == 1) {
                                        selectedHearts = 1
                                    }
                                    
                                    // 3 hearts
                                    HeartButton(hearts: 3, isSelected: selectedHearts == 3) {
                                        selectedHearts = 3
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                } else if currentStep == 3 {
                    // Show completion message
                    VStack(spacing: 24) {
                        Image(systemName: "party.popper.fill")
                            .font(.system(size: 64, weight: .semibold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))  // Black
                        
                        Text("Perfekt!")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        
                        Text("Nu är du redo att hitta fel på riktigt")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                            .multilineTextAlignment(.center)
                    }
                    .onAppear {
                        // Mark tutorial as completed
                        hasCompletedTutorial = true
                        
                        // After 2 seconds, go back to title/button view
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                currentStep = 0
                            }
                        }
                    }
                }
                // Tutorial steps will be added later
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
            
            // Action button
            Button(action: {
                hasCompletedTutorial = true
                startGame = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Spela")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.11, green: 0.11, blue: 0.118))  // Black
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $startGame) {
            FinnFeletGameView(timePerSentence: selectedTimePerSentence, maxHearts: selectedHearts)
        }
        .onAppear {
            // Only show tutorial if not completed
            if !hasCompletedTutorial {
                // Show title for 1 second, then first tutorial step
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        currentStep = 1
                    }
                }
            }
            // If tutorial is completed, just show the title and buttons (currentStep = 0)
        }
    }
}

// MARK: - Finn Felet Game View
struct FinnFeletGameView: View {
    @Environment(\.dismiss) private var dismiss
    
    let timePerSentence: Double  // Time per sentence from settings
    let maxHearts: Int  // Max hearts from settings
    
    @State private var hearts: Int
    @State private var streak = 0
    @State private var currentQuestionIndex = 0
    @State private var gameOver = false
    @State private var timeRemaining: Double
    @State private var timer: Timer?
    @State private var heartBounce = false
    @State private var streakBounce = false
    @State private var selectedWordIndex: Int? = nil
    @State private var showingCorrectFeedback = false
    @State private var showingWrongFeedback = false
    
    // Initialize with settings
    init(timePerSentence: Double = 10.0, maxHearts: Int = 3) {
        self.timePerSentence = timePerSentence
        self.maxHearts = maxHearts
        self._hearts = State(initialValue: maxHearts)
        self._timeRemaining = State(initialValue: timePerSentence)
    }
    
    // Sample questions (in real app, this would come from a database)
    // Each sentence has one grammatical error
    let questions = [
        GrammarQuestion(
            sentence: "Jag gillar att äta glass på sommaren när det är varmt ute",
            words: ["Jag", "gillar", "att", "äta", "glass", "på", "sommaren", "när", "det", "är", "varmt", "ute"],
            correctWordIndex: 1,  // "gillar" should be "tycker om"
            explanation: "Fel: 'gillar' borde vara 'tycker om'"
        ),
        GrammarQuestion(
            sentence: "Han gick till affären för att köpa mjölk och bröd",
            words: ["Han", "gick", "till", "affären", "för", "att", "köpa", "mjölk", "och", "bröd"],
            correctWordIndex: 3,  // "affären" should be "butiken" (more common)
            explanation: "Fel: 'affären' är ovanligt, 'butiken' är bättre"
        )
    ]
    
    var currentQuestion: GrammarQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with hearts and streak
                HStack {
                    // Hearts
                    HStack(spacing: 8) {
                        ForEach(0..<maxHearts, id: \.self) { index in
                            Image(systemName: index < hearts ? "heart.fill" : "heart")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(index < hearts ? .red : Color.gray.opacity(0.3))
                        }
                    }
                    .scaleEffect(heartBounce ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: heartBounce)
                    
                    Spacer()
                    
                    // Streak counter
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.0))
                        Text("\(streak)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    }
                    .scaleEffect(streakBounce ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: streakBounce)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Timer bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                timeRemaining > 3.0 ? Color(red: 0.11, green: 0.11, blue: 0.118) :  // Black
                                timeRemaining > 1.5 ? Color.orange : Color.red
                            )
                            .frame(width: geometry.size.width * CGFloat(timeRemaining / timePerSentence), height: 8)
                            .animation(.linear(duration: 0.1), value: timeRemaining)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                Spacer()
                
                if let question = currentQuestion {
                    // Sentence with tappable words
                    FlowLayout(spacing: 12) {
                        ForEach(Array(question.words.enumerated()), id: \.offset) { index, word in
                            WordButton(
                                word: word,
                                isSelected: selectedWordIndex == index,
                                accentColor: Color(red: 0.11, green: 0.11, blue: 0.118)
                            ) {
                                selectWord(at: index)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                } else {
                    // Game complete
                    Text("Spelet slut!")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                }
                
                Spacer()
            }
            
            // Feedback overlays
            if showingCorrectFeedback {
                Color.green.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 100, weight: .bold))
                            .foregroundColor(.green)
                    )
            }
            
            if showingWrongFeedback {
                Color.red.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay(
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 100, weight: .bold))
                            .foregroundColor(.red)
                    )
            }
        }
        .navigationBarHidden(true)
        .overlay {
            // Custom game over overlay using reusable component
            if gameOver {
                GameOverOverlay(
                    score: streak,
                    scoreLabel: "Din streak",
                    scoreIcon: "flame.fill",
                    accentColor: Color(red: 0.11, green: 0.11, blue: 0.118)  // Black
                ) {
                    dismiss()
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timeRemaining = timePerSentence
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                // Time's up - lose a heart
                timer?.invalidate()
                handleTimeout()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleTimeout() {
        hearts -= 1
        triggerHeartBounce()
        showWrongFeedback()
        
        if hearts <= 0 {
            stopTimer()
            gameOver = true
        } else {
            // Move to next question
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentQuestionIndex += 1
                selectedWordIndex = nil
                
                if currentQuestion == nil {
                    // All questions completed
                    stopTimer()
                    gameOver = true
                } else {
                    startTimer()
                }
            }
        }
    }
    
    private func selectWord(at index: Int) {
        guard let question = currentQuestion else { return }
        
        stopTimer()
        selectedWordIndex = index
        
        // Check if correct
        let isCorrect = index == question.correctWordIndex
        
        if isCorrect {
            // Correct answer
            streak += 1
            triggerStreakBounce()
            showCorrectFeedback()
        } else {
            // Wrong answer
            hearts -= 1
            triggerHeartBounce()
            showWrongFeedback()
            
            // Check if game over AFTER showing feedback
            if hearts <= 0 {
                stopTimer()  // Stop timer immediately
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    gameOver = true
                }
                return
            }
        }
        
        // Move to next question (only if hearts > 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentQuestionIndex += 1
            selectedWordIndex = nil
            
            if currentQuestion == nil {
                // All questions completed
                stopTimer()  // Stop timer when all questions done
                gameOver = true
            } else {
                startTimer()
            }
        }
    }
    
    private func showCorrectFeedback() {
        showingCorrectFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingCorrectFeedback = false
        }
    }
    
    private func showWrongFeedback() {
        showingWrongFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingWrongFeedback = false
        }
    }
    
    private func triggerHeartBounce() {
        heartBounce = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            heartBounce = false
        }
    }
    
    private func triggerStreakBounce() {
        streakBounce = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            streakBounce = false
        }
    }
}

// MARK: - Grammar Question Model
struct GrammarQuestion {
    let sentence: String
    let words: [String]
    let correctWordIndex: Int
    let explanation: String
}

// MARK: - Word Button Component (for Finn Felet)
struct WordButton: View {
    let word: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(word)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.11, green: 0.11, blue: 0.118))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? accentColor : Color(red: 0.97, green: 0.97, blue: 0.97))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? accentColor : Color(red: 0.898, green: 0.898, blue: 0.898), lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout (for wrapping words)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: ProposedViewSize(result.frames[index].size))
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

struct HemView: View {
    @AppStorage("dagensOrdStreak") private var streak = 0
    @AppStorage("lastCompletedDate") private var lastCompletedDateString = ""
    @State private var selectedAnswer: String? = nil
    @State private var hasAnswered = false
    @State private var showFeedback = false
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    
    // HP-estimering scores (superficial for now)
    private let kvantScore: Double = 1.5
    private let verbScore: Double = 1.3
    
    // Sample word of the day - in real app, this would come from database based on date
    let todaysWord = (
        word: "ruva",
        correctAnswer: "skydda",
        alternatives: [
            "liten vrå",
            "väderbiten",
            "om väldigt liten text",
            "skydda",
            "pressade foderkulor"
        ],
        explanation: "\"ruva\" betyder skydda"
    )
    
    // Target date: April 18, 2026
    var targetDate: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 4
        components.day = 18
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    // Format time remaining into days, hours, minutes, seconds
    var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let total = Int(timeRemaining)
        let days = total / 86400
        let hours = (total % 86400) / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return (days, hours, minutes, seconds)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with logo
                    HStack(alignment: .center, spacing: 12) {
                        // Logo - using system icon as fallback if custom image not found
                        if let _ = UIImage(named: "hphome-logo-dark") {
                            Image("hphome-logo-dark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 48, height: 48)
                        } else {
                            // Placeholder - replace with your actual logo
                            Image(systemName: "graduationcap.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 48, height: 48)
                                .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.55))
                        }
                        
                        Text("Hem")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // HP-estimering Section
                    VStack(spacing: 16) {
                        // Title
                        Text("HP-estimering")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            // Total score (left side - larger) - removed "Totalt" text
                            VStack(spacing: 8) {
                                Text(String(format: "%.1f", calculateTotalScore()))
                                    .font(.system(size: 56, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.2))
                            )
                            
                            // KVANT and VERB scores (right side)
                            VStack(spacing: 12) {
                                // KVANT
                                HStack(spacing: 12) {
                                    Text("KVANT")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white.opacity(0.9))
                                    Spacer()
                                    Text(String(format: "%.1f", kvantScore))
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.2))
                                )
                                
                                // VERB
                                HStack(spacing: 12) {
                                    Text("VERB")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white.opacity(0.9))
                                    Spacer()
                                    Text(String(format: "%.1f", verbScore))
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.2))
                                )
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.71, green: 0.55, blue: 0.26),  // Calm dark gold/yellow
                                        Color(red: 0.78, green: 0.62, blue: 0.32)   // Slightly lighter gold
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    
                    // Countdown Timer Section
                    VStack(spacing: 16) {
                        // Title with clock icon
                        HStack(spacing: 8) {
                            Text("Tid kvar till vårens HP")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Countdown display
                        HStack(spacing: 12) {
                            // Days
                            TimeUnitView(value: timeComponents.days, unit: "dagar")
                            
                            // Separator
                            Text(":")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                            
                            // Hours
                            TimeUnitView(value: timeComponents.hours, unit: "timmar")
                            
                            // Separator
                            Text(":")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                            
                            // Minutes
                            TimeUnitView(value: timeComponents.minutes, unit: "minuter")
                            
                            // Separator
                            Text(":")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                            
                            // Seconds
                            TimeUnitView(value: timeComponents.seconds, unit: "sekunder")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0.1, green: 0.25, blue: 0.55))  // Dark blue
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    
                    // Dagens Ord Section
                    VStack(spacing: 20) {
                        // Header with title and streak
                        HStack {
                            Text("Dagens Ord")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Streak counter
                            HStack(spacing: 8) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.0))
                                Text("\(streak)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.29, green: 0.34, blue: 0.42))
                            )
                        }
                        
                        // Word display
                        Text(todaysWord.word)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.29, green: 0.34, blue: 0.42))
                            )
                        
                        // Answer alternatives
                        VStack(spacing: 12) {
                            ForEach(Array(todaysWord.alternatives.enumerated()), id: \.element) { index, alternative in
                                DagensOrdAnswerButton(
                                    letter: String(UnicodeScalar(65 + index)!),  // A, B, C, D, E
                                    text: alternative,
                                    isSelected: selectedAnswer == alternative,
                                    isCorrect: hasAnswered ? alternative == todaysWord.correctAnswer : nil,
                                    isWrong: hasAnswered ? (selectedAnswer == alternative && alternative != todaysWord.correctAnswer) : nil
                                ) {
                                    if !hasAnswered {
                                        selectedAnswer = alternative
                                        hasAnswered = true
                                        showFeedback = true
                                        
                                        // Update streak if correct
                                        if alternative == todaysWord.correctAnswer {
                                            updateStreak()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Countdown to next word
                        HStack(spacing: 8) {
                            Text("Ett nytt ord väntar imorgon")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            Image(systemName: "calendar")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0.40, green: 0.45, blue: 0.54))
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 24)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .onAppear {
                updateTimeRemaining()
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        let now = Date()
        timeRemaining = targetDate.timeIntervalSince(now)
        
        // Stop timer if countdown is complete
        if timeRemaining <= 0 {
            timeRemaining = 0
            timer?.invalidate()
        }
    }
    
    private func updateStreak() {
        let today = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)
        
        // Check if we already completed today
        if lastCompletedDateString == todayString {
            // Already completed today - don't update
            return
        }
        
        if lastCompletedDateString.isEmpty {
            // First time ever
            streak = 1
        } else if let lastDate = dateFormatter.date(from: lastCompletedDateString) {
            // Get the start of both days for accurate comparison
            let lastDateStart = calendar.startOfDay(for: lastDate)
            let todayStart = calendar.startOfDay(for: today)
            
            let daysBetween = calendar.dateComponents([.day], from: lastDateStart, to: todayStart).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive day - increase streak
                streak += 1
            } else if daysBetween > 1 {
                // Missed days - reset streak
                streak = 1
            } else {
                // Same day (shouldn't happen due to check above, but just in case)
                return
            }
        } else {
            // Invalid date stored - reset
            streak = 1
        }
        
        // Update the last completed date
        lastCompletedDateString = todayString
    }
    
    // Calculate total HP score: (KVANT + VERB) / 2
    private func calculateTotalScore() -> Double {
        return (kvantScore + verbScore) / 2.0
    }
}

// MARK: - Time Unit View Component
struct TimeUnitView: View {
    let value: Int
    let unit: String
    
    // Map full unit names to abbreviations
    private var abbreviatedUnit: String {
        switch unit {
        case "dagar": return "d"
        case "timmar": return "h"
        case "minuter": return "m"
        case "sekunder": return "s"
        default: return unit
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Value
            Text(String(format: "%02d", value))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(minWidth: 50)
            
            // Unit label (abbreviated)
            Text(abbreviatedUnit)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Dagens Ord Answer Button Component
struct DagensOrdAnswerButton: View {
    let letter: String
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let isWrong: Bool?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text("\(letter))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let isCorrect = isCorrect, isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                if let isWrong = isWrong, isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isCorrect == true ? Color(red: 0.2, green: 0.78, blue: 0.35) :  // Solid green
                        isWrong == true ? Color(red: 0.95, green: 0.27, blue: 0.27) :  // Solid red
                        Color(red: 0.29, green: 0.34, blue: 0.42)  // Dark blue (unselected)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isCorrect != nil || isWrong != nil)
    }
}

struct OvaView: View {
    @State private var animateCards = false
    @State private var selectedCount = 10  // Default selection
    @State private var selectedSections: Set<Int> = []  // Track selected section IDs
    @State private var showingCountSheet = false  // For the popup sheet
    @State private var animateStats = false  // For stats animation
    @State private var navigateToPractice = false  // For navigation to practice view
    @State private var showingExerciseBreakdown = false  // For exercise breakdown popup
    @State private var showingAccuracyBreakdown = false  // For accuracy breakdown popup
    
    // Arbitrary stats for gamification
    let completedExercises = 127
    let accuracy = 78.5
    
    // Section-specific stats
    // VERB sections (ORD, LÄS, MEK, ELF)
    let exercisesBySection: [String: Int] = [
        "ORD": 23,
        "LÄS": 18,
        "MEK": 15,
        "ELF": 12,
        "XYZ": 21,
        "KVA": 16,
        "NOG": 14,
        "DTK": 8
    ]
    
    // Accuracy by section (must average to 78.5%)
    let accuracyBySection: [String: Double] = [
        "ORD": 82.3,
        "LÄS": 75.8,
        "MEK": 81.2,
        "ELF": 73.5,
        "XYZ": 79.4,
        "KVA": 76.9,
        "NOG": 80.1,
        "DTK": 78.8
    ]
    
    // 8 Högskoleprovet sections
    // KVANT sections (red): XYZ, KVA, NOG, DTK (ids 1-4)
    // VERB sections (blue): ORD, LÄS, MEK, ELF (ids 5-8)
    let allSections: [HPSection] = [
        HPSection(id: 1, code: "XYZ", iconName: "pi"),
        HPSection(id: 2, code: "KVA", iconName: "pencil.and.scribble"),
        HPSection(id: 3, code: "NOG", iconName: "brain.fill"),
        HPSection(id: 4, code: "DTK", iconName: "chart.pie"),
        HPSection(id: 5, code: "ORD", iconName: "lightbulb"),
        HPSection(id: 6, code: "LÄS", iconName: "character.text.justify"),
        HPSection(id: 7, code: "MEK", iconName: "puzzlepiece"),
        HPSection(id: 8, code: "ELF", iconName: "book")
    ]
    
    // Computed properties for left and right columns
    var leftSections: [HPSection] {
        Array(allSections.prefix(4))
    }
    
    var rightSections: [HPSection] {
        Array(allSections.suffix(4))
    }
    
    // Helper function to determine section color
    func sectionColor(for sectionId: Int) -> Color {
        // All sections use dark blue
        return Color(red: 0.1, green: 0.25, blue: 0.55)  // Darker blue for all sections
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    statisticsSection
                    sectionTitleView
                    sectionCardsGrid
                    
                    // Extra bottom spacing for the floating button
                    if !selectedSections.isEmpty {
                        Spacer()
                            .frame(height: 80)
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .overlay(alignment: .bottom) {
                floatingPlayButton
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedSections.isEmpty)
            .onAppear {
                animateCards = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        animateStats = true
                    }
                }
            }
            .sheet(isPresented: $showingCountSheet) {
                CountSelectionSheet(selectedCount: $selectedCount, onStart: {
                    showingCountSheet = false
                    navigateToPractice = true
                })
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
            }
            .overlay {
                if showingExerciseBreakdown {
                    StatsBreakdownOverlay(
                        title: "Övningar per delprov",
                        sections: ["ORD", "LÄS", "MEK", "ELF", "XYZ", "KVA", "NOG", "DTK"],
                        values: exercisesBySection.mapValues { Double($0) },

                        isPercentage: false,
                        onDismiss: {
                            showingExerciseBreakdown = false
                        }
                    )
                }
                
                if showingAccuracyBreakdown {
                    StatsBreakdownOverlay(
                        title: "Träffsäkerhet per delprov",
                        sections: ["ORD", "LÄS", "MEK", "ELF", "XYZ", "KVA", "NOG", "DTK"],
                        values: accuracyBySection,
                        isPercentage: true,
                        onDismiss: {
                            showingAccuracyBreakdown = false
                        }
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToPractice) {
                PracticeView(
                    selectedSections: Array(selectedSections),
                    questionCount: selectedCount
                )
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack {
            Text("Öva")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }
    
    private var statisticsSection: some View {
        VStack(spacing: 20) {
            // Title row
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.55))
                Text("Din statistik")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                Spacer()
            }
            
            HStack(spacing: 16) {
                exerciseStatsCard
                accuracyStatsCard
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(red: 0.898, green: 0.898, blue: 0.898), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
    
    private var exerciseStatsCard: some View {
        Button(action: {
            showingExerciseBreakdown = true
        }) {
            VStack(spacing: 12) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.55))
                
                Text("\(completedExercises)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    .scaleEffect(animateStats ? 1.0 : 0.5)
                    .opacity(animateStats ? 1.0 : 0.0)
                
                Text("övningar")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.25, blue: 0.55).opacity(0.1),
                                Color(red: 0.1, green: 0.25, blue: 0.55).opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.1, green: 0.25, blue: 0.55).opacity(0.3), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private var accuracyStatsCard: some View {
        Button(action: {
            showingAccuracyBreakdown = true
        }) {
            VStack(spacing: 12) {
                Image(systemName: "target")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                
                HStack(spacing: 4) {
                    Text(String(format: "%.1f", accuracy))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        .scaleEffect(animateStats ? 1.0 : 0.5)
                        .opacity(animateStats ? 1.0 : 0.0)
                    Text("%")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.6))
                        .offset(y: 2)
                        .scaleEffect(animateStats ? 1.0 : 0.5)
                        .opacity(animateStats ? 1.0 : 0.0)
                }
                
                Text("träffsäkerhet")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.1),
                                Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.3), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private var sectionTitleView: some View {
        HStack {
            Text("Välj vilka områden du vill träna på")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.6))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var sectionCardsGrid: some View {
        HStack(spacing: 16) {
            leftColumn
            rightColumn
        }
        .padding(.horizontal, 20)
    }
    
    private var leftColumn: some View {
        VStack(spacing: 16) {
            ForEach(leftSections.indices, id: \.self) { index in
                let section = leftSections[index]
                SectionCard(
                    section: section,
                    isCompact: true,
                    isSelected: selectedSections.contains(section.id),
                    accentColor: sectionColor(for: section.id),
                    onTap: {
                        if selectedSections.contains(section.id) {
                            selectedSections.remove(section.id)
                        } else {
                            selectedSections.insert(section.id)
                        }
                    }
                )
                .offset(y: animateCards ? 0 : 50)
                .opacity(animateCards ? 1 : 0)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                        .delay(Double(index) * 0.1),
                    value: animateCards
                )
            }
        }
    }
    
    private var rightColumn: some View {
        VStack(spacing: 16) {
            ForEach(rightSections.indices, id: \.self) { index in
                let section = rightSections[index]
                SectionCard(
                    section: section,
                    isCompact: true,
                    isSelected: selectedSections.contains(section.id),
                    accentColor: sectionColor(for: section.id),
                    onTap: {
                        if selectedSections.contains(section.id) {
                            selectedSections.remove(section.id)
                        } else {
                            selectedSections.insert(section.id)
                        }
                    }
                )
                .offset(y: animateCards ? 0 : 50)
                .opacity(animateCards ? 1 : 0)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                        .delay(Double(index + 4) * 0.1),
                    value: animateCards
                )
            }
        }
    }
    
    @ViewBuilder
    private var floatingPlayButton: some View {
        if !selectedSections.isEmpty {
            Button(action: {
                showingCountSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("Starta övning")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                )
                .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
            }
            .padding(.bottom, 40)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - Practice View
// This view handles practice sessions for selected sections
struct PracticeView: View {
    let selectedSections: [Int]  // Array of section IDs
    let questionCount: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestion = 1
    @State private var selectedAnswer: String? = nil
    @State private var showingExitAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    Button(action: { 
                        showingExitAlert = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                            Text("Avsluta")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                        )
                    }
                    
                    Spacer()
                    
                    Text("\(currentQuestion)/\(questionCount)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                            .frame(width: geometry.size.width * CGFloat(currentQuestion) / CGFloat(questionCount), height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 16)
            .background(Color.white)
            
            // Question content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Fråga \(currentQuestion)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    
                    Text("This is a placeholder for practice question content. Questions will be from the selected sections: \(sectionNames)")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        .lineSpacing(4)
                    
                    // Show DTK image if this would be a DTK question
                    if isDTKSection {
                        Button(action: {
                            // Show image fullscreen
                        }) {
                            VStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                                        .frame(height: 220)
                                    
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo")
                                            .font(.system(size: 48, weight: .medium))
                                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.3))
                                        
                                        Text("DTK Diagram/Bild")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.5))
                                        
                                        Text("Tryck för att förstora")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.4))
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.898, green: 0.898, blue: 0.898), lineWidth: 2)
                                )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Answer options
                    VStack(spacing: 12) {
                        ForEach(answerOptions, id: \.self) { option in
                            AnswerButton(
                                option: option,
                                isSelected: selectedAnswer == option,
                                text: nil,  // Will use placeholder text
                                imageName: nil  // Set to image filename when loading from database
                            ) {
                                if selectedAnswer == option {
                                    selectedAnswer = nil
                                } else {
                                    selectedAnswer = option
                                }
                            }
                        }
                    }
                    
                    // Section badges at bottom
                    HStack(spacing: 8) {
                        ForEach(selectedSections, id: \.self) { sectionId in
                            if let sectionName = getSectionName(for: sectionId) {
                                Text(sectionName)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.55))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                                    )
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            
            // Bottom navigation
            HStack(spacing: 16) {
                if currentQuestion > 1 {
                    Button(action: {
                        currentQuestion -= 1
                        selectedAnswer = nil
                    }) {
                        Text("Föregående")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.0, green: 0.48, blue: 1.0), lineWidth: 2)
                            )
                    }
                }
                
                if selectedAnswer != nil {
                    Button(action: {
                        if currentQuestion < questionCount {
                            currentQuestion += 1
                            selectedAnswer = nil
                        } else {
                            // Finish practice
                            dismiss()
                        }
                    }) {
                        Text(currentQuestion < questionCount ? "Nästa" : "Avsluta")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .overlay {
            if showingExitAlert {
                ConfirmationOverlay(
                    title: "Avsluta övning?",
                    message: "Ditt framsteg kommer inte att sparas.",
                    iconName: "exclamationmark.triangle.fill",
                    iconColor: Color(red: 1.0, green: 0.6, blue: 0.0),
                    confirmButtonText: "Avsluta",
                    confirmButtonColor: Color(red: 0.95, green: 0.27, blue: 0.27),
                    cancelButtonText: "Fortsätt öva",
                    onConfirm: {
                        dismiss()
                    },
                    onCancel: {
                        showingExitAlert = false
                    }
                )
            }
        }
    }
    
    // Helper to check if DTK section is selected
    private var isDTKSection: Bool {
        selectedSections.contains(4)  // DTK is section ID 4
    }
    
    // Helper to get section names as a comma-separated string
    private var sectionNames: String {
        selectedSections.compactMap { getSectionName(for: $0) }.joined(separator: ", ")
    }
    
    // Helper to get section name from ID
    private func getSectionName(for id: Int) -> String? {
        let sections = [
            1: "XYZ", 2: "KVA", 3: "NOG", 4: "DTK",
            5: "ORD", 6: "LÄS", 7: "MEK", 8: "ELF"
        ]
        return sections[id]
    }
    
    // Answer options based on selected sections
    private var answerOptions: [String] {
        // ORD (5) and NOG (3) have 5 options
        if selectedSections.contains(5) || selectedSections.contains(3) {
            return ["A", "B", "C", "D", "E"]
        }
        return ["A", "B", "C", "D"]
    }
}

// MARK: - Count Selection Sheet
struct CountSelectionSheet: View {
    @Binding var selectedCount: Int
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Title
            HStack {
                Text("Antal övningar")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Number circles
            HStack(spacing: 12) {
                NumberCircle(number: "5", isSelected: selectedCount == 5) {
                    selectedCount = 5
                }
                NumberCircle(number: "10", isSelected: selectedCount == 10) {
                    selectedCount = 10
                }
                NumberCircle(number: "20", isSelected: selectedCount == 20) {
                    selectedCount = 20
                }
                NumberCircle(number: "40", isSelected: selectedCount == 40) {
                    selectedCount = 40
                }
            }
            .padding(.horizontal, 20)
            
            // Start button
            Button(action: onStart) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Starta")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.1, green: 0.25, blue: 0.55))  // Changed to blue
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }
}

// MARK: - Number Circle Component
struct NumberCircle: View {
    let number: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color(red: 0.11, green: 0.11, blue: 0.118) : Color.white)
                    .frame(width: 44, height: 44)
                
                Text(number)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : Color(red: 0.11, green: 0.11, blue: 0.118))
            }
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Play Button Component
struct PlayButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.1, green: 0.25, blue: 0.55))  // Changed to blue
                    .frame(width: 44, height: 44)
                
                Image(systemName: "play.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: 1)  // Slight offset to center the play icon visually
            }
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

struct ProvView: View {
    // Historical test data with provpass numbers
    let historicalTests: [HistoricalTest] = [
        HistoricalTest(year: "2025", semester: "HT", kvant1: 1, kvant2: 4, verb1: 3, verb2: 5),
        HistoricalTest(year: "2025", semester: "VT", kvant1: 3, kvant2: 5, verb1: 2, verb2: 4),
        HistoricalTest(year: "2024", semester: "HT", kvant1: 1, kvant2: 4, verb1: 3, verb2: 5),
        HistoricalTest(year: "2024", semester: "VT", kvant1: 2, kvant2: 5, verb1: 1, verb2: 4),
        HistoricalTest(year: "2023", semester: "HT", kvant1: 2, kvant2: 4, verb1: 3, verb2: 5),
        HistoricalTest(year: "2023", semester: "VT", kvant1: 2, kvant2: 4, verb1: 3, verb2: 5),
        HistoricalTest(year: "2022", semester: "HT", kvant1: 1, kvant2: 4, verb1: 2, verb2: 5),
        HistoricalTest(year: "2022", semester: "VT", kvant1: 1, kvant2: 4, verb1: 3, verb2: 5)
    ]
    
    @Environment(\.modelContext) private var modelContext
    @Query private var allSessions: [TestSession]
    
    @State private var showingGeneratedTestSheet = false
    @State private var selectedGeneratedTestType = "KVANT"
    @State private var navigateToGeneratedTest = false
    @State private var timerEnabledForGenerated = true
    @State private var showingRestartAlert = false
    @State private var testToRestart: HistoricalTest?
    @State private var showingGeneratedRestartAlert = false
    @State private var generatedTestTypeToRestart: String?
    @State private var animateCards = false
    @State private var hasAnimated = false  // Track if animation has been shown
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header section - left aligned (matching Spela layout exactly)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Prov")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        
                        Text("Generera ett övningsprov")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                    
                    // Two test sections in a row
                    HStack(spacing: 16) {
                        // KVANT (Grey)
                        ProvCard(
                            title: "KVANT",
                            iconName: "wand.and.stars",
                            hasProgress: hasGeneratedProgress(for: "KVANT"),
                            onRestart: {
                                generatedTestTypeToRestart = "KVANT"
                                showingGeneratedRestartAlert = true
                            }
                        ) {
                            selectedGeneratedTestType = "KVANT"
                            showingGeneratedTestSheet = true
                        }
                        
                        // VERB (Grey)
                        ProvCard(
                            title: "VERB",
                            iconName: "sparkles",
                            hasProgress: hasGeneratedProgress(for: "VERB"),
                            onRestart: {
                                generatedTestTypeToRestart = "VERB"
                                showingGeneratedRestartAlert = true
                            }
                        ) {
                            selectedGeneratedTestType = "VERB"
                            showingGeneratedTestSheet = true
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Gamla Högskoleprov section
                    VStack(spacing: 16) {
                        // Section title
                        HStack {
                            Text("Gamla Högskoleprov")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Grid of historical tests - 2 columns x 4 rows
                        VStack(spacing: 16) {
                            // Row 1: HT 2025, VT 2025
                            HStack(spacing: 16) {
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[0])) {
                                    HistoricalProvCard(
                                        year: "2025",
                                        semester: "HT",
                                        hasProgress: hasProgress(for: historicalTests[0]),
                                        onRestart: {
                                            testToRestart = historicalTests[0]
                                            showingRestartAlert = true
                                        }
                                    )
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    // Navigation handled by NavigationLink
                                })
                                .offset(y: animateCards ? 0 : 50)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                                        .delay(0.0),
                                    value: animateCards
                                )
                                
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[1])) {
                                    HistoricalProvCard(
                                        year: "2025",
                                        semester: "VT",
                                        hasProgress: hasProgress(for: historicalTests[1]),
                                        onRestart: {
                                            testToRestart = historicalTests[1]
                                            showingRestartAlert = true
                                        }
                                    )
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    // Navigation handled by NavigationLink
                                })
                                .offset(y: animateCards ? 0 : 50)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                                        .delay(0.1),
                                    value: animateCards
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            // Row 2: HT 2024, VT 2024
                            HStack(spacing: 16) {
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[2])) {
                                    HistoricalProvCard(
                                        year: "2024",
                                        semester: "HT",
                                        hasProgress: hasProgress(for: historicalTests[2]),
                                        onRestart: {
                                            testToRestart = historicalTests[2]
                                            showingRestartAlert = true
                                        }
                                    )
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    // Navigation handled by NavigationLink
                                })
                                .offset(y: animateCards ? 0 : 50)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                                        .delay(0.2),
                                    value: animateCards
                                )
                                
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[3])) {
                                    HistoricalProvCard(
                                        year: "2024",
                                        semester: "VT",
                                        hasProgress: hasProgress(for: historicalTests[3]),
                                        onRestart: {
                                            testToRestart = historicalTests[3]
                                            showingRestartAlert = true
                                        }
                                    )
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    // Navigation handled by NavigationLink
                                })
                                .offset(y: animateCards ? 0 : 50)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                                        .delay(0.3),
                                    value: animateCards
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            // Row 3: HT 2023, VT 2023
                            HStack(spacing: 16) {
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[4])) {
                                    HistoricalProvCard(
                                        year: "2023",
                                        semester: "HT",
                                        hasProgress: hasProgress(for: historicalTests[4]),
                                        onRestart: {
                                            testToRestart = historicalTests[4]
                                            showingRestartAlert = true
                                        }
                                    )
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    // Navigation handled by NavigationLink
                                })
                                .offset(y: animateCards ? 0 : 50)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                                        .delay(0.4),
                                    value: animateCards
                                )
                                
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[5])) {
                                    HistoricalProvCard(
                                        year: "2023",
                                        semester: "VT",
                                        hasProgress: hasProgress(for: historicalTests[5]),
                                        onRestart: {
                                            testToRestart = historicalTests[5]
                                            showingRestartAlert = true
                                        }
                                    )
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    // Navigation handled by NavigationLink
                                })
                                .offset(y: animateCards ? 0 : 50)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                                        .delay(0.5),
                                    value: animateCards
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            // Row 4: HT 2022, VT 2022
                            HStack(spacing: 16) {
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[6])) {
                                    HistoricalProvCard(
                                        year: "2022",
                                        semester: "HT",
                                        hasProgress: hasProgress(for: historicalTests[6]),
                                        onRestart: {
                                            testToRestart = historicalTests[6]
                                            showingRestartAlert = true
                                        }
                                    )
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    // Navigation handled by NavigationLink
                                })
                                .offset(y: animateCards ? 0 : 50)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                                        .delay(0.6),
                                    value: animateCards
                                )
                                
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[7])) {
                                    HistoricalProvCard(
                                        year: "2022",
                                        semester: "VT",
                                        hasProgress: hasProgress(for: historicalTests[7]),
                                        onRestart: {
                                            testToRestart = historicalTests[7]
                                            showingRestartAlert = true
                                        }
                                    )
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    // Navigation handled by NavigationLink
                                })
                                .offset(y: animateCards ? 0 : 50)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)
                                        .delay(0.7),
                                    value: animateCards
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .onAppear {
                // Only animate on first appearance
                if !hasAnimated {
                    animateCards = true
                    hasAnimated = true
                }
            }
            .sheet(isPresented: $showingGeneratedTestSheet) {
                GeneratedProvInfoSheet(
                    type: selectedGeneratedTestType,
                    timerEnabled: $timerEnabledForGenerated,
                    onStart: {
                        showingGeneratedTestSheet = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToGeneratedTest = true
                        }
                    }
                )
                .presentationDetents([.height(240)])
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $navigateToGeneratedTest) {
                TestView(type: selectedGeneratedTestType, provpassNumber: 0, timerEnabled: timerEnabledForGenerated)
            }
            .overlay {
                if showingRestartAlert, let test = testToRestart {
                    ConfirmationOverlay(
                        title: "Börja om prov?",
                        message: "Detta kommer radera allt sparat framsteg för detta prov.",
                        iconName: "arrow.counterclockwise",
                        iconColor: Color(red: 1.0, green: 0.6, blue: 0.0),
                        confirmButtonText: "Börja om",
                        confirmButtonColor: Color(red: 0.95, green: 0.27, blue: 0.27),
                        cancelButtonText: "Avbryt",
                        onConfirm: {
                            restartAllSessionsForTest(test)
                            showingRestartAlert = false
                        },
                        onCancel: {
                            showingRestartAlert = false
                            testToRestart = nil
                        }
                    )
                }
                
                if showingGeneratedRestartAlert, let testType = generatedTestTypeToRestart {
                    ConfirmationOverlay(
                        title: "Börja om prov?",
                        message: "Detta kommer radera allt sparat framsteg för detta genererade prov.",
                        iconName: "arrow.counterclockwise",
                        iconColor: Color(red: 1.0, green: 0.6, blue: 0.0),
                        confirmButtonText: "Börja om",
                        confirmButtonColor: Color(red: 0.95, green: 0.27, blue: 0.27),
                        cancelButtonText: "Avbryt",
                        onConfirm: {
                            restartGeneratedTest(testType)
                            showingGeneratedRestartAlert = false
                        },
                        onCancel: {
                            showingGeneratedRestartAlert = false
                            generatedTestTypeToRestart = nil
                        }
                    )
                }
            }
        }
    }
    
    // Helper to check if any progress exists for a generated test
    private func hasGeneratedProgress(for type: String) -> Bool {
        allSessions.contains { session in
            !session.isCompleted &&
            session.testType == type &&
            session.provpassNumber == 0  // Generated tests have provpassNumber 0
        }
    }
    
    // Helper to check if any progress exists for a historical test
    private func hasProgress(for test: HistoricalTest) -> Bool {
        allSessions.contains { session in
            !session.isCompleted &&
            session.historicalTestYear == test.year &&
            session.historicalTestSemester == test.semester
        }
    }
    
    // Restart generated test
    private func restartGeneratedTest(_ testType: String) {
        let sessionsToDelete = allSessions.filter { session in
            session.testType == testType &&
            session.provpassNumber == 0
        }
        
        for session in sessionsToDelete {
            modelContext.delete(session)
        }
        
        do {
            try modelContext.save()
            print("✅ Deleted \(sessionsToDelete.count) generated \(testType) sessions")
        } catch {
            print("❌ Error deleting generated sessions: \(error)")
        }
        
        generatedTestTypeToRestart = nil
    }
    
    // Restart all sessions for a test
    private func restartAllSessionsForTest(_ test: HistoricalTest) {
        let sessionsToDelete = allSessions.filter { session in
            session.historicalTestYear == test.year &&
            session.historicalTestSemester == test.semester
        }
        
        for session in sessionsToDelete {
            modelContext.delete(session)
        }
        
        do {
            try modelContext.save()
            print("✅ Deleted \(sessionsToDelete.count) sessions for \(test.semester) \(test.year)")
        } catch {
            print("❌ Error deleting sessions: \(error)")
        }
        
        testToRestart = nil
    }
}

// MARK: - Generated Prov Info Sheet
struct GeneratedProvInfoSheet: View {
    let type: String
    @Binding var timerEnabled: Bool
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Title
            HStack {
                Text("\(type)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Info box
            VStack(spacing: 12) {
                // Questions info
                HStack {
                    Text("Provet består av 40 frågor")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    Spacer()
                }
                
                // Time info with toggle - subtle border style
                HStack {
                    Image(systemName: "timer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    Text("Det tar 55 minuter")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    
                    Spacer()
                    
                    // Custom subtle toggle
                    Button(action: {
                        timerEnabled.toggle()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: timerEnabled ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(timerEnabled ? Color(red: 0.2, green: 0.78, blue: 0.35) : Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.3))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.969, green: 0.969, blue: 0.969))
            )
            .padding(.horizontal, 20)
            
            // Start button
            Button(action: onStart) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Starta prov")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }
}

// MARK: - Prov Card Component
struct ProvCard: View {
    let title: String
    let iconName: String
    var hasProgress: Bool = false
    var onRestart: (() -> Void)? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                VStack(spacing: 16) {
                    // Large icon
                    Image(systemName: iconName)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    
                    // Title text below icon
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        .multilineTextAlignment(.center)
                    
                    // Progress indicator
                    if hasProgress {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Startad")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.15))
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))  // Light grey
                )
                
                // Restart button overlay
                if hasProgress, let onRestart = onRestart {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                onRestart()
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                                    )
                            }
                            .padding(12)
                        }
                        Spacer()
                    }
                }
            }
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Historical Test Data Model
struct HistoricalTest: Identifiable {
    let id = UUID()
    let year: String
    let semester: String
    let kvant1: Int
    let kvant2: Int
    let verb1: Int
    let verb2: Int
}

// MARK: - Historical Prov Card Component
struct HistoricalProvCard: View {
    let year: String
    let semester: String
    var hasProgress: Bool = false
    var onRestart: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Base background - darker blue-grey
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.29, green: 0.34, blue: 0.42))  // Darker blue-grey #4A5669
            
            // Half circle overlay - lighter blue-grey, from right to middle
            GeometryReader { geometry in
                Circle()
                    .fill(Color(red: 0.40, green: 0.45, blue: 0.54))  // Lighter blue-grey #66738A
                    .frame(width: geometry.size.height * 1.4, height: geometry.size.height * 1.4)
                    .offset(x: geometry.size.width * 0.3, y: -geometry.size.height * 0.2)
            }
            .opacity(0.8)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Content
            VStack(spacing: 12) {
                // Year and semester on the same row
                HStack(spacing: 8) {
                    Text(semester)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(year)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Small archive icon
                Image(systemName: "archivebox.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                // Progress indicator
                if hasProgress {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Pågående")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.25))
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            
            // Restart button overlay
            if hasProgress, let onRestart = onRestart {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            onRestart()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                )
                        }
                        .padding(12)
                    }
                    Spacer()
                }
            }
        }
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Historical Test Detail View
struct HistoricalTestDetailView: View {
    let test: HistoricalTest
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allSessions: [TestSession]
    
    @State private var showingProvpassSheet = false
    @State private var selectedProvpass: (type: String, number: Int)? = nil
    @State private var selectedProvpassType: String = "KVANT"
    @State private var selectedProvpassNumber: Int = 1
    @State private var navigateToTest = false
    @State private var resumeSession: TestSession?
    
    @State private var timerEnabledInSheet = true
    @State private var showingRestartAlert = false
    @State private var sessionToRestart: TestSession?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                            Text("Tillbaka")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                        )
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("\(test.semester) \(test.year)")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                // KVANT section
                VStack(spacing: 16) {
                    HStack {
                        Text("KVANT")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 16) {
                        ProvpassCardWithProgress(
                            type: "KVANT",
                            provpass: test.kvant1,
                            session: findSession(type: "KVANT", provpass: test.kvant1),
                            onTap: {
                                selectedProvpassType = "KVANT"
                                selectedProvpassNumber = test.kvant1
                                resumeSession = findSession(type: "KVANT", provpass: test.kvant1)
                                showingProvpassSheet = true
                            },
                            onRestart: {
                                if let session = findSession(type: "KVANT", provpass: test.kvant1) {
                                    sessionToRestart = session
                                    showingRestartAlert = true
                                }
                            }
                        )
                        
                        ProvpassCardWithProgress(
                            type: "KVANT",
                            provpass: test.kvant2,
                            session: findSession(type: "KVANT", provpass: test.kvant2),
                            onTap: {
                                selectedProvpassType = "KVANT"
                                selectedProvpassNumber = test.kvant2
                                resumeSession = findSession(type: "KVANT", provpass: test.kvant2)
                                showingProvpassSheet = true
                            },
                            onRestart: {
                                if let session = findSession(type: "KVANT", provpass: test.kvant2) {
                                    sessionToRestart = session
                                    showingRestartAlert = true
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // VERB section
                VStack(spacing: 16) {
                    HStack {
                        Text("VERB")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 16) {
                        ProvpassCardWithProgress(
                            type: "VERB",
                            provpass: test.verb1,
                            session: findSession(type: "VERB", provpass: test.verb1),
                            onTap: {
                                selectedProvpassType = "VERB"
                                selectedProvpassNumber = test.verb1
                                resumeSession = findSession(type: "VERB", provpass: test.verb1)
                                showingProvpassSheet = true
                            },
                            onRestart: {
                                if let session = findSession(type: "VERB", provpass: test.verb1) {
                                    sessionToRestart = session
                                    showingRestartAlert = true
                                }
                            }
                        )
                        
                        ProvpassCardWithProgress(
                            type: "VERB",
                            provpass: test.verb2,
                            session: findSession(type: "VERB", provpass: test.verb2),
                            onTap: {
                                selectedProvpassType = "VERB"
                                selectedProvpassNumber = test.verb2
                                resumeSession = findSession(type: "VERB", provpass: test.verb2)
                                showingProvpassSheet = true
                            },
                            onRestart: {
                                if let session = findSession(type: "VERB", provpass: test.verb2) {
                                    sessionToRestart = session
                                    showingRestartAlert = true
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 24)
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .sheet(isPresented: $showingProvpassSheet) {
            ProvpassInfoSheet(
                type: selectedProvpassType,
                provpassNumber: selectedProvpassNumber,
                timerEnabled: $timerEnabledInSheet,
                hasExistingSession: resumeSession != nil,
                onStart: {
                    showingProvpassSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        navigateToTest = true
                    }
                }
            )
            .presentationDetents([.height(resumeSession != nil ? 280 : 240)])
            .presentationDragIndicator(.visible)
        }
        .overlay {
            if showingRestartAlert, let session = sessionToRestart {
                ConfirmationOverlay(
                    title: "Börja om delprov?",
                    message: "Detta kommer radera ditt sparade framsteg för detta delprov.",
                    iconName: "arrow.counterclockwise",
                    iconColor: Color(red: 1.0, green: 0.6, blue: 0.0),
                    confirmButtonText: "Börja om",
                    confirmButtonColor: Color(red: 0.95, green: 0.27, blue: 0.27),
                    cancelButtonText: "Avbryt",
                    onConfirm: {
                        restartSession(session)
                        showingRestartAlert = false
                    },
                    onCancel: {
                        showingRestartAlert = false
                        sessionToRestart = nil
                    }
                )
            }
        }
        .navigationDestination(isPresented: $navigateToTest) {
            TestView(
                type: selectedProvpassType,
                provpassNumber: selectedProvpassNumber,
                timerEnabled: timerEnabledInSheet,
                historicalTest: test,
                existingSession: resumeSession
            )
        }
    }
    
    // Find saved session for specific test
    private func findSession(type: String, provpass: Int) -> TestSession? {
        allSessions.first { session in
            !session.isCompleted &&
            session.testType == type &&
            session.provpassNumber == provpass &&
            session.historicalTestYear == test.year &&
            session.historicalTestSemester == test.semester
        }
    }
    
    // Restart a session
    private func restartSession(_ session: TestSession) {
        modelContext.delete(session)
        try? modelContext.save()
        sessionToRestart = nil
    }
}

// MARK: - Provpass Info Sheet
struct ProvpassInfoSheet: View {
    let type: String
    let provpassNumber: Int
    @Binding var timerEnabled: Bool
    let hasExistingSession: Bool
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Title
            HStack {
                Text("\(type) - Provpass \(provpassNumber)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Info box
            VStack(spacing: 12) {
                // Questions info
                HStack {
                    Text("Provet består av 40 frågor")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    Spacer()
                }
                
                // Resume indicator
                if hasExistingSession {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                        Text("Du kommer fortsätta där du slutade")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                        Spacer()
                    }
                }
                
                // Time info with toggle - subtle border style
                HStack {
                    Image(systemName: "timer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    Text("Det tar 55 minuter")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    
                    Spacer()
                    
                    // Custom subtle toggle
                    Button(action: {
                        timerEnabled.toggle()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: timerEnabled ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(timerEnabled ? Color(red: 0.2, green: 0.78, blue: 0.35) : Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.3))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.969, green: 0.969, blue: 0.969))
            )
            .padding(.horizontal, 20)
            
            // Start button
            Button(action: onStart) {
                HStack(spacing: 12) {
                    Image(systemName: hasExistingSession ? "play.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text(hasExistingSession ? "Fortsätt" : "Starta prov")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(hasExistingSession ? Color(red: 0.2, green: 0.78, blue: 0.35) : Color(red: 0.1, green: 0.25, blue: 0.55))
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }
}

// MARK: - Provpass Card Component
struct ProvpassCard: View {
    let type: String
    let provpass: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Type text
                Text(type)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                
                // Provpass text
                Text("Provpass \(provpass)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.95, green: 0.95, blue: 0.95))  // Light grey
            )
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Provpass Card With Progress Component
struct ProvpassCardWithProgress: View {
    let type: String
    let provpass: Int
    let session: TestSession?
    let onTap: () -> Void
    var onRestart: (() -> Void)? = nil
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                VStack(spacing: 12) {
                    // Type text
                    Text(type)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    
                    // Provpass text
                    Text("Provpass \(provpass)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.6))
                    
                    // Progress indicator
                    if session != nil {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Startad")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.15))
                        )
                        .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                )
                
                // Restart button overlay
                if session != nil, let onRestart = onRestart {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                onRestart()
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                                    )
                            }
                            .padding(12)
                        }
                        Spacer()
                    }
                }
            }
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Test View
struct TestView: View {
    let type: String
    let provpassNumber: Int
    let timerEnabled: Bool
    var historicalTest: HistoricalTest? = nil  // Optional historical test for date display
    var existingSession: TestSession? = nil  // For resuming saved progress
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentQuestion = 1
    @State private var selectedAnswer: String? = nil
    @State private var timeRemaining: TimeInterval = 55 * 60 // 55 minutes in seconds
    @State private var timer: Timer?
    @State private var showingExitAlert = false
    @State private var testSession: TestSession?
    @State private var answerHistory: [Int: String] = [:]  // questionNumber -> selectedOption
    @State private var showingImageFullScreen = false  // For DTK image zoom
    @State private var imageScale: CGFloat = 1.0  // For image tap animation
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with timer and progress
            VStack(spacing: 12) {
                HStack {
                    Button(action: { 
                        showingExitAlert = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                            Text("Avsluta")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                        )
                    }
                    
                    Spacer()
                    
                    if timerEnabled {
                        Text(timeString(from: timeRemaining))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    }
                    
                    Spacer()
                    
                    Text("\(currentQuestion)/40")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                            .frame(width: geometry.size.width * CGFloat(currentQuestion) / 40.0, height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 16)
            .background(Color.white)
            
            // Question content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Question text
                    
                    Text("Fråga \(currentQuestion)-\(sectionCode(for: currentQuestion))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    
                    Text("This is a placeholder for the actual question content. The real implementation would load questions from a data source.")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        .lineSpacing(4)
                    
                    // DTK Image Block - only show for DTK questions
                    if isDTKQuestion(currentQuestion) {
                        Button(action: {
                            // Scale up animation
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                imageScale = 1.05
                            }
                            
                            // Show fullscreen after brief delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingImageFullScreen = true
                                // Reset scale
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    imageScale = 1.0
                                }
                            }
                        }) {
                            VStack(spacing: 12) {
                                // Placeholder image with icon
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                                        .frame(height: 220)
                                    
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo")
                                            .font(.system(size: 48, weight: .medium))
                                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.3))
                                        
                                        Text("DTK Diagram/Bild")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.5))
                                        
                                        Text("Tryck för att förstora")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.4))
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.898, green: 0.898, blue: 0.898), lineWidth: 2)
                                )
                            }
                            .scaleEffect(imageScale)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Answer options
                    VStack(spacing: 12) {
                        ForEach(answerOptions(for: currentQuestion), id: \.self) { option in
                            // When you implement database loading, replace this with:
                            // if let alternative = currentQuestionFromDB?.alternatives.first(where: { $0.letter == option }) {
                            //     AnswerButton(
                            //         option: alternative.letter,
                            //         isSelected: selectedAnswer == option,
                            //         text: alternative.alternativeText,
                            //         imageName: alternative.alternativeImageName
                            //     ) { ... }
                            // }
                            
                            AnswerButton(
                                option: option,
                                isSelected: selectedAnswer == option,
                                text: nil,  // Load from database: alternative.alternativeText
                                imageName: nil  // Load from database: alternative.alternativeImageName
                                                // Example: "kvant_2025_ht_q5_optionA.png"
                            ) {
                                // Toggle selection - tap again to deselect
                                if selectedAnswer == option {
                                    selectedAnswer = nil
                                    answerHistory.removeValue(forKey: currentQuestion)
                                } else {
                                    selectedAnswer = option
                                    answerHistory[currentQuestion] = option
                                }
                                // Auto-save after answer selection
                                saveProgress()
                            }
                        }
                    }
                    
                    // Date badge at bottom left (only for historical tests)
                    if let test = historicalTest {
                        HStack {
                            Text("\(test.semester) \(test.year)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.55))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                                )
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            
            // Bottom navigation
            HStack(spacing: 16) {
                if currentQuestion > 1 {
                    Button(action: {
                        currentQuestion -= 1
                        selectedAnswer = answerHistory[currentQuestion]
                        saveProgress()
                    }) {
                        Text("Föregående")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.0, green: 0.48, blue: 1.0), lineWidth: 2)
                            )
                    }
                }
                
                if selectedAnswer != nil {
                    Button(action: {
                        if currentQuestion < 40 {
                            currentQuestion += 1
                            selectedAnswer = answerHistory[currentQuestion]
                            saveProgress()
                        } else {
                            // Finish test - mark as completed
                            completeTest()
                            dismiss()
                        }
                    }) {
                        Text(currentQuestion < 40 ? "Nästa" : "Avsluta")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                            )
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .overlay {
            if showingExitAlert {
                ExitConfirmationOverlay(
                    onContinue: {
                        showingExitAlert = false
                    },
                    onSaveAndExit: {
                        showingExitAlert = false
                        timer?.invalidate()
                        saveProgress()
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                )
            }
            
            // Full-screen image viewer for DTK questions
            if showingImageFullScreen {
                DTKImageFullScreenView(
                    onDismiss: {
                        showingImageFullScreen = false
                    }
                )
            }
        }
        .onAppear {
            // Load existing session or create new one
            if let existing = existingSession {
                testSession = existing
                currentQuestion = existing.currentQuestionNumber
                timeRemaining = existing.timeRemaining
                // Load saved answers
                for answer in existing.answers {
                    answerHistory[answer.questionNumber] = answer.selectedOption
                }
                selectedAnswer = answerHistory[currentQuestion]
                print("📂 Loaded existing session: Question \(currentQuestion), \(answerHistory.count) answers")
            } else {
                // Create new session
                let newSession = TestSession(
                    testType: type,
                    provpassNumber: provpassNumber,
                    historicalTestYear: historicalTest?.year,
                    historicalTestSemester: historicalTest?.semester,
                    timerEnabled: timerEnabled
                )
                modelContext.insert(newSession)
                testSession = newSession
                
                // Save the new session immediately
                do {
                    try modelContext.save()
                    print("✅ New session created and saved")
                } catch {
                    print("❌ Error creating session: \(error)")
                }
            }
            
            if timerEnabled {
                startTimer()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // Helper to check if current question is a DTK question
    private func isDTKQuestion(_ questionNumber: Int) -> Bool {
        if type == "KVANT" {
            return questionNumber >= 29 && questionNumber <= 40
        }
        return false
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
                
                // Auto-save progress every 30 seconds
                if Int(timeRemaining) % 30 == 0 {
                    saveProgress()
                }
            } else {
                timer.invalidate()
                // Handle time's up - save and complete
                completeTest()
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func sectionCode(for question: Int) -> String {
        if type == "KVANT" {
            switch question {
            case 1...12:
                return "XYZ"
            case 13...24:
                return "KVA"
            case 25...28:
                return "NOG"
            case 29...40:
                return "DTK"
            default:
                return ""
            }
        } else if type == "VERB" {
            switch question {
            case 1...10:
                return "ORD"
            case 11...20:
                return "LÄS"
            case 21...30:
                return "MEK"
            case 31...40:
                return "ELF"
            default:
                return ""
            }
        }
        return ""
    }
    
    private func answerOptions(for question: Int) -> [String] {
        let section = sectionCode(for: question)
        // ORD and NOG sections have 5 options (A-E)
        if section == "ORD" || section == "NOG" {
            return ["A", "B", "C", "D", "E"]
        }
        // All other sections have 4 options (A-D)
        return ["A", "B", "C", "D"]
    }
    
    private func saveProgress() {
        guard let session = testSession else { return }
        
        // Update session details
        session.currentQuestionNumber = currentQuestion
        session.timeRemaining = timeRemaining
        session.lastUpdated = Date()
        
        // Clear old answers and add current ones
        session.answers.removeAll()
        for (questionNum, option) in answerHistory.sorted(by: { $0.key < $1.key }) {
            let answer = TestAnswer(questionNumber: questionNum, selectedOption: option)
            answer.testSession = session
            session.answers.append(answer)
            modelContext.insert(answer)
        }
        
        do {
            try modelContext.save()
            print("✅ Progress saved: Question \(currentQuestion), \(answerHistory.count) answers")
        } catch {
            print("❌ Error saving progress: \(error)")
        }
    }
    
    private func completeTest() {
        guard let session = testSession else { return }
        
        timer?.invalidate()
        
        session.isCompleted = true
        session.currentQuestionNumber = 40
        session.lastUpdated = Date()
        
        // Save all answers one final time
        session.answers.removeAll()
        for (questionNum, option) in answerHistory.sorted(by: { $0.key < $1.key }) {
            let answer = TestAnswer(questionNumber: questionNum, selectedOption: option)
            answer.testSession = session
            session.answers.append(answer)
            modelContext.insert(answer)
        }
        
        do {
            try modelContext.save()
            print("✅ Test completed and saved: \(answerHistory.count) answers")
        } catch {
            print("❌ Error completing test: \(error)")
        }
    }
}

// MARK: - Answer Button Component
struct AnswerButton: View {
    let option: String
    let isSelected: Bool
    var text: String? = nil  // Optional text - if nil, uses placeholder
    var imageName: String? = nil  // Optional image for KVANT alternatives
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Option letter
                Text(option)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? .white : Color(red: 0.11, green: 0.11, blue: 0.118))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? Color(red: 0.1, green: 0.25, blue: 0.55) : Color(red: 0.95, green: 0.95, blue: 0.95))
                    )
                
                // Content: Either image or text
                if let imageName = imageName {
                    // Image alternative (for KVANT)
                    ZStack {
                        if let uiImage = UIImage(named: imageName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 80)
                        } else {
                            // Placeholder if image not found
                            VStack(spacing: 4) {
                                Image(systemName: "photo")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.3))
                                Text(imageName)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.4))
                            }
                            .frame(maxHeight: 80)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    // Text alternative (standard)
                    Text(text ?? "Svar alternativ \(option)")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(red: 0.1, green: 0.25, blue: 0.55).opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(red: 0.1, green: 0.25, blue: 0.55) : Color.black, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Answer Button Helpers
// Helper extension for creating AnswerButton from database alternative
/* Usage example when you implement your database:
extension QuestionAlternative {
    func toAnswerButton(isSelected: Bool, action: @escaping () -> Void) -> AnswerButton {
        return AnswerButton(
            option: self.letter,
            isSelected: isSelected,
            text: self.alternativeText,
            imageName: self.alternativeImageName,
            action: action
        )
    }
}
*/

// MARK: - DTK Image Full Screen View Component
struct DTKImageFullScreenView: View {
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack {
                // Close button
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(20)
                    }
                }
                
                Spacer()
                
                // Large image placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                    
                    VStack(spacing: 16) {
                        Image(systemName: "photo")
                            .font(.system(size: 80, weight: .medium))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.3))
                        
                        Text("DTK Diagram/Bild")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.5))
                        
                        Text("Fullskärmsvy")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.4))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 500)
                .padding(.horizontal, 20)
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                scale = 1.0
                            }
                        }
                )
                
                // Hint text
                Text("Nyp för att zooma • Tryck utanför för att stänga")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 24)
                
                Spacer()
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Exit Confirmation Overlay Component
struct ExitConfirmationOverlay: View {
    let onContinue: () -> Void
    let onSaveAndExit: () -> Void
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Card
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.0))
                
                // Title
                Text("Avsluta delprov?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    .multilineTextAlignment(.center)
                
                // Message
                Text("Du kan alltid återuppta provet senare från där du slutade.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                // Buttons
                VStack(spacing: 12) {
                    // Continue button
                    Button(action: onContinue) {
                        Text("Fortsätt öva")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                            )
                    }
                    
                    // Save and exit button
                    Button(action: onSaveAndExit) {
                        Text("Spara och avsluta")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.55))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.1, green: 0.25, blue: 0.55), lineWidth: 2)
                            )
                    }
                }
            }
            .padding(32)
            .frame(width: 340)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
        }
        .transition(.opacity)
    }
}

// MARK: - Section Card Component
struct SectionCard: View {
    let section: HPSection
    var isCompact: Bool = false  // New parameter for two-column layout
    var isSelected: Bool = false  // Selection state
    var accentColor: Color = .black  // Accent color for selected state
    var onTap: () -> Void = {}  // Tap action
    
    @State private var isJumping = false
    
    var body: some View {
        Button(action: {
            // Trigger jump animation
            isJumping = true
            
            // Call the tap action
            onTap()
            
            // Reset jump after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isJumping = false
            }
        }) {
            ZStack {
                // Base background
                RoundedRectangle(cornerRadius: 20)
                    .fill(accentColor)
                
                // Half circle overlay - darker blue, from right to middle
                GeometryReader { geometry in
                    Circle()
                        .fill(Color(red: 0.05, green: 0.15, blue: 0.35))  // Darker blue
                        .frame(width: geometry.size.height * 1.4, height: geometry.size.height * 1.4)
                        .offset(x: geometry.size.width * 0.3, y: -geometry.size.height * 0.2)
                        .opacity(0.6)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Content
                HStack(spacing: 12) {
                    // Section code on the left
                    Text(section.code)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Icon on the right
                    Image(systemName: section.iconName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .scaledToFit()
                }
                .padding(.horizontal, 20)
                
                // Checkmark overlay when selected
                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                                .background(
                                    Circle()
                                        .fill(Color(red: 0.2, green: 0.78, blue: 0.35))  // Green
                                        .frame(width: 32, height: 32)
                                )
                                .padding(12)
                        }
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            .offset(y: isJumping ? -12 : 0)  // Jump up 12 points
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: isJumping)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Stats Breakdown Overlay Component
struct StatsBreakdownOverlay: View {
    let title: String
    let sections: [String]  // Section codes in order
    let values: [String: Double]  // Section code -> value
    let isPercentage: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Card
            VStack(spacing: 24) {
                // Title
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    .multilineTextAlignment(.center)
                
                // Grid of sections - 4x2 (VERB first row, KVANT second row)
                VStack(spacing: 16) {
                    // First row - VERB sections (ORD, LÄS, MEK, ELF)
                    HStack(spacing: 12) {
                        ForEach(Array(sections.prefix(4)), id: \.self) { section in
                            SectionStatCard(
                                sectionCode: section,
                                value: values[section] ?? 0,
                                isPercentage: isPercentage
                            )
                        }
                    }
                    
                    // Second row - KVANT sections (XYZ, KVA, NOG, DTK)
                    HStack(spacing: 12) {
                        ForEach(Array(sections.suffix(4)), id: \.self) { section in
                            SectionStatCard(
                                sectionCode: section,
                                value: values[section] ?? 0,
                                isPercentage: isPercentage
                            )
                        }
                    }
                }
                
                // Close button
                Button(action: onDismiss) {
                    Text("Stäng")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.1, green: 0.25, blue: 0.55))
                        )
                }
            }
            .padding(32)
            .frame(width: 380)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
        }
        .transition(.opacity)
    }
}

// MARK: - Section Stat Card Component
struct SectionStatCard: View {
    let sectionCode: String
    let value: Double
    let isPercentage: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Section code
            Text(sectionCode)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
            
            // Value
            if isPercentage {
                Text(String(format: "%.1f%%", value))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.55))
            } else {
                Text("\(Int(value))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.55))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.97, green: 0.97, blue: 0.97))
        )
    }
}

#Preview {
    ContentView()
}

