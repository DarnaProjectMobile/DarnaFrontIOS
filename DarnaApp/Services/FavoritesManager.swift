//
//  FavoritesManager.swift
//  DarnaApp
//

import Foundation

extension Notification.Name {
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
}

@MainActor
final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    private init() {
        loadFavorites()
    }
    
    @Published private(set) var favoritePropertyIds: Set<String> = []
    
    private let favoritesKey = "FavoriteProperties"
    
    // MARK: - Public Methods
    
    func isFavorite(propertyId: String) -> Bool {
        return favoritePropertyIds.contains(propertyId)
    }
    
    func toggleFavorite(propertyId: String) {
        if favoritePropertyIds.contains(propertyId) {
            favoritePropertyIds.remove(propertyId)
        } else {
            favoritePropertyIds.insert(propertyId)
        }
        saveFavorites()
    }
    
    func addFavorite(propertyId: String) {
        favoritePropertyIds.insert(propertyId)
        saveFavorites()
    }
    
    func removeFavorite(propertyId: String) {
        favoritePropertyIds.remove(propertyId)
        saveFavorites()
    }
    
    func clearFavorites() {
        favoritePropertyIds.removeAll()
        saveFavorites()
    }
    
    func getFavoritePropertyIds() -> [String] {
        return Array(favoritePropertyIds)
    }
    
    // MARK: - Private Methods
    
    private func saveFavorites() {
        let array = Array(favoritePropertyIds)
        UserDefaults.standard.set(array, forKey: favoritesKey)
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    private func loadFavorites() {
        if let array = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoritePropertyIds = Set(array)
        }
    }
}

