//
//  AdRepository.swift
//  DarnaApp
//

import Foundation

protocol AdRepositoryProtocol {
    func getAllAds() async throws -> [Ad]
    func createAd(_ ad: Ad) async throws -> Ad
    func updateAd(_ ad: Ad) async throws -> Ad
    func deleteAd(id: UUID) async throws
}

class AdRepository: AdRepositoryProtocol {
    private let apiService: AdAPIServiceProtocol
    private let localStorage: AdLocalStorageProtocol
    
    init(apiService: AdAPIServiceProtocol = AdAPIService(),
         localStorage: AdLocalStorageProtocol = AdLocalStorage()) {
        self.apiService = apiService
        self.localStorage = localStorage
    }
    
    func getAllAds() async throws -> [Ad] {
        do {
            // Essayer de récupérer depuis l'API
            let dtos = try await apiService.fetchAds()
            let ads = dtos.map { Ad(from: $0) }
            
            // Sauvegarder localement pour le cache
            await localStorage.saveAds(ads)
            
            return ads
        } catch {
            // En cas d'erreur, retourner les données locales (cache)
            let localAds = await localStorage.loadAds()
            if !localAds.isEmpty {
                return localAds
            }
            throw error
        }
    }
    
    func createAd(_ ad: Ad) async throws -> Ad {
        let dto = ad.toDTO()
        let createdDTO = try await apiService.createAd(dto)
        let createdAd = Ad(from: createdDTO)
        
        // Mettre à jour le cache local
        await localStorage.addAd(createdAd)
        
        return createdAd
    }
    
    func updateAd(_ ad: Ad) async throws -> Ad {
        let dto = ad.toDTO()
        let updatedDTO = try await apiService.updateAd(dto)
        let updatedAd = Ad(from: updatedDTO)
        
        // Mettre à jour le cache local
        await localStorage.updateAd(updatedAd)
        
        return updatedAd
    }
    
    func deleteAd(id: UUID) async throws {
        try await apiService.deleteAd(id: id)
        
        // Supprimer du cache local
        await localStorage.deleteAd(id: id)
    }
}

// MARK: - Local Storage Protocol (pour le cache)
protocol AdLocalStorageProtocol {
    func saveAds(_ ads: [Ad]) async
    func loadAds() async -> [Ad]
    func addAd(_ ad: Ad) async
    func updateAd(_ ad: Ad) async
    func deleteAd(id: UUID) async
}

class AdLocalStorage: AdLocalStorageProtocol {
    private let saveKey = "SavedAds"
    
    func saveAds(_ ads: [Ad]) async {
        if let encoded = try? JSONEncoder().encode(ads) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func loadAds() async -> [Ad] {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Ad].self, from: data) {
            return decoded
        }
        return []
    }
    
    func addAd(_ ad: Ad) async {
        var ads = await loadAds()
        ads.insert(ad, at: 0)
        await saveAds(ads)
    }
    
    func updateAd(_ ad: Ad) async {
        var ads = await loadAds()
        if let index = ads.firstIndex(where: { $0.id == ad.id }) {
            ads[index] = ad
            await saveAds(ads)
        }
    }
    
    func deleteAd(id: UUID) async {
        var ads = await loadAds()
        ads.removeAll { $0.id == id }
        await saveAds(ads)
    }
}
