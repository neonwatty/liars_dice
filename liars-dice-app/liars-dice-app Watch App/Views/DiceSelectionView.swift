//
//  DiceSelectionView.swift
//  liars-dice-app Watch App
//
//  Screen 1: Select total dice in play using Digital Crown
//

import SwiftUI

struct DiceSelectionView: View {
    @EnvironmentObject var gameState: GameState
    @State private var crownValue = 0.0
    @State private var isNavigating = false
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // Header
                Text("Dice in Play")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                Spacer()
                
                // Large dice count display
                Text("\(gameState.totalDiceCount)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .focusable()
                    .digitalCrownRotation(
                        $crownValue,
                        from: 1,
                        through: 40,
                        by: 1,
                        sensitivity: .medium,
                        isContinuous: false,
                        isHapticFeedbackEnabled: true
                    )
                    .onChange(of: crownValue) { newValue in
                        gameState.updateTotalDice(Int(newValue))
                    }
                    .onAppear {
                        crownValue = Double(gameState.totalDiceCount)
                    }
                
                Spacer()
                
                // Navigation hint
                Text("Tap arrow to continue")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.bottom, 10)
            }
            
            // Right arrow for navigation
            HStack {
                Spacer()
                
                Button(action: {
                    isNavigating = true
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isNavigating ? 0.9 : 1.0)
            }
            .padding(.trailing, 5)
        }
        .navigationDestination(isPresented: $isNavigating) {
            ProbabilityView()
        }
        .navigationBarHidden(true)
    }
}