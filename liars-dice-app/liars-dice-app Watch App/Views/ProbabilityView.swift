//
//  ProbabilityView.swift
//  liars-dice-app Watch App
//
//  Screen 2: Display bid probability with color-coded feedback
//

import SwiftUI

struct ProbabilityView: View {
    @EnvironmentObject var gameState: GameState
    @State private var crownValue = 0.0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 5) {
                // Header with break-even
                Text("Break-even: \(gameState.breakEvenBid)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                Spacer()
                
                // Current bid display
                VStack(spacing: 12) {
                    Text("Bid")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.8))
                    
                    Text("\(gameState.currentBid)")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .focusable()
                        .digitalCrownRotation(
                            $crownValue,
                            from: 0,
                            through: Double(gameState.totalDiceCount),
                            by: 1,
                            sensitivity: .medium,
                            isContinuous: false,
                            isHapticFeedbackEnabled: true
                        )
                        .onChange(of: crownValue) { newValue in
                            gameState.updateCurrentBid(Int(newValue))
                        }
                        .onAppear {
                            crownValue = Double(gameState.currentBid)
                        }
                    
                    // Probability display with color coding
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(gameState.probabilityColor.opacity(0.3))
                            .frame(height: 45)
                        
                        Text(gameState.probabilityPercentage)
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundColor(gameState.probabilityColor)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Probability description
                Text(gameState.probabilityDescription)
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.bottom, 10)
            }
            
            // Left arrow for navigation back
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
                
                Spacer()
            }
            .padding(.leading, 5)
        }
        .navigationBarHidden(true)
    }
}