//
//  SponsorAdsViewModel.swift
//  DarnaApp
//

import Foundation
import SwiftUI

@MainActor
class SponsorAdsViewModel: ObservableObject {
    @Published var ads: [Ad] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: AdRepositoryProtocol
    
    init(repository: AdRepositoryProtocol = AdRepository()) {
        self.repository = repository
    }
    
    func loadAds() async {
        isLoading = true
        errorMessage = nil
        
        do {
            ads = try await repository.getAllAds()
        } catch {
            errorMessage = error.localizedDescription
            print("Erreur lors du chargement: \(error)")
        }
        
        isLoading = false
    }
    
    func createAd(_ ad: Ad) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let createdAd = try await repository.createAd(ad)
            ads.insert(createdAd, at: 0)
        } catch {
            errorMessage = error.localizedDescription
            print("Erreur lors de la création: \(error)")
        }
        
        isLoading = false
    }
    
    func updateAd(_ ad: Ad) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedAd = try await repository.updateAd(ad)
            if let index = ads.firstIndex(where: { $0.id == updatedAd.id }) {
                ads[index] = updatedAd
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Erreur lors de la mise à jour: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteAd(_ ad: Ad) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.deleteAd(id: ad.id)
            ads.removeAll { $0.id == ad.id }
        } catch {
            errorMessage = error.localizedDescription
            print("Erreur lors de la suppression: \(error)")
        }
        
        isLoading = false
    }
    
    func duplicateAd(_ ad: Ad) async {
        var copy = ad
        copy.id = UUID()
        copy.title += " (copie)"
        await createAd(copy)
    }
}
