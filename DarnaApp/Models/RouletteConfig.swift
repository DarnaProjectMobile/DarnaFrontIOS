//
//  RouletteConfig.swift
//  DarnaApp
//

import Foundation
import SwiftUI

/// Configuration pour la roue de la fortune
struct RouletteConfig: Codable, Equatable {
    let options: [String]           // Ex: ["-10%", "-20%", "-50%", "Rien gagné"]
    let probabilities: [Double]     // Ex: [0.3, 0.2, 0.1, 0.4]
    let colors: [String]?           // Hex colors optionnels
    
    init(options: [String], probabilities: [Double], colors: [String]? = nil) {
        self.options = options
        self.probabilities = probabilities
        self.colors = colors
    }
    
    /// Couleurs par défaut pour la roue
    var segmentColors: [Color] {
        if let colors = colors {
            return colors.map { Color(hex: $0) ?? .blue }
        }
        // Palette de couleurs vives par défaut
        let defaultColors: [Color] = [
            Color(hex: "#FF6B9D") ?? .pink,      // Rose vif
            Color(hex: "#4ECDC4") ?? .teal,      // Turquoise
            Color(hex: "#FFE66D") ?? .yellow,    // Jaune
            Color(hex: "#A8E6CF") ?? .green,     // Vert menthe
            Color(hex: "#FF8B94") ?? .red,       // Rouge corail
            Color(hex: "#B4A7D6") ?? .purple,    // Violet pastel
            Color(hex: "#95E1D3") ?? .cyan,      // Cyan
            Color(hex: "#FFDAC1") ?? .orange     // Orange pêche
        ]
        
        var result: [Color] = []
        for i in 0..<options.count {
            result.append(defaultColors[i % defaultColors.count])
        }
        return result
    }
    
    /// Valide que la configuration est correcte
    var isValid: Bool {
        guard options.count == probabilities.count else { return false }
        guard !options.isEmpty else { return false }
        let sum = probabilities.reduce(0, +)
        return abs(sum - 1.0) < 0.01 // Tolérance pour les erreurs d'arrondi
    }
}

// Extension pour convertir hex en Color
// COMMENTÉ: Cette extension est déjà définie ailleurs dans le projet
/*
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
*/
