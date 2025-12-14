//
//  RouletteEngine.swift
//  DarnaApp
//

import Foundation

/// Moteur de calcul pour la roue de la fortune
class RouletteEngine {
    
    /// Durée de l'animation de rotation (en secondes)
    static let spinDuration: Double = 2.5
    
    /// Nombre de tours complets avant de s'arrêter
    static let numberOfSpins: Double = 5.0
    
    /// Détermine le résultat gagnant basé sur les probabilités
    /// - Parameters:
    ///   - options: Liste des options possibles
    ///   - probabilities: Probabilités correspondantes (doivent sommer à 1.0)
    /// - Returns: L'option gagnante et l'index
    static func spin(options: [String], probabilities: [Double]) -> (result: String, index: Int) {
        guard options.count == probabilities.count, !options.isEmpty else {
            return (options.first ?? "Erreur", 0)
        }
        
        // Générer un nombre aléatoire entre 0 et 1
        let random = Double.random(in: 0...1)
        
        // Déterminer l'option gagnante basée sur les probabilités cumulatives
        var cumulativeProbability = 0.0
        for (index, probability) in probabilities.enumerated() {
            cumulativeProbability += probability
            if random <= cumulativeProbability {
                return (options[index], index)
            }
        }
        
        // Fallback (ne devrait jamais arriver)
        return (options.last ?? "Erreur", options.count - 1)
    }
    
    /// Calcule l'angle final de rotation pour l'animation
    /// - Parameters:
    ///   - winningIndex: Index de l'option gagnante
    ///   - totalOptions: Nombre total d'options
    /// - Returns: Angle en degrés
    static func calculateFinalAngle(winningIndex: Int, totalOptions: Int) -> Double {
        guard totalOptions > 0 else { return 0 }
        
        // Angle par segment
        let anglePerSegment = 360.0 / Double(totalOptions)
        
        // Angle du centre du segment gagnant
        let winningAngle = anglePerSegment * Double(winningIndex) + (anglePerSegment / 2.0)
        
        // Ajouter plusieurs tours complets + un offset aléatoire pour plus de naturel
        let randomOffset = Double.random(in: -10...10)
        let totalRotation = (numberOfSpins * 360.0) + winningAngle + randomOffset
        
        return totalRotation
    }
    
    /// Calcule l'angle de rotation pour pointer vers le haut (position 12h)
    /// - Parameters:
    ///   - winningIndex: Index de l'option gagnante
    ///   - totalOptions: Nombre total d'options
    /// - Returns: Angle en degrés pour que le segment gagnant soit en haut
    static func calculateAngleToTop(winningIndex: Int, totalOptions: Int) -> Double {
        guard totalOptions > 0 else { return 0 }
        
        let anglePerSegment = 360.0 / Double(totalOptions)
        
        // L'angle nécessaire pour amener le segment gagnant vers le haut
        // On soustrait 90° car le premier segment commence à droite (3h)
        let angleToTop = -(anglePerSegment * Double(winningIndex)) - 90.0
        
        // Ajouter plusieurs tours complets pour l'effet de rotation
        let totalRotation = (numberOfSpins * 360.0) + angleToTop
        
        // Ajouter un petit offset aléatoire
        let randomOffset = Double.random(in: -5...5)
        
        return totalRotation + randomOffset
    }
}
