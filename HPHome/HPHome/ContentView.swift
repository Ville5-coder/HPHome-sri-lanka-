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
    @State private var selectedTab = 1  // Start on Hem (middle tab)
    
    init() {
        // Configure tab bar appearance for solid background
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)  // #F7F7F7
        
        // Add subtle top border/shadow
        appearance.shadowColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1.0)  // #E5E5E5
        
        // Inactive tab item color (gray)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        
        // Apply to all tab bar states
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1 - Spela
            SpelaView()
                .tabItem {
                    Label("Spela", systemImage: "gamecontroller.fill")
                }
                .tag(0)
            
            // Tab 2 - Hem
            HemView()
                .tabItem {
                    Label("Hem", systemImage: "house.fill")
                }
                .tag(1)
            
            // Tab 3 - Teori
            TeoriView()
                .tabItem {
                    Label("Teori", systemImage: "book.fill")
                }
                .tag(2)
        }
        .tint(tabColor(for: selectedTab))
    }
    
    // Return the appropriate color based on selected tab
    private func tabColor(for tab: Int) -> Color {
        switch tab {
        case 0: // Spela
            return Color(red: 0.75, green: 0.22, blue: 0.85)  // Purple/magenta
        case 1: // Hem
            return Color(red: 0.0, green: 0.48, blue: 1.0)  // Primary blue
        case 2: // Teori
            return Color(red: 0.19, green: 0.82, blue: 0.85)  // Teal/cyan
        default:
            return Color(red: 0.0, green: 0.48, blue: 1.0)  // Default blue
        }
    }
}

// MARK: - Tab Views
struct SpelaView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Spela")
                        .font(.largeTitle)
                        .bold()
                    Text("Game content coming soon")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("Spela")
        }
    }
}

struct HemView: View {
    // 8 Högskoleprovet sections
    let sections: [HPSection] = [
        HPSection(id: 1, code: "XYZ", iconName: "calculator.fill"),
        HPSection(id: 2, code: "KVA", iconName: "scale.3d"),
        HPSection(id: 3, code: "NOG", iconName: "brain.head.profile"),
        HPSection(id: 4, code: "DTK", iconName: "chart.pie"),
        HPSection(id: 5, code: "ORD", iconName: "text.alignleft"),
        HPSection(id: 6, code: "LÄS", iconName: "book"),
        HPSection(id: 7, code: "MEK", iconName: "puzzlepiece"),
        HPSection(id: 8, code: "ELF", iconName: "character.textbox")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {  // 16pt spacing between blocks
                    // All 8 section cards - exactly the same size
                    ForEach(sections) { section in
                        SectionCard(section: section)
                    }
                }
                .padding(.horizontal, 20)  // Screen margins
                .padding(.vertical, 24)    // Top/bottom breathing room
            }
            .background(Color.white)  // White background
            .navigationTitle("Hem")
        }
    }
}

struct TeoriView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Teori")
                        .font(.largeTitle)
                        .bold()
                    Text("Theory content coming soon")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("Teori")
        }
    }
}

// MARK: - Section Card Component
struct SectionCard: View {
    let section: HPSection
    
    var body: some View {
        Button(action: {
            // Tappable action - to be implemented
            print("Tapped section: \(section.code)")
        }) {
            HStack {
                // Section code on the left
                Text(section.code)
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))  // Dark navy/black
                
                Spacer()
                
                // Icon on the right
                Image(systemName: section.iconName)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.118))  // Dark navy/black
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(height: 180)  // All blocks same height: 180pt
            .frame(maxWidth: .infinity)  // All blocks same width: full available width
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.969, green: 0.969, blue: 0.969))  // #F7F7F7
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.898, green: 0.898, blue: 0.898), lineWidth: 1)  // #E5E5E5
            )
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)  // Remove default button styling
    }
}

#Preview {
    ContentView()
}
