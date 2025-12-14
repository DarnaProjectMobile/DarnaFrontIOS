//
//  RouletteView.swift
//  DarnaApp
//

import SwiftUI

/// Vue principale de la roue de la fortune
struct RouletteView: View {
    let config: RouletteConfig
    @Binding var rotation: Double
    @Binding var isSpinning: Bool
    let onSpin: () -> Void
    
    private let wheelSize: CGFloat = 280
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                // Indicateur en haut (flèche pointant vers le bas)
                VStack {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 30))
                        .foregroundColor(AppTheme.primary)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    Spacer()
                }
                .zIndex(10)
                
                // La roue elle-même
                ZStack {
                    // Ombre de la roue
                    Circle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: wheelSize + 10, height: wheelSize + 10)
                        .blur(radius: 10)
                        .offset(y: 5)
                    
                    // Roue avec segments
                    ZStack {
                        ForEach(0..<config.options.count, id: \.self) { index in
                            let anglePerSegment = 360.0 / Double(config.options.count)
                            let startAngle = anglePerSegment * Double(index) - 90
                            let endAngle = startAngle + anglePerSegment
                            
                            RouletteSegmentView(
                                text: config.options[index],
                                color: config.segmentColors[index],
                                startAngle: startAngle,
                                endAngle: endAngle,
                                radius: wheelSize / 2
                            )
                        }
                    }
                    .frame(width: wheelSize, height: wheelSize)
                    .rotationEffect(Angle(degrees: rotation))
                    .animation(
                        isSpinning ? .easeOut(duration: RouletteEngine.spinDuration) : .default,
                        value: rotation
                    )
                    
                    // Centre de la roue
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.gray.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(AppTheme.primary, lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .frame(width: wheelSize, height: wheelSize)
            }
            .padding(.top, 20)
            
            // Bouton de lancement
            Button(action: {
                if !isSpinning {
                    onSpin()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: isSpinning ? "hourglass" : "play.fill")
                        .font(.system(size: 20))
                    Text(isSpinning ? "En cours..." : "Tourner la roue")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: isSpinning ? [Color.gray, Color.gray.opacity(0.8)] : [AppTheme.primary, AppTheme.primary.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: AppTheme.primary.opacity(isSpinning ? 0 : 0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(isSpinning)
            .padding(.horizontal, 30)
        }
    }
}
