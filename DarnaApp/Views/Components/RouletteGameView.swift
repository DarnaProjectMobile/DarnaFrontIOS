//
//  RouletteGameView.swift
//  DarnaApp
//
//  Composant de roulette animée pour les jeux

import SwiftUI

struct RouletteGameView: View {
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var selectedSegment: Int = 0
    @State private var showResult = false
    @State private var hasWon = false
    @State private var wonReduction: ReductionJeu?
    
    // Réductions disponibles dans le jeu
    let reductions: [ReductionJeu]
    
    // Segments générés à partir des réductions + segments "Perdu"
    var segments: [(text: String, color: Color, isWin: Bool, reduction: ReductionJeu?)] {
        var segmentsList: [(text: String, color: Color, isWin: Bool, reduction: ReductionJeu?)] = []
        let colors: [Color] = [.orange, .purple, .pink, .yellow, .green, .blue, .cyan]
        
        // Ajouter les réductions comme segments gagnants
        for (index, reduction) in reductions.enumerated() {
            segmentsList.append(("-\(Int(reduction.pourcentage))%", colors[index % colors.count], true, reduction))
        }
        
        // Ajouter des segments "Perdu" pour équilibrer (au moins 50% de chance de perdre)
        let lostSegments = max(reductions.count, 3) // Au moins autant de segments perdus que de gains
        for i in 0..<lostSegments {
            segmentsList.append(("Perdu", Color.gray, false, nil))
        }
        
        return segmentsList
    }
    
    let onWin: (ReductionJeu) -> Void
    
    // Couleurs pour le gradient
    private var wheelColors: [Color] {
        segments.map { segment in
            segment.isWin ? Color.blue.opacity(0.6) : Color.blue.opacity(0.3)
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            headerSection
            rouletteWheel
            stopButton
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Tentez votre chance!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Appuyez sur STOP pour arrêter la roue et découvrir votre réduction!")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 8)
    }
    
    private var rouletteWheel: some View {
        ZStack {
            wheelShape
            indicatorTriangle
            wheelCenter
            segmentTexts
        }
        .frame(height: 320)
    }
    
    private var wheelShape: some View {
        WheelShape(segments: segments.count)
            .fill(
                AngularGradient(
                    colors: wheelColors,
                    center: .center,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(270)
                )
            )
            .frame(width: 300, height: 300)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
            )
            .rotationEffect(.degrees(rotation))
            .animation(isSpinning ? .linear(duration: 0.1).repeatForever(autoreverses: false) : .easeOut(duration: 2), value: rotation)
    }
    
    private var indicatorTriangle: some View {
        VStack {
            Triangle()
                .fill(Color.blue)
                .frame(width: 28, height: 40)
            Spacer()
        }
        .frame(height: 300)
    }
    
    private var wheelCenter: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 100, height: 100)
            .overlay(
                Circle()
                    .stroke(Color.blue, lineWidth: 3)
            )
    }
    
    @ViewBuilder
    private var segmentTexts: some View {
        ForEach(0..<segments.count, id: \.self) { index in
            segmentText(at: index)
        }
    }
    
    private func segmentText(at index: Int) -> some View {
        let angle = Double(index) * (360.0 / Double(segments.count)) - 90
        let segment = segments[index]
        
        return Group {
            if segment.isWin {
                Text(segment.text)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3)
                    .rotationEffect(.degrees(angle + 90))
                    .offset(y: -120)
                    .rotationEffect(.degrees(-rotation))
            } else {
                Text(segment.text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(angle + 90))
                    .offset(y: -120)
                    .rotationEffect(.degrees(-rotation))
            }
        }
    }
    
    private var stopButton: some View {
        Button(action: {
            if isSpinning {
                stopRoulette()
            } else {
                startRoulette()
            }
        }) {
            Text(isSpinning ? "STOP" : "Jouer")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(isSpinning ? Color.red : AppTheme.primary)
                .cornerRadius(12)
        }
        .disabled(isSpinning && showResult)
        .padding(.horizontal, 40)
    }
    
    private func stopRoulette() {
        guard isSpinning else {
            startRoulette()
            return
        }
        
        isSpinning = false
        
        // Calculer l'angle final pour déterminer le segment
        let finalAngle = rotation.truncatingRemainder(dividingBy: 360)
        let segmentAngle = 360.0 / Double(segments.count)
        let segmentIndex = Int((360 - finalAngle) / segmentAngle) % segments.count
        
        selectedSegment = segmentIndex
        let selectedSegmentData = segments[segmentIndex]
        hasWon = selectedSegmentData.isWin
        wonReduction = selectedSegmentData.reduction
        
        withAnimation(.easeOut(duration: 1)) {
            showResult = true
        }
        
        if hasWon, let reduction = wonReduction {
            // Générer un QR code pour cette réduction spécifique
            let reductionCode = "REDUCTION-\(Int(reduction.pourcentage))-\(Int.random(in: 100000...999999))"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Créer une réduction avec QR code
                var reductionWithQR = reduction
                // Note: En production, le QR code serait généré côté backend
                // Ici on génère un QR code local
                onWin(reduction)
            }
        }
    }
    
    private func startRoulette() {
        isSpinning = true
        showResult = false
        
        // Rotation multiple pour effet réaliste
        let randomSpins = Double.random(in: 5...10)
        rotation = randomSpins * 360 + Double.random(in: 0...360)
    }
}

// Forme de roue avec segments
struct WheelShape: Shape {
    let segments: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let anglePerSegment = 360.0 / Double(segments)
        
        for i in 0..<segments {
            let startAngle = Double(i) * anglePerSegment - 90
            let endAngle = Double(i + 1) * anglePerSegment - 90
            
            path.move(to: center)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(startAngle),
                endAngle: .degrees(endAngle),
                clockwise: false
            )
            path.closeSubpath()
        }
        
        return path
    }
}

// Forme triangulaire pour l'indicateur
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

