# HPHome - Design Guidelines

> **Purpose**: This document defines the complete visual and interaction design system for HPHome. All UI changes and new features must follow these guidelines to maintain consistency.

---

## 🎨 Color Palette

### Primary Colors
```swift
// Use these exact hex values in your SwiftUI Color extensions
Primary Blue:     #1E3A8A  // Main brand color - buttons, accents, headers
Deep Blue:        #1E293B  // Darker variant - pressed states, emphasis
Light Blue:       #3B82F6  // Lighter variant - highlights, hovers
```

### Accent Colors
```swift
Swedish Yellow:   #FECC00  // Secondary accent - achievements, highlights
Teal:            #06B6D4  // Tertiary accent - info, links
```

### Semantic Colors
```swift
Success:         #10B981  // Correct answers, completion
Warning:         #FF9600  // Alerts, cautions
Error:           #FF4B4B  // Wrong answers, errors
Info:            #3B82F6  // Tips, information
```

### Neutral Colors
```swift
White:           #FFFFFF  // Backgrounds
Light Gray:      #F7F7F7  // Surfaces, cards
Border Gray:     #E5E5E5  // Borders, dividers
Text Dark:       #3C3C3C  // Primary text
Text Medium:     #777777  // Secondary text
Text Light:      #AFAFAF  // Disabled, placeholder
```

### Color Usage Guidelines

#### Primary Blue Usage
- Primary buttons and CTAs
- Progress indicators
- Selected states
- Headers and titles (sparingly)
- Active navigation items

#### Swedish Yellow Usage
- Achievements and badges
- Streak indicators
- Special highlights
- Celebration moments
- **NOT** for critical actions

#### Success Green Usage
- Correct answers only
- Completion states
- Success messages
- Positive feedback

#### Error Red Usage
- Wrong answers only
- Error messages
- Delete actions (if any)
- Critical warnings

#### Gray Usage
- Cards and surfaces (light gray)
- Borders and dividers (medium gray)
- Body text (dark gray)
- Disabled states (light gray)

---

## 📐 Spacing Philosophy

### 8pt Grid System
**All spacing must be multiples of 8**
- Standard values: 8pt, 16pt, 24pt, 32pt, 48pt, 64pt
- Exception: 4pt for micro-adjustments only

### Spacing Scale
```swift
Tight:          8-12pt    // Related items
Normal:         16-24pt   // Standard spacing
Loose:          32-48pt   // Section breaks
Screen Margins: 20pt      // Horizontal padding
```

---

## 🔷 Shape & Corners

### Border Radius
```swift
Small Elements:  8-12pt    // Small buttons, tags
Cards/Buttons:   12pt      // Standard components
Large Cards:     16pt      // Hero cards, major sections
Circles:         50%       // Avatars, icon backgrounds
```

### Philosophy
- ✅ Rounded corners everywhere (never sharp)
- ✅ Consistent radius within component types
- ✅ Friendly, approachable feel

---

## ✨ Animation Principles

### Timing
```swift
Fast Interactions:     0.2-0.3s   // Button taps, toggles
Standard Transitions:  0.3-0.4s   // View changes, cards
Celebrations:          1.0-1.5s   // Success states, achievements
```

### Easing Curves
```swift
Default:    ease-in-out    // Smooth both ways
Entrances:  ease-out       // Starts fast, ends slow
Exits:      ease-in        // Starts slow, ends fast
```

### Animation Types
```swift
Scale:      For button presses (scale to 0.98)
Fade:       For appearing/disappearing elements
Slide:      For view transitions
Pulse:      For success states (1.0 → 1.05 → 1.0)
Shake:      For error feedback (subtle horizontal)
Spring:     For playful interactions
```

### When to Animate
✅ **DO Animate:**
- Button presses (scale feedback)
- View transitions (slide/fade)
- Success celebrations (pulse, confetti)
- Error feedback (shake)
- Loading states (smooth rotation)
- Progress changes (smooth fill)

