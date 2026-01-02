//
//  ContentView.swift
//  HPHome
//
//  Created by Ville Sandgren on 2025-12-27.
//

import SwiftUI
import SwiftData

// MARK: - Section Data Model
struct HPSection: Identifiable {
    let id: Int
    let code: String
    let iconName: String
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
            if let tabBar = UIApplication.shared.windows.first?.rootViewController?.view.subviews.first(where: { $0 is UITabBar }) as? UITabBar {
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
                        // Game 1: Ordsviten (Green)
                        GameCard(
                            title: "Ordsviten",
                            iconName: "text.word.spacing",
                            color: Color(red: 0.2, green: 0.78, blue: 0.35)  // Nice green
                        ) {
                            print("Ordsviten tapped")
                        }
                        
                        // Game 2: Udda ordet (Black)
                        GameCard(
                            title: "Udda ordet",
                            iconName: "xmark.circle.fill",
                            color: Color(red: 0.11, green: 0.11, blue: 0.118)  // Black
                        ) {
                            print("Udda ordet tapped")
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 24)
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Game Card Component
struct GameCard: View {
    let title: String
    let iconName: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct HemView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Empty - content to be added
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color.white)
            .navigationTitle("Hem")
        }
    }
}

struct OvaView: View {
    @State private var animateCards = false
    @State private var selectedCount = 10  // Default selection
    @State private var selectedSections: Set<Int> = []  // Track selected section IDs
    @State private var showingCountSheet = false  // For the popup sheet
    
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
                    // Header section - left aligned (matching Spela layout exactly)
                    HStack {
                        Text("Öva")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                    
                    // Section cards in two columns - matching Spela's HStack spacing exactly
                    HStack(spacing: 16) {
                        // Left column
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
                        
                        // Right column
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
                    .padding(.horizontal, 20)
                    
                    // Statistik section - separate box
                    VStack(spacing: 16) {
                        // Section title
                        HStack {
                            Text("Statistik")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                            Spacer()
                        }
                        
                        // Icons and text directly in the box
                        VStack(spacing: 14) {
                            // Row 1: Genomförda övningar with pencil icon
                            HStack(spacing: 12) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                Text("genomförda övningar")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                Spacer()
                            }
                            
                            // Row 2: Träffsäkerhet with target icon
                            HStack(spacing: 12) {
                                Image(systemName: "target")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                Text("träffsäkerhet")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                                Spacer()
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.969, green: 0.969, blue: 0.969))  // #F7F7F7
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(red: 0.898, green: 0.898, blue: 0.898), lineWidth: 1)  // #E5E5E5
                    )
                    .padding(.horizontal)
                    
                    // Extra bottom spacing for the floating button
                    if !selectedSections.isEmpty {
                        Spacer()
                            .frame(height: 80)
                    }
                }
                .padding(.vertical, 24)    // Top/bottom breathing room
            }
            .background(Color.white)  // White background
            .navigationBarHidden(true)  // Hide navigation bar
            .overlay(alignment: .bottom) {
                // Floating play button at the bottom
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
                                .fill(Color(red: 0.2, green: 0.78, blue: 0.35))  // Green
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
                    }
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedSections.isEmpty)
            .onAppear {
                animateCards = true
            }
            .sheet(isPresented: $showingCountSheet) {
                CountSelectionSheet(selectedCount: $selectedCount, onStart: {
                    showingCountSheet = false
                    // Start practice action
                    print("Starting practice with \(selectedSections.count) sections and \(selectedCount) questions")
                })
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
            }
        }
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
                        .fill(Color(red: 0.2, green: 0.78, blue: 0.35))  // Green
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
                    .fill(Color(red: 0.2, green: 0.78, blue: 0.35))  // Green color
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
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118).opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                    
                    // Two test sections in a row
                    HStack(spacing: 16) {
                        // KVANT (Grey)
                        ProvCard(
                            title: "KVANT",
                            iconName: "function"
                        ) {
                            print("KVANT tapped")
                        }
                        
                        // VERB (Grey)
                        ProvCard(
                            title: "VERB",
                            iconName: "book.fill"
                        ) {
                            print("VERB tapped")
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
                                    HistoricalProvCard(year: "2025", semester: "HT")
                                }
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[1])) {
                                    HistoricalProvCard(year: "2025", semester: "VT")
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Row 2: HT 2024, VT 2024
                            HStack(spacing: 16) {
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[2])) {
                                    HistoricalProvCard(year: "2024", semester: "HT")
                                }
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[3])) {
                                    HistoricalProvCard(year: "2024", semester: "VT")
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Row 3: HT 2023, VT 2023
                            HStack(spacing: 16) {
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[4])) {
                                    HistoricalProvCard(year: "2023", semester: "HT")
                                }
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[5])) {
                                    HistoricalProvCard(year: "2023", semester: "VT")
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Row 4: HT 2022, VT 2022
                            HStack(spacing: 16) {
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[6])) {
                                    HistoricalProvCard(year: "2022", semester: "HT")
                                }
                                NavigationLink(destination: HistoricalTestDetailView(test: historicalTests[7])) {
                                    HistoricalProvCard(year: "2022", semester: "VT")
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Prov Card Component
struct ProvCard: View {
    let title: String
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
    
    var body: some View {
        VStack(spacing: 8) {
            // Large year text
            Text(year)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
            
            // Semester text below
            Text(semester)
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
}

// MARK: - Historical Test Detail View
struct HistoricalTestDetailView: View {
    let test: HistoricalTest
    @Environment(\.dismiss) private var dismiss
    @State private var showingProvpassSheet = false
    @State private var selectedProvpass: (type: String, number: Int)? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(test.semester) \(test.year)")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
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
                        ProvpassCard(
                            type: "KVANT",
                            provpass: test.kvant1
                        ) {
                            selectedProvpass = ("KVANT", test.kvant1)
                            showingProvpassSheet = true
                        }
                        
                        ProvpassCard(
                            type: "KVANT",
                            provpass: test.kvant2
                        ) {
                            selectedProvpass = ("KVANT", test.kvant2)
                            showingProvpassSheet = true
                        }
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
                        ProvpassCard(
                            type: "VERB",
                            provpass: test.verb1
                        ) {
                            selectedProvpass = ("VERB", test.verb1)
                            showingProvpassSheet = true
                        }
                        
                        ProvpassCard(
                            type: "VERB",
                            provpass: test.verb2
                        ) {
                            selectedProvpass = ("VERB", test.verb2)
                            showingProvpassSheet = true
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 24)
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .sheet(isPresented: $showingProvpassSheet) {
            if let provpass = selectedProvpass {
                ProvpassInfoSheet(
                    type: provpass.type,
                    provpassNumber: provpass.number,
                    onStart: {
                        showingProvpassSheet = false
                        print("Starting \(provpass.type) Provpass \(provpass.number)")
                    }
                )
                .presentationDetents([.height(240)])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - Provpass Info Sheet
struct ProvpassInfoSheet: View {
    let type: String
    let provpassNumber: Int
    let onStart: () -> Void
    @State private var timerEnabled = true
    
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
                
                // Time info with clock icon and toggle
                HStack(spacing: 8) {
                    Text(timerEnabled ? "Det tar 55 minuter" : "Obegränsad tid")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    
                    Spacer()
                    
                    Image(systemName: "clock")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))
                    
                    Toggle("", isOn: $timerEnabled)
                        .labelsHidden()
                        .tint(Color(red: 0.2, green: 0.78, blue: 0.35))
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
                        .fill(Color(red: 0.2, green: 0.78, blue: 0.35))
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

#Preview {
    ContentView()
}

