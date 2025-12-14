//
//  ConfettiView.swift
//  DarnaApp
//
//  Animation de confettis native SwiftUI (sans dépendance externe)

import SwiftUI

/// Animation de confettis native SwiftUI
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var isAnimating = false
    
    let colors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan
    ]
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                RoundedRectangle(cornerRadius: piece.isCircle ? 50 : 2)
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(x: piece.x, y: piece.y)
                    .rotationEffect(.degrees(piece.rotation))
                    .opacity(piece.opacity)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Générer 50 confettis
        confettiPieces = (0..<50).map { _ in
            ConfettiPiece(
                id: UUID(),
                x: Double.random(in: 0...UIScreen.main.bounds.width),
                y: -20,
                color: colors.randomElement() ?? .red,
                size: Double.random(in: 8...16),
                isCircle: Bool.random(),
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
        }
        
        isAnimating = true
        
        // Animer chaque confetti
        for index in confettiPieces.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 2.0...3.5)
            let horizontalVelocity = Double.random(in: -100...100)
            let finalY = UIScreen.main.bounds.height + 100
            
            withAnimation(
                .easeOut(duration: duration)
                .delay(delay)
            ) {
                confettiPieces[index].y = finalY
                confettiPieces[index].x += horizontalVelocity
                confettiPieces[index].rotation += Double.random(in: 360...720)
            }
            
            // Faire disparaître progressivement
            withAnimation(
                .easeOut(duration: duration * 0.7)
                .delay(delay + duration * 0.3)
            ) {
                confettiPieces[index].opacity = 0
            }
        }
    }
}

// MARK: - Confetti Piece Model
struct ConfettiPiece: Identifiable {
    let id: UUID
    var x: Double
    var y: Double
    let color: Color
    let size: Double
    let isCircle: Bool
    var rotation: Double
    var opacity: Double
}
