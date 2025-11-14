//
//  AdAPIService.swift
//  DarnaApp
//

import Foundation

protocol AdAPIServiceProtocol {
    func fetchAds() async throws -> [AdDTO]
    func createAd(_ ad: AdDTO) async throws -> AdDTO
    func updateAd(_ ad: AdDTO) async throws -> AdDTO
    func deleteAd(id: UUID) async throws
}

class AdAPIService: AdAPIServiceProtocol {
    // TODO: Mettre à jour avec l'URL de votre backend NestJS
    private let baseURL = "https://api.darnaapp.com/api/ads"
    
    // MARK: - Mock Implementation (Mode statique - pas de backend pour l'instant)
    // Ces méthodes simulent les appels API mais retournent des données statiques
    
    func fetchAds() async throws -> [AdDTO] {
        // Simulation d'un délai réseau
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 secondes
        
        // Données mockées statiques
        let mockAds: [Ad] = [
            Ad(
                title: "Réduction Étudiants",
                brand: "BlueCoffee",
                type: .reduction,
                discountText: "-20%",
                description: "Réduction valable sur toutes les boissons jusqu'à fin du mois.",
                promoCode: "STUDENT20",
                startDate: Date().addingTimeInterval(-86400 * 3),
                endDate: Date().addingTimeInterval(86400 * 20),
                imageURL: nil
            ),
            Ad(
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
        ]
        
        return mockAds.map { $0.toDTO() }
    }
    
    func createAd(_ ad: AdDTO) async throws -> AdDTO {
        // Simulation d'un délai réseau
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Simuler la création (le backend générerait un ID)
        var createdAd = ad
        // Dans un vrai backend, l'ID serait généré par le serveur
        if createdAd.id == nil {
            // Pour le mock, on génère un ID localement
            // En production, le serveur le générera
        }
        
        return createdAd
    }
    
    func updateAd(_ ad: AdDTO) async throws -> AdDTO {
        // Simulation d'un délai réseau
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Simuler la mise à jour
        return ad
    }
    
    func deleteAd(id: UUID) async throws {
        // Simulation d'un délai réseau
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Simuler la suppression
        // En production, le backend supprimerait l'annonce
    }
    
    // MARK: - Real Implementation (À décommenter quand le backend sera prêt)
    /*
    func fetchAds() async throws -> [AdDTO] {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // TODO: Ajouter le token d'authentification si nécessaire
        // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let ads = try JSONDecoder().decode([AdDTO].self, from: data)
            return ads
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func createAd(_ ad: AdDTO) async throws -> AdDTO {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // TODO: Ajouter le token d'authentification si nécessaire
        request.httpBody = try JSONEncoder().encode(ad)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            let createdAd = try JSONDecoder().decode(AdDTO.self, from: data)
            return createdAd
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func updateAd(_ ad: AdDTO) async throws -> AdDTO {
        guard let id = ad.id,
              let url = URL(string: "\(baseURL)/\(id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // TODO: Ajouter le token d'authentification si nécessaire
        request.httpBody = try JSONEncoder().encode(ad)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            let updatedAd = try JSONDecoder().decode(AdDTO.self, from: data)
            return updatedAd
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func deleteAd(id: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        // TODO: Ajouter le token d'authentification si nécessaire
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
    }
    */
}
