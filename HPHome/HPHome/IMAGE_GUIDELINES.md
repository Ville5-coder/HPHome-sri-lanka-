# Image Guidelines for KVANT Question Alternatives

## Overview
KVANT questions can have images in their answer alternatives instead of text. This is particularly common in sections like XYZ (mathematics) and DTK (diagram interpretation).

## Image Naming Convention

### For Historical Tests
```
{testType}_{year}_{semester}_q{questionNumber}_option{letter}.png
```

**Examples:**
- `kvant_2025_ht_q5_optionA.png` - KVANT, HT 2025, Question 5, Option A
- `kvant_2024_vt_q15_optionD.png` - KVANT, VT 2024, Question 15, Option D

### For Generated Tests
```
{testType}_generated_{provpassNumber}_q{questionNumber}_option{letter}.png
```

**Examples:**
- `kvant_generated_0_q12_optionC.png` - Generated KVANT, Question 12, Option C
- `kvant_generated_0_q28_optionA.png` - Generated KVANT, Question 28, Option A

## Image Specifications

### Technical Requirements
- **Format:** PNG (recommended for clarity and transparency support)
- **Resolution:** 2x or 3x for Retina displays
  - Standard: 600px width maximum
  - 2x: 1200px width maximum
  - 3x: 1800px width maximum
- **Aspect Ratio:** Flexible, but keep reasonable (max 3:1 ratio)
- **File Size:** Optimize to keep under 200KB per image
- **Background:** Transparent or white background

### Visual Guidelines
- **Clarity:** Ensure text and symbols are clearly visible
- **Contrast:** High contrast for readability
- **Padding:** Include small padding around content (10-20px)
- **Font Size:** If image contains text/equations, ensure it's readable at display size

## Asset Catalog Organization

### Recommended Structure in Xcode
```
Assets.xcassets/
├── KVANT_Questions/
│   ├── Historical/
│   │   ├── 2025_HT/
│   │   │   ├── kvant_2025_ht_q5_optionA.imageset/
│   │   │   ├── kvant_2025_ht_q5_optionB.imageset/
│   │   │   └── ...
│   │   ├── 2025_VT/
│   │   ├── 2024_HT/
│   │   └── 2024_VT/
│   └── Generated/
│       └── kvant_generated_0_q12_optionC.imageset/
└── DTK_Questions/
    └── (similar structure for question images)
```

## Database Schema

### Question Alternative Table
```sql
CREATE TABLE question_alternatives (
    id UUID PRIMARY KEY,
    question_id UUID NOT NULL,
    letter VARCHAR(1) NOT NULL,  -- A, B, C, D, or E
    alternative_text TEXT,        -- Nullable: use for text alternatives
    alternative_image_name TEXT,  -- Nullable: use for image alternatives
    created_at TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(id),
    CHECK (alternative_text IS NOT NULL OR alternative_image_name IS NOT NULL)
);
```

### Key Points
- Either `alternative_text` OR `alternative_image_name` must be set (not both)
- Use `alternative_image_name` for KVANT questions with visual/mathematical content
- Use `alternative_text` for standard text-based alternatives (most VERB questions)

## Swift Code Implementation

### 1. Database Model (SwiftData)
```swift
@Model
final class QuestionAlternative {
    var id: UUID
    var letter: String  // "A", "B", "C", "D", or "E"
    var alternativeText: String?  // For text alternatives
    var alternativeImageName: String?  // For image alternatives
    
    var question: Question?
    
    init(letter: String, alternativeText: String? = nil, alternativeImageName: String? = nil) {
        self.id = UUID()
        self.letter = letter
        self.alternativeText = alternativeText
        self.alternativeImageName = alternativeImageName
    }
}
```

### 2. Loading and Displaying
```swift
// In your TestView or PracticeView
VStack(spacing: 12) {
    ForEach(currentQuestion.alternatives, id: \.id) { alternative in
        AnswerButton(
            option: alternative.letter,
            isSelected: selectedAnswer == alternative.letter,
            text: alternative.alternativeText,
            imageName: alternative.alternativeImageName
        ) {
            selectedAnswer = alternative.letter
        }
    }
}
```