❌ **DON'T Animate:**
- Text appearing
- Static content
- Every single element (be selective)

---

## 🖼 Shadow & Depth

### Shadow System
```swift
Light:   0 2px 8px rgba(0,0,0,0.08)    // Cards at rest
Medium:  0 4px 12px rgba(0,0,0,0.12)   // Cards on hover/press
Strong:  0 8px 24px rgba(0,0,0,0.15)   // Modals, overlays
```

### Elevation Principles
- Use shadows sparingly
- Increase shadow on interaction
- Maintain hierarchy (higher = more shadow)

---

## 📝 Typography

### Font Choice
- **Primary**: iOS default fonts (SF Pro)
- **Optional**: SF Rounded for playful feel
- **No custom fonts needed**

### Text Hierarchy
```swift
Large Titles:    28-32pt, Bold       // Screen titles
Titles:          20-24pt, Semibold   // Section titles
Headings:        17-18pt, Semibold   // Card headers
Body:            15-17pt, Regular    // Main content
Small Text:      13pt, Regular       // Supporting text
Captions:        11-12pt, Regular    // Footnotes, labels
```

### Typography Principles
- ❌ Never use pure black (#000000)
- ✅ Use dark gray (#3C3C3C) for main text
- ✅ Limit font sizes (max 5 sizes per screen)
- ✅ Line height: 1.4-1.5x font size for readability
- ✅ Keep line length comfortable (not full screen width)

---

## 🎯 Button Hierarchy

### Visual Weight
```swift
Primary:      Filled blue, white text, shadow
Secondary:    Blue border, blue text, no fill
Tertiary:     Text only, no border, underline on press
Destructive:  Red fill or red text (use sparingly)
```

### Sizing
```swift
Large:    Full width or prominent (16pt padding)
Medium:   Standard buttons (12pt padding)
Small:    Compact actions (8pt padding)
```

### Minimum Tap Target
**44pt x 44pt minimum** for all interactive elements

---

## 🎭 Interactive States

### Every Interactive Element Must Have:
```swift
Default:    Resting state
Press:      Visual feedback (scale 0.98, color change)
Selected:   Clear indication (border, background)
Disabled:   Grayed out (Text Light color)
Loading:    Spinner or skeleton
```

### Feedback States
```swift
Success:  Green tint + checkmark icon + pulse animation
Error:    Red tint + X icon + shake animation
Warning:  Orange/yellow tint + warning icon
Info:     Blue tint + info icon
```

### Visual Feedback
```swift
Tap:       Scale down to 0.98 + subtle shadow change
Selected:  Border color change + background tint
Disabled:  Gray out + remove interactivity
Loading:   Spinner + semi-transparent overlay
Success:   Green tint + checkmark + pulse
Error:     Red tint + X icon + shake
```

### Haptic Feedback
```swift
Light Impact:    Button taps
Medium Impact:   Success states
Soft Impact:     Error states
```
**Use sparingly** - quality over quantity

---

## 🔄 Transitions

### Screen Transitions
```swift
Push:      Slide from right (0.3s)
Pop:       Slide to right (0.3s)
Present:   Slide up from bottom (0.3s)
Dismiss:   Slide down (0.3s)
```

### Element Transitions
```swift
Appear:     Fade in (0.2s)
Disappear:  Fade out (0.2s)
Move:       Smooth position change (0.3s)
Replace:    Cross-fade (0.3s)
```

---

## 📱 Layout Philosophy

### Screen Structure
- Clear visual hierarchy
- Generous white space
- Group related content
- One primary action per screen
- Easy thumb reach for primary buttons

### Grid System
- Use flexible layouts (no rigid columns)
- Adapt to content
- Maintain breathing room
- Consider different iPhone sizes

---

## 📊 Progress Visualization

### Style Guidelines
- ✅ Use bars over circles when possible
- ✅ Smooth animations (not jumpy)
- ✅ Clear percentage or fraction labels
- ✅ Primary blue for progress fill
- ✅ Light gray for background track
- ✅ Round corners on progress bars

---

## 💫 Special Effects

### When to Use
```swift
✨ Confetti:          First exercise completion, streak milestones
🎉 Particle effects:  Achievement unlocks
⚡ Glow effects:      Special badges
🌊 Subtle gradients:  Hero cards, progress cards
```

### Keep It Tasteful
- Use sparingly
- Don't distract from content
- Should enhance, not overwhelm
- Can be disabled for accessibility

---

## ♿️ Accessibility

### Must-Haves
- ✅ High contrast text (4.5:1 minimum)
- ✅ Large tap targets (44pt minimum)
- ✅ Support Dynamic Type
- ✅ VoiceOver labels on all interactive elements
- ✅ Reduce motion option respected
- ✅ Color isn't the only indicator

### Design Considerations
- Don't rely on color alone (add icons)
- Ensure readable text sizes
- Test with zoom/larger text
- Provide text alternatives for visual indicators

---

## 🎪 Personality & Tone

### Visual Personality
- **Encouraging**: Celebrate wins
- **Clear**: No confusion
- **Calm**: Not overwhelming
- **Swedish**: Subtle flag colors in accents
- **Student-friendly**: For 16-19 year olds

### Overall Aesthetic
- Playful but professional
- Clean and minimal (lots of white space)
- Friendly (rounded corners, soft shadows)
- Engaging (color accents, subtle animations)
- Confidence-building (clear feedback, celebration)

### Inspiration
**Think**: Duolingo's friendliness + Notion's clarity

### What to Avoid
- ❌ Corporate/boring aesthetics
- ❌ Childish (too playful)
- ❌ Cluttered interfaces
- ❌ Harsh transitions
- ❌ Intimidating design

---

## 🌟 Key Design Principles

1. **Clarity First**: Users should never be confused
2. **Celebrate Progress**: Make learning feel rewarding
3. **Consistent Patterns**: Same actions look the same everywhere
4. **Breathing Room**: Don't cram content
5. **Instant Feedback**: Users know immediately if something worked
6. **Professional but Fun**: Balance playfulness with credibility
7. **Swedish Identity**: Subtle, not overwhelming

---

## 🚀 Implementation Checklist

### For Every New Feature/View
- [ ] Colors from defined palette only
- [ ] All spacing uses 8pt grid
- [ ] Animations follow timing guidelines
- [ ] Interactive states implemented (default, press, disabled)
- [ ] Accessibility labels added
- [ ] Minimum 44pt tap targets
- [ ] Follows typography hierarchy
- [ ] Consistent with existing patterns

### Testing the Design
Ask yourself:
- ✅ Does it feel friendly?
- ✅ Is it immediately clear what to do?
- ✅ Does feedback feel satisfying?
- ✅ Would a 16-year-old like it?
- ✅ Can you use it easily on small phones?

---

## 📎 Quick Reference

### Most Common Values
```swift
// Spacing
8pt, 16pt, 24pt, 32pt

// Colors
Primary: #1E3A8A
Success: #10B981
Error: #FF4B4B
Text: #3C3C3C

// Corner Radius
12pt (standard)

// Animation Duration
0.3s (standard)

// Button Scale on Press
0.98

// Shadow (cards)
0 2px 8px rgba(0,0,0,0.08)
```

---

## 📝 Notes for Implementation

### SwiftUI Tips
- Create a `Color` extension with all palette colors
- Create a `View` extension for common modifiers (shadow, corner radius)
- Use `.buttonStyle` for consistent button appearance
- Use `.animation(.easeInOut(duration: 0.3))` for smooth transitions
- Implement haptics with `UIImpactFeedbackGenerator`

### Consistency is Key
Every view should feel like part of the same app. When in doubt:
1. Check existing views for patterns
2. Use these guidelines
3. Keep it simple and clear

---

**Last Updated**: December 29, 2025
**Version**: 1.0
