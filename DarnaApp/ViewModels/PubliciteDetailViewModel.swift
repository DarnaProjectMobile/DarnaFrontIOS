//
//  PubliciteDetailViewModel.swift
//  DarnaApp
//

import Foundation
import SwiftUI

@MainActor
class PubliciteDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var publicite: Publicite
    @Published var angleRotation: Double = 0
    @Published var isSpinning: Bool = false
    @Published var gameResult: String?
    @Published var isWinResult: Bool?
    @Published var showResult: Bool = false
    @Published var showWinAnimation: Bool = false
    @Published var showQRCode: Bool = false
    @Published var hasPlayedGame: Bool = false
    
    // MARK: - Computed Properties
    var rouletteConfig: RouletteConfig? {
        guard publicite.publiciteType == .jeu else { return nil }
        
        // Essayer de parser les détails du jeu
        if let detailJeu = publicite.detailJeu {
            let options = detailJeu.gains ?? ["Rien gagné"]
            let probabilities = detailJeu.probabilites ?? [1.0]
            
            // Normaliser les probabilités si nécessaire
            let sum = probabilities.reduce(0, +)
            let normalizedProbs = sum > 0 ? probabilities.map { $0 / sum } : probabilities
            
            return RouletteConfig(options: options, probabilities: normalizedProbs)
        }
        
        // Configuration par défaut si pas de détails
        return RouletteConfig(
            options: ["-10%", "-20%", "-50%", "Rien gagné"],
            probabilities: [0.3, 0.2, 0.1, 0.4]
        )
    }
    
    var promoCode: String {
        // Générer un code promo basé sur l'ID de la publicité
        let prefix = publicite.type.prefix(3).uppercased()
        let suffix = String(publicite.id.suffix(6)).uppercased()
        return "\(prefix)\(suffix)"
    }
    
    // MARK: - Initialization
    init(publicite: Publicite) {
        self.publicite = publicite
        
        // Vérifier si l'utilisateur a déjà joué
        if let userId = AuthenticationManager.shared.currentUser?.id {
            hasPlayedGame = GamePlayManager.shared.hasUserPlayed(
                userId: userId,
                publiciteId: publicite.id
            )
        }
    }
    
    // MARK: - Actions
    func jouerRoulette() {
        guard !isSpinning, !hasPlayedGame else { return }
        
        // Vérifier à nouveau avec le manager
        if let userId = AuthenticationManager.shared.currentUser?.id {
            if GamePlayManager.shared.hasUserPlayed(userId: userId, publiciteId: publicite.id) {
                hasPlayedGame = true
                return
            }
        }
        guard let config = rouletteConfig, config.isValid else {
            gameResult = "Configuration invalide"
            showResult = true
            return
        }
        
        // Lancer le jeu
        isSpinning = true
        SoundManager.shared.playSpinSound()
        
        // Déterminer le résultat
        let (result, index) = RouletteEngine.spin(
            options: config.options,
            probabilities: config.probabilities
        )
        
        // Calculer l'angle final
        let finalAngle = RouletteEngine.calculateAngleToTop(
            winningIndex: index,
            totalOptions: config.options.count
        )
        
        // Animation de rotation
        withAnimation(.easeInOut(duration: RouletteEngine.spinDuration)) {
            angleRotation = finalAngle
        }
        
        // Afficher le résultat après l'animation
        DispatchQueue.main.asyncAfter(deadline: .now() + RouletteEngine.spinDuration + 0.3) {
            let isWin = !result.lowercased().contains("rien")
            self.gameResult = isWin ? result : "Dommage, pas de gain cette fois."
            self.isWinResult = isWin
            self.isSpinning = false
            self.hasPlayedGame = true
            
            // Marquer comme joué dans la persistance
            if let userId = AuthenticationManager.shared.currentUser?.id {
                GamePlayManager.shared.markAsPlayed(
                    userId: userId,
                    publiciteId: self.publicite.id
                )
            }
            
            isWin ? SoundManager.shared.playWinSound() : SoundManager.shared.playLoseSound()
            if isWin { self.showWinAnimation = true }
            
            withAnimation {
                self.showResult = true
            }
        }
    }
    
    func resetGame() {
        // Ne pas réinitialiser le statut de jeu - l'utilisateur ne peut jouer qu'une seule fois par annonce
        // Cette fonction est gardée pour réinitialiser l'affichage visuel seulement
        angleRotation = 0
        isSpinning = false
        gameResult = nil
        isWinResult = nil
        showResult = false
        showWinAnimation = false
        // Ne pas réinitialiser hasPlayedGame - l'utilisateur a déjà joué à cette annonce
    }
    
    func utiliserReduction() {
        showQRCode = true
    }
    
    func utiliserCodePromo() {
        showQRCode = true
    }
}