### 3. Helper Extension (Optional)
```swift
extension QuestionAlternative {
    var hasImage: Bool {
        alternativeImageName != nil
    }
    
    var hasText: Bool {
        alternativeText != nil
    }
}
```

## Import Process

### When Importing Questions from External Sources

1. **Identify Image Alternatives**
   - Check if the alternative contains LaTeX, mathematical symbols, or complex formatting
   - If yes, render it as an image

2. **Generate Images**
   - Use a LaTeX renderer or screenshot tool to create PNG images
   - Follow the naming convention above
   - Optimize images for web/mobile

3. **Add to Asset Catalog**
   - Drag images into Xcode's Asset Catalog
   - Ensure image set includes @2x and @3x versions if available
   - Set rendering mode to "Original" (not template)

4. **Update Database**
   - Insert question with alternatives
   - Set `alternative_image_name` for image-based alternatives
   - Set `alternative_text` for text-based alternatives

### Example Import Script (Python)
```python
import sqlite3

def import_question_with_images(db_path, question_data):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Insert question
    cursor.execute("""
        INSERT INTO questions (id, test_type, question_number, question_text)
        VALUES (?, ?, ?, ?)
    """, (question_data['id'], question_data['test_type'], 
          question_data['number'], question_data['text']))
    
    # Insert alternatives
    for alt in question_data['alternatives']:
        cursor.execute("""
            INSERT INTO question_alternatives 
            (id, question_id, letter, alternative_text, alternative_image_name)
            VALUES (?, ?, ?, ?, ?)
        """, (alt['id'], question_data['id'], alt['letter'],
              alt.get('text'), alt.get('image_name')))
    
    conn.commit()
    conn.close()

# Example usage
question = {
    'id': 'uuid-here',
    'test_type': 'KVANT',
    'number': 5,
    'text': 'Vilket värde har x?',
    'alternatives': [
        {'id': 'uuid-1', 'letter': 'A', 'image_name': 'kvant_2025_ht_q5_optionA.png'},
        {'id': 'uuid-2', 'letter': 'B', 'image_name': 'kvant_2025_ht_q5_optionB.png'},
        {'id': 'uuid-3', 'letter': 'C', 'text': 'x = 0'},
        {'id': 'uuid-4', 'letter': 'D', 'text': 'x = 1'}
    ]
}

import_question_with_images('questions.db', question)
```

## Testing Checklist

- [ ] Images display correctly on all device sizes (iPhone SE, iPhone 15, iPad)
- [ ] Images are sharp on Retina displays (@2x, @3x)
- [ ] Images load quickly (under 200KB each)
- [ ] Fallback placeholder appears if image is missing
- [ ] Text alternatives still work correctly
- [ ] Mixed text/image alternatives in same question work
- [ ] Images maintain aspect ratio
- [ ] Dark mode compatibility (if applicable)

## Common Sections with Image Alternatives

### KVANT Sections
- **XYZ (Q1-12):** Mathematical equations, graphs, geometric figures
- **KVA (Q13-24):** Often text, but may include graphs or number sequences
- **NOG (Q25-28):** Rarely uses images
- **DTK (Q29-40):** Question images common, alternatives usually text

### VERB Sections
- **ORD, LÄS, MEK, ELF:** Rarely use images in alternatives (mostly text-based)

## Troubleshooting

### Image Not Displaying
1. Check image name spelling matches database exactly
2. Verify image exists in Asset Catalog
3. Check image is included in app target
4. Ensure image format is supported (PNG/JPG)

### Image Too Large/Small
1. Adjust `maxHeight` parameter in AnswerButton (currently 80pt)
2. Use `.aspectRatio(contentMode: .fit)` to maintain proportions
3. Optimize source image resolution

### Performance Issues
1. Compress images using ImageOptim or similar tool
2. Use appropriate resolution (don't use 4K images)
3. Consider lazy loading for large question sets
4. Cache loaded images in memory

## Future Enhancements

- [ ] Support for SVG images (scalable)
- [ ] LaTeX rendering on-the-fly (no pre-generated images needed)
- [ ] Image zoom capability for complex diagrams
- [ ] Accessibility: VoiceOver descriptions for images
- [ ] Offline image caching strategy
- [ ] Image CDN integration for cloud-based loading
