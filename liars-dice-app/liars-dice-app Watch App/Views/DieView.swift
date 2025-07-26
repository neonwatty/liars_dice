//
//  DieView.swift
//  liars-dice-app Watch App
//
//  Reusable die component for displaying dice faces
//

import SwiftUI

struct DieView: View {
    let faceValue: Int?
    let size: CGFloat
    let isSelected: Bool
    
    init(faceValue: Int?, size: CGFloat = 32, isSelected: Bool = false) {
        self.faceValue = faceValue
        self.size = size
        self.isSelected = isSelected
    }
    
    var body: some View {
        ZStack {
            // Die background
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(backgroundColor)
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.2)
                        .strokeBorder(borderColor, lineWidth: isSelected ? 2 : 1)
                )
            
            // Die face or empty state
            if let value = faceValue {
                dieFaceView(for: value)
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: size * 0.4, weight: .medium))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue.opacity(0.3)
        } else if faceValue != nil {
            return .white.opacity(0.9)
        } else {
            return .gray.opacity(0.2)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .blue
        } else if faceValue != nil {
            return .gray
        } else {
            return .gray.opacity(0.5)
        }
    }
    
    @ViewBuilder
    private func dieFaceView(for value: Int) -> some View {
        let dotSize = size * 0.15
        let spacing = size * 0.25
        
        switch value {
        case 1:
            Circle()
                .fill(Color.black)
                .frame(width: dotSize, height: dotSize)
        case 2:
            VStack(spacing: spacing) {
                HStack {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
            }
            .frame(width: size * 0.6, height: size * 0.6)
        case 3:
            VStack(spacing: spacing * 0.7) {
                HStack {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
            }
            .frame(width: size * 0.6, height: size * 0.6)
        case 4:
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
            }
        case 5:
            VStack(spacing: spacing * 0.8) {
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
                HStack {
                    Spacer()
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Spacer()
                }
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
            }
        case 6:
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
            }
        default:
            Text("\(value)")
                .font(.system(size: size * 0.5, weight: .bold))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 10) {
            ForEach(1...6, id: \.self) { value in
                DieView(faceValue: value, size: 40)
            }
        }
        
        HStack(spacing: 10) {
            DieView(faceValue: nil, size: 40)
            DieView(faceValue: 3, size: 40, isSelected: true)
        }
    }
    .padding()
    .background(Color.black)
}