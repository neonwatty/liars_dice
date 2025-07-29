//
//  HandEntryView.swift
//  liars-dice-app Watch App
//
//  Screen 3: Enter hand configuration for conditional probability calculation
//

import SwiftUI

struct HandEntryView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDieIndex: Int = 0
    @State private var myDiceCountCrownValue = 0.0
    @State private var dieValueCrownValue = 1.0
    @FocusState private var focusedMode: CrownMode?
    @State private var crownMode: CrownMode = .myDiceCount
    @State private var hasInitializedDieSelection = false
    @State private var refreshID = UUID()
    
    private enum CrownMode {
        case myDiceCount
        case dieValue
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // Header
                headerView
                
                // Main content area with scroll
                ScrollView {
                    VStack(spacing: 12) {
                        if gameState.myDiceCount > 0 {
                            // Dice grid
                            diceGridView
                            
                            // Probability comparison
                            probabilityComparisonView
                        } else {
                            // Message when no dice
                            VStack(spacing: 8) {
                                Image(systemName: "questionmark.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("Set your dice count above")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 20)
                        }
                    }
                    .padding(.bottom, 10) // Extra padding at bottom
                }
            }
            .padding(.horizontal, 8)
            
            // Navigation back button
            backButtonView
        }
        .navigationBarHidden(true)
        .onAppear {
            setupInitialState()
        }
        .onChange(of: gameState.handConfiguration) { _, newValue in
            print("HandEntry: handConfiguration changed, newValue exists: \(newValue != nil), hasInitializedDieSelection: \(hasInitializedDieSelection)")
            if newValue != nil && !hasInitializedDieSelection {
                print("HandEntry: Calling selectFirstAvailableDie from onChange")
                // Only select first die on initial configuration setup
                selectFirstAvailableDie()
                hasInitializedDieSelection = true
            } else if newValue == nil {
                print("HandEntry: Resetting hasInitializedDieSelection flag")
                // Reset flag when configuration is cleared
                hasInitializedDieSelection = false
            } else {
                print("HandEntry: Not calling selectFirstAvailableDie - hasInitializedDieSelection is true")
            }
        }
        .onChange(of: gameState.myDiceCount) { oldValue, newValue in
            print("HandEntry: myDiceCount changed from \(oldValue) to \(newValue)")
            // Update crown value to match
            if crownMode == .myDiceCount {
                myDiceCountCrownValue = Double(newValue)
            }
            // Ensure hand configuration exists when dice count changes
            if newValue > 0 && gameState.handConfiguration == nil {
                print("HandEntry: myDiceCount changed but no hand configuration - creating one")
                gameState.initializeHandConfiguration()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 4) {
            Text("My Dice")
                .font(.caption2)
                .foregroundColor(.gray)
            
            Button(action: {
                toggleCrownMode(.myDiceCount)
            }) {
                Text("\(gameState.myDiceCount)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(crownMode == .myDiceCount ? .blue : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(crownMode == .myDiceCount ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .focusable(crownMode == .myDiceCount)
            .focused($focusedMode, equals: .myDiceCount)
            .digitalCrownRotation(
                $myDiceCountCrownValue,
                from: 0,
                through: Double(gameState.totalDiceCount),
                by: 1,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: myDiceCountCrownValue) { oldValue, newValue in
                print("HandEntry: myDiceCount onChange - old: \(oldValue), new: \(newValue), mode: \(crownMode), focused: \(String(describing: focusedMode))")
                if crownMode == .myDiceCount && oldValue != newValue {
                    let newCount = Int(round(newValue))
                    let oldCount = gameState.myDiceCount
                    if newCount != oldCount {
                        print("HandEntry: Updating myDiceCount from \(oldCount) to \(newCount)")
                        gameState.updateMyDiceCount(newCount)
                        
                        // Initialize hand configuration if we now have dice and didn't before
                        if newCount > 0 && oldCount == 0 && gameState.handConfiguration == nil {
                            print("HandEntry: Creating hand configuration after dice count update")
                            gameState.initializeHandConfiguration()
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Dice Grid
    
    private var diceGridView: some View {
        let columnCount = diceGridColumnCount
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount)
        
        return LazyVGrid(columns: columns, spacing: 8) {
            diceGridContent
        }
        .padding(.leading, 50) // Protected margin to avoid back button
        .padding(.trailing, 10)
        .focusable(crownMode == .dieValue)
        .focused($focusedMode, equals: .dieValue)
        .digitalCrownRotation(
            $dieValueCrownValue,
            from: 1,
            through: 6,
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: dieValueCrownValue) { oldValue, newValue in
            print("HandEntry: diceGrid onChange - old: \(oldValue), new: \(newValue), mode: \(crownMode), focused: \(String(describing: focusedMode)), selectedDieIndex: \(selectedDieIndex))")
            if crownMode == .dieValue && oldValue != newValue {
                print("HandEntry: Crown value changed in dieValue mode - updating die")
                let value = Int(round(newValue))
                print("HandEntry: Updating die \(selectedDieIndex) to value \(value)")
                
                // Check if hand configuration exists before updating
                if gameState.handConfiguration != nil {
                    gameState.updateHandDie(at: selectedDieIndex, to: value)
                    // Force view refresh
                    refreshID = UUID()
                    
                    // Verify the update
                    if let updatedValue = gameState.handConfiguration?.getDie(at: selectedDieIndex) {
                        print("HandEntry: After crown update, die \(selectedDieIndex) value is: \(updatedValue)")
                    } else {
                        print("HandEntry: ERROR - Die \(selectedDieIndex) is nil after crown update!")
                    }
                } else {
                    print("HandEntry: ERROR - No hand configuration exists, cannot update die!")
                    print("HandEntry: Current state - myDiceCount: \(gameState.myDiceCount), selectedDieIndex: \(selectedDieIndex)")
                    // Try to recreate hand configuration if we have dice
                    if gameState.myDiceCount > 0 {
                        print("HandEntry: Attempting to recreate hand configuration")
                        gameState.initializeHandConfiguration()
                        // Try updating again after recreating
                        if gameState.handConfiguration != nil {
                            gameState.updateHandDie(at: selectedDieIndex, to: value)
                            refreshID = UUID()
                            print("HandEntry: Successfully recreated hand configuration and updated die")
                        }
                    }
                }
            } else {
                print("HandEntry: Crown onChange but not in dieValue mode or value unchanged - ignoring")
            }
        }
    }
    
    @ViewBuilder
    private var diceGridContent: some View {
        ForEach(0..<gameState.myDiceCount, id: \.self) { index in
            DieView(
                faceValue: gameState.handConfiguration?.getDie(at: index),
                size: dieSize,
                isSelected: selectedDieIndex == index && crownMode == .dieValue
            )
            .id("\(index)-\(refreshID)")
            .onTapGesture {
                selectDie(at: index)
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                // Fallback: If die is selected but crown isn't working, cycle through values
                if selectedDieIndex == index && crownMode == .dieValue {
                    let currentValue = gameState.handConfiguration?.getDie(at: index) ?? 0
                    let nextValue = (currentValue % 6) + 1
                    print("HandEntry: Long press fallback - cycling die \(index) from \(currentValue) to \(nextValue)")
                    gameState.updateHandDie(at: index, to: nextValue)
                    dieValueCrownValue = Double(nextValue)
                    refreshID = UUID()
                }
            }
            .accessibilityLabel("Die \(index + 1)")
            .accessibilityValue(dieAccessibilityValue(at: index))
            .accessibilityHint("Tap to select, then rotate the Digital Crown to set value")
            .overlay(
                // Visual indicator when die is selected and ready for crown input
                RoundedRectangle(cornerRadius: dieSize * 0.2)
                    .strokeBorder(Color.blue, lineWidth: 2)
                    .opacity(selectedDieIndex == index && crownMode == .dieValue ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: selectedDieIndex)
            )
        }
    }
    
    // MARK: - Probability Comparison
    
    private var probabilityComparisonView: some View {
        VStack(spacing: 4) {
            HStack {
                // Original probability
                VStack(spacing: 2) {
                    Text("Original")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.8))
                    
                    Text(gameState.specificFaceProbabilityPercentage)
                        .font(.caption)
                        .foregroundColor(gameState.specificFaceProbabilityColor)
                }
                
                Spacer()
                
                // Improvement indicator
                VStack(spacing: 2) {
                    Image(systemName: probabilityImprovementIcon)
                        .font(.caption2)
                        .foregroundColor(probabilityImprovementColor)
                    
                    Text(gameState.probabilityImprovementString)
                        .font(.caption2)
                        .foregroundColor(probabilityImprovementColor)
                }
                
                Spacer()
                
                // Conditional probability
                VStack(spacing: 2) {
                    Text("With Hand")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.8))
                    
                    Text(gameState.conditionalProbabilityPercentage)
                        .font(.caption)
                        .foregroundColor(gameState.conditionalProbabilityColor)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    // MARK: - Back Button
    
    private var backButtonView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Back to probability view")
            .accessibilityHint("Return to the probability screen")
            
            Spacer()
        }
        .padding(.leading, 5)
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialState() {
        print("HandEntry: setupInitialState - myDiceCount: \(gameState.myDiceCount), totalDiceCount: \(gameState.totalDiceCount), handConfiguration exists: \(gameState.handConfiguration != nil), hasInitializedDieSelection: \(hasInitializedDieSelection)")
        
        // Start with my dice count mode
        crownMode = .myDiceCount
        myDiceCountCrownValue = Double(gameState.myDiceCount)
        
        // Handle hand configuration initialization and die selection
        if gameState.myDiceCount > 0 {
            if gameState.handConfiguration == nil {
                print("HandEntry: Creating new hand configuration for first visit")
                gameState.initializeHandConfiguration()
                print("HandEntry: After initializeHandConfiguration, handConfiguration exists: \(gameState.handConfiguration != nil)")
                // selectFirstAvailableDie will be called in onChange when config is created
            } else {
                print("HandEntry: Hand configuration exists, selecting first die")
                // Configuration already exists, just select first die
                selectFirstAvailableDie()
            }
        } else {
            print("HandEntry: No dice count set, cannot initialize hand configuration")
        }
    }
    
    private func selectDie(at index: Int) {
        print("HandEntry: selectDie called for index \(index)")
        print("HandEntry: Current crownMode: \(crownMode), handConfiguration exists: \(gameState.handConfiguration != nil)")
        
        selectedDieIndex = index
        toggleCrownMode(.dieValue)
        
        print("HandEntry: After toggleCrownMode, crownMode: \(crownMode), dieValueCrownValue: \(dieValueCrownValue)")
        
        // Update crown value to current die value
        if let value = gameState.handConfiguration?.getDie(at: index) {
            dieValueCrownValue = Double(value)
            print("HandEntry: Die \(index) has existing value: \(value)")
        } else {
            // Start at 1 for crown value but don't set the die automatically
            dieValueCrownValue = 1.0
            print("HandEntry: Die \(index) is unset, crown value set to 1")
        }
    }
    
    private func selectFirstAvailableDie() {
        print("HandEntry: selectFirstAvailableDie called")
        guard let config = gameState.handConfiguration else { 
            print("HandEntry: No hand configuration, returning")
            return 
        }
        
        print("HandEntry: Hand configuration exists with \(config.diceCount) dice")
        
        // Find first unset die
        for i in 0..<config.diceCount {
            if config.getDie(at: i) == nil {
                print("HandEntry: Found unset die at index \(i)")
                selectedDieIndex = i
                toggleCrownMode(.dieValue)
                // Start at 1 for crown value but don't set the die automatically
                dieValueCrownValue = 1.0
                print("HandEntry: Selected unset die at index \(selectedDieIndex), crownMode: \(crownMode)")
                return
            }
        }
        
        // All dice are set, select the first one
        print("HandEntry: All dice are set, selecting first die")
        selectedDieIndex = 0
        toggleCrownMode(.dieValue)
        if let value = config.getDie(at: 0) {
            dieValueCrownValue = Double(value)
            print("HandEntry: Selected first die with value \(value)")
        }
    }
    
    private func toggleCrownMode(_ mode: CrownMode) {
        print("HandEntry: toggleCrownMode to \(mode)")
        crownMode = mode
        
        // Add a small delay to ensure focus transfers properly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.focusedMode = mode
            print("HandEntry: Focus set to \(mode)")
        }
        
        switch mode {
        case .myDiceCount:
            myDiceCountCrownValue = Double(gameState.myDiceCount)
        case .dieValue:
            if let value = gameState.handConfiguration?.getDie(at: selectedDieIndex) {
                dieValueCrownValue = Double(value)
            } else {
                // Start at 1 for crown value but don't set the die automatically
                dieValueCrownValue = 1.0
            }
        }
        print("HandEntry: After toggleCrownMode - crownMode: \(crownMode), focusedMode: \(String(describing: focusedMode)), myDiceCountCrownValue: \(myDiceCountCrownValue), dieValueCrownValue: \(dieValueCrownValue)")
    }
    
    private func dieAccessibilityValue(at index: Int) -> String {
        if let value = gameState.handConfiguration?.getDie(at: index) {
            return "Showing \(value)"
        } else {
            return "Not set"
        }
    }
    
    // MARK: - Computed Properties
    
    private var dieSize: CGFloat {
        switch gameState.myDiceCount {
        case 1...3: return 36
        case 4...6: return 32
        default: return 28 // Minimum size for usability
        }
    }
    
    private var diceGridColumnCount: Int {
        switch gameState.myDiceCount {
        case 1...2: return 1
        case 3...4: return 2
        default: return 2 // Max 2 columns to maintain larger die sizes
        }
    }
    
    private var probabilityImprovementIcon: String {
        let improvement = gameState.probabilityImprovement
        if improvement > 0.01 {
            return "arrow.up"
        } else if improvement < -0.01 {
            return "arrow.down"
        } else {
            return "minus"
        }
    }
    
    private var probabilityImprovementColor: Color {
        let improvement = gameState.probabilityImprovement
        if improvement > 0.01 {
            return .green
        } else if improvement < -0.01 {
            return .red
        } else {
            return .gray
        }
    }
}

#Preview {
    HandEntryView()
        .environmentObject(GameState())
}