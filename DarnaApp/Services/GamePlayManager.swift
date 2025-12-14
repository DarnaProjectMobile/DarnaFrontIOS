//
//  GamePlayManager.swift
//  DarnaApp
//
//  Gestionnaire de persistance pour les jeux joués par utilisateur

import Foundation

/// Gère la persistance des jeux joués par utilisateur
final class GamePlayManager {
    static let shared = GamePlayManager()
    
    private let userDefaults = UserDefaults.standard
    private let playedGamesKey = "com.darna.playedGames"
    
    private init() {}
    
    /// Vérifie si l'utilisateur a déjà joué à cette publicité
    func hasUserPlayed(userId: String, publiciteId: String) -> Bool {
        let key = "\(userId)_\(publiciteId)"
        return userDefaults.bool(forKey: key)
    }
    
    /// Marque une publicité comme jouée par l'utilisateur
    func markAsPlayed(userId: String, publiciteId: String) {
        let key = "\(userId)_\(publiciteId)"
        userDefaults.set(true, forKey: key)
    }
    
    /// Réinitialise un jeu spécifique pour permettre de rejouer
    func resetGame(userId: String, publiciteId: String) {
        let key = "\(userId)_\(publiciteId)"
        userDefaults.removeObject(forKey: key)
    }
    
    /// Réinitialise les jeux joués pour un utilisateur (utile pour les tests)
    func resetGamesForUser(userId: String) {
        let keys = userDefaults.dictionaryRepresentation().keys
        for key in keys {
            if key.hasPrefix("\(userId)_") {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}
