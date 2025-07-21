//
//  CrownTestView.swift
//  liars-dice-app Watch App
//
//  Test view to debug Digital Crown rotation issues
//

import SwiftUI

struct CrownTestView: View {
    @State private var testValue = 1.0
    @State private var displayValue = 1
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Crown Test")
                .font(.headline)
            
            Text("Display: \(displayValue)")
                .font(.title2)
            
            Text("Raw: \(String(format: "%.1f", testValue))")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Visual die representation
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                
                Text("\(displayValue)")
                    .font(.title)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .focusable(true)
        .digitalCrownRotation(
            $testValue,
            from: 1,
            through: 6,
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: testValue) { _, newValue in
            displayValue = Int(newValue)
            print("CrownTest: Crown changed to: \(newValue), display: \(displayValue)")
        }
        .onAppear {
            print("CrownTest: View appeared with initial value: \(testValue)")
        }
    }
}

#Preview {
    CrownTestView()
}