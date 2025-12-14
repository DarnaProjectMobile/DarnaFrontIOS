//
//  RouletteSegmentView.swift
//  DarnaApp
//

import SwiftUI

/// Vue pour un segment individuel de la roue
struct RouletteSegmentView: View {
    let text: String
    let color: Color
    let startAngle: Double
    let endAngle: Double
    let radius: CGFloat
    
    var body: some View {
        ZStack {
            // Segment coloré
            Path { path in
                path.move(to: CGPoint(x: radius, y: radius))
                path.addArc(
                    center: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: Angle(degrees: startAngle),
                    endAngle: Angle(degrees: endAngle),
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(color)
            
            // Bordure blanche
            Path { path in
                path.move(to: CGPoint(x: radius, y: radius))
                path.addArc(
                    center: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: Angle(degrees: startAngle),
                    endAngle: Angle(degrees: endAngle),
                    clockwise: false
                )
                path.closeSubpath()
            }
            .stroke(Color.white, lineWidth: 2)
            
            // Texte du segment
            Text(text)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                .rotationEffect(Angle(degrees: (startAngle + endAngle) / 2 + 90))
                .offset(
                    x: cos(Angle(degrees: (startAngle + endAngle) / 2).radians) * (radius * 0.65),
                    y: sin(Angle(degrees: (startAngle + endAngle) / 2).radians) * (radius * 0.65)
                )
        }
    }
}
