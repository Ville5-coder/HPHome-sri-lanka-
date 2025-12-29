# Home Screen Design Interpretation

## Design Goal
Create a clean, scrollable home screen with 8 distinct section blocks arranged in a ladder/staggered layout with one section per block.

---

## Visual Layout

### Structure
```
┌─────────────────────────────────┐
│     [Block 1 - Full Width]      │
│                                 │
└─────────────────────────────────┘

     ┌─────────────────────────┐
     │  [Block 2 - Offset]     │
     │                         │
     └─────────────────────────┘

┌─────────────────────────────────┐
│     [Block 3 - Full Width]      │
│                                 │
└─────────────────────────────────┘

     ┌─────────────────────────┐
     │  [Block 4 - Offset]     │
     │                         │
     └─────────────────────────┘

... (continues for 8 blocks total)
```

---

## Design Decisions Based on Guidelines

### Colors
- **Card Background**: Light Gray (#F7F7F7) - surface color for cards
- **Card Border**: Border Gray (#E5E5E5) - subtle borders for definition
- **Background**: White (#FFFFFF) - main screen background

### Spacing (8pt Grid System)
- **Screen Margins**: 20pt horizontal padding (as specified)
- **Vertical Spacing Between Blocks**: 16pt (normal spacing)
- **Card Padding**: 16pt internal padding (for future content)

### Shape
- **Corner Radius**: 16pt (large cards as specified)
- **Rounded corners**: All cards have friendly, rounded corners

### Block Heights
- **Placeholder Height**: 120pt (temporary, will adjust based on content later)
- **Consistent across all blocks** for visual harmony

### Ladder/Staggered Effect
**Interpretation**: Alternating alignment pattern
- **Odd blocks (1, 3, 5, 7)**: Aligned to leading edge
- **Even blocks (2, 4, 6, 8)**: Offset/indented to create ladder effect

**Offset Amount**: 40pt from leading edge (creates clear visual stagger)

### Shadow
- **Light shadow**: 0 2px 8px rgba(0,0,0,0.08) - cards at rest
- Subtle depth without being overwhelming

### Layout Philosophy Applied
- ✅ Clear visual hierarchy (alternating pattern draws eye down)
- ✅ Generous white space (16pt between blocks)
- ✅ Breathing room (blocks don't crowd each other)
- ✅ Friendly feel (rounded corners, soft shadows)

---

## SwiftUI Implementation Plan

### Component Structure
```swift
ScrollView {
    VStack(spacing: 16) {  // 16pt spacing between blocks
        // Block 1 - Full width
        BlockCard(isOffset: false)
        
        // Block 2 - Offset
        BlockCard(isOffset: true)
        
        // Block 3 - Full width
        BlockCard(isOffset: false)
        
        // Block 4 - Offset
        BlockCard(isOffset: true)
        
        // ... continues for 8 blocks
    }
    .padding(.horizontal, 20)  // Screen margins
    .padding(.vertical, 24)    // Top/bottom breathing room
}
```

### Reusable BlockCard Component
- Takes `isOffset` parameter
- Applies leading padding when offset
- Consistent styling across all blocks
- No text or content (pure empty blocks)

---

## Visual Characteristics

### What You'll See
- ✅ 8 empty rectangular cards
- ✅ Light gray background on each card
- ✅ Soft shadows for subtle depth
- ✅ Alternating left/right alignment creating ladder effect
- ✅ Smooth scrolling experience
- ✅ Generous spacing between elements
- ✅ Clean, minimal aesthetic

### What You WON'T See (intentionally)
- ❌ No text or titles
- ❌ No icons or images
- ❌ No buttons or interactive elements
- ❌ No colors other than neutrals
- ❌ No animations (static layout for now)

---

## Responsive Behavior
- Cards will adapt to screen width
- 20pt margins maintained on all device sizes
- Offset creates visual interest without crowding on smaller screens

---

## Next Steps (After Review)
Once approved, these blocks can be populated with:
1. Section titles
2. Content cards
3. Progress indicators
4. Interactive elements
5. Color accents from the palette

---

**Design Version**: 1.0  
**Date**: December 29, 2025  
**Status**: Awaiting approval before implementation
