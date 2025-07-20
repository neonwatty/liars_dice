# Claude AI Assistant Documentation

## Project: Liar's Dice Probability Calculator Watch App

### Build & Test Commands

To build and test the watchOS app, use these Xcode commands:

```bash
# Build the app
xcodebuild -scheme "liars-dice-app Watch App" build

# Run tests
xcodebuild -scheme "liars-dice-app Watch App" test

# Clean build folder
xcodebuild -scheme "liars-dice-app Watch App" clean
```

### Swift Type Checking

Swift has built-in type checking during compilation. The Xcode build process automatically performs:
- Type checking
- Syntax validation
- Swift lint checks
- Compiler warnings

### Note on Simulator Issues

If you encounter "Watch-Only Application Stubs are not available" errors when building for simulator, this is a known issue with the container app configuration. The app can still be built and run directly from Xcode IDE.

### Key Files

- **ProbabilityEngine.swift**: Core probability calculations for P(at least k dice show ANY face value)
- **GameState.swift**: Main state management with ObservableObject pattern
- **DiceSelectionView.swift**: Screen 1 - Select total dice with Digital Crown
- **ProbabilityView.swift**: Screen 2 - View probability and break-even threshold
- **OnboardingView.swift**: Tutorial for first-time users

### Testing

The app includes comprehensive unit tests in:
- **ProbabilityEngineTests.swift**: Tests for probability calculations
- **GameStateTests.swift**: Tests for state management

All tests are passing with the updated probability formula.