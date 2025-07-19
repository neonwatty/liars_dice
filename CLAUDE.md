# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a native watchOS app for calculating probabilities in Liar's Dice gameplay. The app provides real-time probability calculations for bid assessment during games, featuring a two-screen interface optimized for Apple Watch interaction.

## Build and Development Commands

### Building the Project
```bash
# Open in Xcode
open liars-dice-app/liars-dice-app.xcodeproj

# Build from command line (requires Xcode Command Line Tools)
cd liars-dice-app
xcodebuild -scheme "liars-dice-app Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' build

# Run tests
xcodebuild test -scheme "liars-dice-app Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)'
```

### Important Note on .gitignore
The current .gitignore is for Node.js projects. Consider updating it with Swift/Xcode-specific entries:
- `*.xcuserdata/`
- `DerivedData/`
- `*.xccheckout`
- `*.xcscmblueprint`

## Architecture and Code Structure

### App Architecture (Planned)
- **MVVM Pattern**: Views (SwiftUI) → ViewModels (ObservableObject) → Models
- **Two Main Views**:
  1. `DiceSelectionView`: Select total dice count (1-40) using Digital Crown
  2. `ProbabilityView`: Display bid probability with color coding and break-even threshold

### Key Components to Implement

1. **Probability Engine**
   - Precomputed lookup table for binomial probabilities
   - Formula: P(k|n) = ∑ₓ₌ₖⁿ C(n,x)(1/6)ˣ(5/6)ⁿ⁻ˣ
   - Support for n ≤ 40 dice, k ≤ n target dice
   - Break-even calculation (K₀): highest bid with P ≥ 50%

2. **Navigation System**
   - Simple two-screen flow with arrow-based navigation
   - Right arrow on Screen 1 → Screen 2
   - Left arrow on Screen 2 → Screen 1

3. **Digital Crown Integration**
   - Screen 1: Adjust total dice count
   - Screen 2: Adjust current bid value

4. **Visual Design**
   - Dark background for battery efficiency
   - Color-coded probabilities: Green (≥50%), Yellow (30-49%), Red (<30%)
   - SF system font with varying sizes for hierarchy

### Performance Requirements
- Probability updates must render in <50ms
- Total app size should remain under 50KB
- Precomputed table should be optimized for space

## Development Workflow

The project includes comprehensive documentation:
- `docs/prd.txt`: Full Product Requirements Document
- `docs/tasks.json`: Detailed task breakdown with implementation steps

When implementing features:
1. Refer to the PRD for exact requirements and UI specifications
2. Follow the task breakdown in tasks.json for systematic development
3. Ensure all probability calculations match the mathematical specifications
4. Test on actual Apple Watch hardware when possible for Crown sensitivity

## Testing Strategy

- Unit tests for probability calculations and break-even logic
- UI tests for navigation flow and Crown interaction
- Performance tests to ensure <50ms update times
- Manual testing on physical device for haptic feedback and Crown sensitivity