//
//  AdsStore.swift
//  DarnaApp
//

import Foundation
import SwiftUI

@MainActor
class AdsStore: ObservableObject {
    @Published var ads: [Ad] = []
    
    init() {
        // Charger les données d'exemple au démarrage (statique, en mémoire uniquement)
        loadExampleAds()
    }
    
    func add(_ ad: Ad) {
        // Ajouter en mémoire uniquement (pas de sauvegarde)
        ads.insert(ad, at: 0)
    }
    
    func update(_ ad: Ad) {
        // Mettre à jour en mémoire uniquement
        if let index = ads.firstIndex(where: { $0.id == ad.id }) {
            ads[index] = ad
        }
    }
    
    func delete(_ ad: Ad) {
        // Supprimer de la mémoire uniquement
        ads.removeAll { $0.id == ad.id }
    }
    
    func delete(at offsets: IndexSet) {
        // Supprimer de la mémoire uniquement
        ads.remove(atOffsets: offsets)
    }
    
    func duplicate(_ ad: Ad) {
        var copy = ad
        copy.id = UUID()
        copy.title += " (copie)"
        add(copy)
    }
    
    // Charger les données d'exemple (statique, en mémoire)
    private func loadExampleAds() {
        let example1 = Ad(
            title: "Réduction Étudiants",
            brand: "BlueCoffee",
            type: .reduction,
            discountText: "-20%",
            description: "Réduction valable sur toutes les boissons jusqu'à fin du mois.",
            promoCode: "STUDENT20",
            startDate: Date().addingTimeInterval(-86400 * 3),
            endDate: Date().addingTimeInterval(86400 * 20),
            imageURL: nil
        )
        
        let example2 = Ad(
            title: "Promo Rentrée",
            brand: "BookStore",
            type: .promo,
            discountText: "2 pour 1",
            description: "Achetez un livre, obtenez le second gratuit !",
            promoCode: "BOOK2FOR1",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            imageURL: nil
        )
        
        ads = [example1, example2]
    }
    
    // Fonction pour réinitialiser avec les données d'exemple (utile pour le debug)
    func resetToExamples() {
        loadExampleAds()
    }
}
