# Liar's Dice Watch App - Implementation Todo

## Project Overview
Building a watchOS app for calculating probabilities in Liar's Dice gameplay. The app provides real-time probability calculations for bid assessment during games.

**Current Status:** Project initialized with basic SwiftUI template in `/liars-dice-app`

## Key Documentation References

### Apple Documentation
- [watchOS App Programming Guide](https://developer.apple.com/documentation/watchos)
- [SwiftUI for watchOS](https://developer.apple.com/documentation/swiftui/watchos)
- [Digital Crown Programming Guide](https://developer.apple.com/documentation/watchkit/digital_crown)
- [watchOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos)
- [watchOS App Architecture](https://developer.apple.com/documentation/watchos/apps/architecting_your_watchos_app)
- [watchOS Performance](https://developer.apple.com/documentation/watchos/apps/optimizing_your_watchos_app)
- [Accelerate Framework](https://developer.apple.com/documentation/accelerate)

### Mathematical Resources
- [Binomial Distribution](https://en.wikipedia.org/wiki/Binomial_distribution)
- [Cumulative Binomial Probability](https://en.wikipedia.org/wiki/Binomial_distribution#Cumulative_distribution_function)
- [Swift Numerics](https://github.com/apple/swift-numerics)

### Design & Accessibility
- [watchOS Color Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos/visual-design/color)
- [watchOS Typography](https://developer.apple.com/design/human-interface-guidelines/watchos/visual-design/typography)
- [watchOS Accessibility](https://developer.apple.com/documentation/watchos/apps/accessibility)

### Testing & Distribution
- [watchOS Testing](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect](https://developer.apple.com/documentation/appstoreconnect)

## Implementation Tasks

### High Priority Tasks

#### [x] Task 1: Update .gitignore for Swift/Xcode project [SUBAGENT]
**Description:** Replace Node.js .gitignore with Swift/Xcode-specific patterns

**Subtasks:**
- [x] Replace current .gitignore content
- [x] Include patterns: `*.xcuserdata/`, `DerivedData/`, `*.xccheckout`, `*.xcscmblueprint`, `.DS_Store`
- [x] Add build artifacts and temporary files

**Subagent Prompt:**
```
Update the .gitignore file at /Users/jeremywatt/Desktop/liars_dice/.gitignore to replace Node.js patterns with Swift/Xcode patterns. Include: *.xcuserdata/, DerivedData/, *.xccheckout, *.xcscmblueprint, .DS_Store, *.moved-aside, *.playground, timeline.xctimeline, playground.xcworkspace, .build/, Pods/, *.xcworkspace, !default.xcworkspace, xcshareddata/, *.xcuserstate
```

---

#### [x] Task 2: Create MVVM folder structure [SUBAGENT]
**Description:** Organize project with MVVM architecture folders

**Subtasks:**
- [x] Create Models/ folder
- [x] Create Views/ folder
- [x] Create ViewModels/ folder  
- [x] Create Utilities/ folder
- [x] Move ContentView.swift to Views/
- [x] Add placeholder files

**Subagent Prompt:**
```
In the liars-dice-app/liars-dice-app Watch App/ directory, create MVVM folder structure with Models/, Views/, ViewModels/, and Utilities/ folders. Move the existing ContentView.swift to the Views/ folder. Create placeholder Swift files in each folder (e.g., Placeholder.swift) to maintain structure. Update any necessary import paths.
```

---

#### [x] Task 3: Research binomial probability algorithms [SUBAGENT]
**Description:** Research efficient algorithms for calculating binomial probabilities

**Subtasks:**
- [x] Research P(k|n) = ∑ₓ₌ₖⁿ C(n,x)(1/6)ˣ(5/6)ⁿ⁻ˣ
- [x] Evaluate computational methods
- [x] Document edge cases (n < 6)
- [x] Investigate Swift's Accelerate framework
- [x] Create implementation plan

**Subagent Prompt:**
```
Research efficient algorithms for calculating binomial probabilities P(k|n) = ∑ₓ₌ₖⁿ C(n,x)(1/6)ˣ(5/6)ⁿ⁻ˣ for a Liar's Dice game. We need to support n ≤ 40 dice and 0 ≤ k ≤ n. Evaluate different computational methods (direct calculation, recursive, approximations). Document how to handle edge cases, especially n < 6. Investigate if Swift's Accelerate framework can help. Create a detailed implementation plan with specific functions needed.
```

---

#### [x] Task 4: Create ProbabilityEngine class
**Description:** Implement core probability calculation engine with precomputed lookup table

**Subtasks:**
- [x] Implement factorial and combination functions
- [x] Create binomial probability calculation methods
- [x] Design 2D lookup table structure
- [x] Populate table with precomputed values
- [x] Implement accessor methods
- [x] Ensure <50KB memory footprint

---

#### [x] Task 5: Implement break-even threshold (K₀) calculation
**Description:** Create functionality to find maximum k where P(k|n) ≥ 50%

**Subtasks:**
- [x] Implement search algorithm for K₀
- [x] Handle edge cases
- [x] Add caching for performance
- [x] Test with all valid n values (1-40)

---

#### [x] Task 6: Create GameState model with ObservableObject
**Description:** Implement data model for game state management

**Subtasks:**
- [x] Create GameState class with ObservableObject
- [x] Add @Published properties (totalDiceCount, currentBid)
- [x] Add computed properties for probability and color
- [x] Integrate with ProbabilityEngine
- [x] Implement validation logic

---

#### [x] Task 7: Implement input validation
**Description:** Add validation for dice count and bid values

**Subtasks:**
- [x] Validate dice count (1-40)
- [x] Validate bid (0 to n)
- [x] Implement in setters and update methods
- [x] Add error handling
- [x] Test boundary conditions

---

#### [x] Task 8: Design Screen 1 - Dice Selection View
**Description:** Create first screen for selecting total dice

**Subtasks:**
- [x] Create "Dice in Play" header
- [x] Implement large number display (1-40)
- [x] Add right-arrow navigation icon
- [x] Integrate Digital Crown control
- [x] Add haptic feedback
- [x] Test on different watch sizes

---

#### [x] Task 9: Design Screen 2 - Probability View
**Description:** Create second screen for bid probability display

**Subtasks:**
- [x] Create "Break-even: K₀" header
- [x] Implement bid display with probability percentage
- [x] Add color-coded display
- [x] Add left-arrow navigation icon
- [x] Integrate Digital Crown for bid adjustment
- [x] Add haptic feedback

---

#### [x] Task 10: Implement navigation system
**Description:** Create navigation between screens

**Subtasks:**
- [x] Set up NavigationStack or coordinator
- [x] Implement arrow tap handlers
- [x] Add slide animations
- [x] Ensure GameState is shared
- [x] Test rapid navigation

---

#### [x] Task 11: Integrate Digital Crown with haptic feedback
**Description:** Complete Digital Crown integration for both screens

**Subtasks:**
- [x] Configure rotation sensitivity for dice count
- [x] Configure rotation sensitivity for bid value
- [x] Implement focus management
- [x] Add haptic feedback patterns
- [x] Implement acceleration for larger ranges

---

### Medium Priority Tasks

#### [x] Task 12: Create color-coded probability component
**Description:** Implement visual probability display with color coding

**Subtasks:**
- [x] Design reusable SwiftUI component
- [x] Implement color thresholds (green ≥50%, yellow 30-49%, red <30%)
- [x] Add smooth transitions
- [x] Ensure text readability
- [x] Add accessibility support

---

#### [ ] Task 13: Design and implement onboarding overlay
**Description:** Create first-launch tutorial

**Subtasks:**
- [ ] Design multi-step content
- [ ] Create gesture illustrations
- [ ] Implement overlay logic
- [ ] Add UserDefaults tracking
- [ ] Ensure accessibility

---

#### [ ] Task 14: Optimize performance [SUBAGENT for research]
**Description:** Profile and optimize for watchOS constraints

**Subtasks:**
- [ ] Profile with Instruments
- [ ] Optimize lookup table memory
- [ ] Implement caching strategies
- [ ] Optimize SwiftUI views
- [ ] Minimize battery impact
- [ ] Verify <50ms updates

**Subagent Prompt (for research phase):**
```
Research watchOS performance optimization techniques for SwiftUI apps. Focus on achieving <50ms UI updates, minimizing memory usage (lookup table must be <50KB), and battery efficiency. Create a detailed profiling checklist and optimization strategies specific to watch apps. Include specific Instruments tools to use and metrics to track.
```

---

#### [ ] Task 15: Design and create app icon [SUBAGENT]
**Description:** Create app icon for all watchOS sizes

**Subtasks:**
- [ ] Design icon concept (dice/probability theme)
- [ ] Create assets for all sizes (38-49mm + App Store)
- [ ] Test in light/dark modes
- [ ] Add to asset catalog

**Subagent Prompt:**
```
Design concept for Liar's Dice Probability watch app icon. Research effective watchOS app icons. Create detailed specifications for an icon that represents dice and probability. List all required sizes for watchOS (38mm, 40mm, 42mm, 44mm, 46mm, 49mm) plus App Store (1024x1024). Describe visual elements, colors, and how it will look at small sizes.
```

---

#### [ ] Task 16: Implement accessibility features [SUBAGENT for audit]
**Description:** Ensure full VoiceOver and accessibility support

**Subtasks:**
- [ ] Add accessibility labels and traits
- [ ] Configure VoiceOver navigation
- [ ] Implement dynamic announcements
- [ ] Support Dynamic Type
- [ ] Test with all settings

**Subagent Prompt (for audit phase):**
```
Audit the Liar's Dice watchOS app for accessibility requirements. Create a comprehensive checklist for: VoiceOver support (labels, traits, navigation order), Dynamic Type support, haptic feedback patterns, color-blind considerations, and Reduce Motion support. Reference Apple's watchOS accessibility guidelines. Include specific code examples for SwiftUI accessibility modifiers.
```

---

#### [ ] Task 17: Add error handling and edge cases
**Description:** Implement robust error handling

**Subtasks:**
- [ ] Document all error conditions
- [ ] Implement input validation system
- [ ] Design error UI
- [ ] Create logging system
- [ ] Test edge cases from PRD

---

#### [ ] Task 18: Create unit tests
**Description:** Develop comprehensive test suite

**Subtasks:**
- [ ] Test probability calculations
- [ ] Test edge cases
- [ ] Test break-even calculations
- [ ] Verify performance (<50ms)
- [ ] Test memory usage

---

#### [ ] Task 19: Create UI tests
**Description:** Implement UI behavior tests

**Subtasks:**
- [ ] Test navigation flows
- [ ] Test Digital Crown interactions
- [ ] Test color changes
- [ ] Test on multiple sizes
- [ ] Test accessibility

---

### Low Priority Tasks

#### [ ] Task 20: Prepare App Store submission [SUBAGENT]
**Description:** Prepare all App Store materials

**Subtasks:**
- [ ] Create screenshots
- [ ] Write description
- [ ] Prepare privacy policy
- [ ] Configure TestFlight
- [ ] Review guidelines

**Subagent Prompt:**
```
Create App Store submission materials for Liar's Dice Probability watch app. Write: 1) Compelling app description highlighting probability calculations for Liar's Dice gameplay, 2) Short promotional text (170 chars max), 3) Keywords for search optimization, 4) Privacy policy template, 5) Release notes for version 1.0. Reference the app's features: instant probability calculations, break-even guidance, Digital Crown controls, color-coded display.
```

---

## Implementation Order

1. **Phase 1: Setup** (Launch 3 parallel subagents)
   - Task 1: Update .gitignore [SUBAGENT]
   - Task 2: Create MVVM structure [SUBAGENT]  
   - Task 3: Research algorithms [SUBAGENT]

2. **Phase 2: Core Engine** (Main thread focus)
   - Task 4: ProbabilityEngine class
   - Task 5: Break-even calculation
   - Task 6: GameState model
   - Task 7: Input validation

3. **Phase 3: UI Implementation** (Main thread + design subagent)
   - Task 8: Screen 1 (Dice Selection)
   - Task 9: Screen 2 (Probability View)
   - Task 10: Navigation system
   - Task 11: Digital Crown integration
   - Task 15: App icon design [SUBAGENT in parallel]

4. **Phase 4: Polish** (Main thread + research subagents)
   - Task 12: Color-coded display
   - Task 13: Onboarding
   - Task 14: Performance optimization [SUBAGENT for research]
   - Task 16: Accessibility [SUBAGENT for audit]
   - Task 17: Error handling

5. **Phase 5: Testing & Release**
   - Task 18: Unit tests
   - Task 19: UI tests
   - Task 20: App Store prep [SUBAGENT]

---

## Progress Tracking

### Completed Tasks
- Phase 1: All 3 subagents completed
- Task 1: Updated .gitignore for Swift/Xcode
- Task 2: Created MVVM folder structure
- Task 3: Researched binomial probability algorithms
- Task 4: Created ProbabilityEngine class
- Task 5: Implemented break-even threshold calculation
- Task 6: Created GameState model with ObservableObject
- Task 7: Implemented input validation
- Task 8: Designed Screen 1 - Dice Selection View
- Task 9: Designed Screen 2 - Probability View
- Task 10: Implemented navigation system
- Task 11: Integrated Digital Crown with haptic feedback
- Task 12: Created color-coded probability component

### Current Focus
- Core implementation complete!
- Ready for polish tasks (onboarding, accessibility, optimization)

### Blockers
- None

### Notes
- Project already initialized in `/liars-dice-app`
- Using SwiftUI for watchOS
- Performance requirements: <50ms updates, <50KB storage
- Minimum watchOS version: 9.0+