//
//  Publicite.swift
//  DarnaApp
//

import Foundation

// MARK: - Publicite Model (correspond au backend NestJS)
struct Publicite: Identifiable, Codable, Equatable {
    let id: String           // _id du backend
    let titre: String
    let description: String
    let type: String
    let pourcentageReduction: Double?
    let imageUrl: String?
    let dateDebut: String
    let dateFin: String
    let partenaireId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case titre
        case description
        case type
        case pourcentageReduction
        case imageUrl
        case dateDebut
        case dateFin
        case partenaireId
    }
    
    // MARK: - Dates calculées
    var dateDebutDate: Date? {
        parseDate(from: dateDebut)
    }
    
    var dateFinDate: Date? {
        parseDate(from: dateFin)
    }
    
    private func parseDate(from value: String) -> Date? {
        // ISO standard
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: value) {
            return date
        }
        
        // Format complet avec millisecondes
        let fullFormatter = DateFormatter()
        fullFormatter.locale = Locale(identifier: "en_US_POSIX")
        fullFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = fullFormatter.date(from: value) {
            return date
        }
        
        // Format simple (date seule)
        let simpleFormatter = DateFormatter()
        simpleFormatter.locale = Locale(identifier: "en_US_POSIX")
        simpleFormatter.dateFormat = "yyyy-MM-dd"
        return simpleFormatter.date(from: value)
    }
    
    var isActive: Bool {
        guard let debut = dateDebutDate, let fin = dateFinDate else { return false }
        let now = Date()
        return now >= debut && now <= fin
    }
    
    var discountText: String {
        if let pourcentage = pourcentageReduction {
            return "-\(Int(pourcentage))%"
        }
        return type
    }
}

// MARK: - Create/Update DTO
struct PubliciteDTO: Codable {
    let titre: String
    let description: String
    let type: String
    let pourcentageReduction: Double?
    let imageUrl: String?
    let dateDebut: String
    let dateFin: String
    let partenaireId: String?
}

// MARK: - Response Wrapper (liste)
struct PubliciteListResponse: Codable {
    let data: [Publicite]?
    let message: String?
}

// MARK: - Response Wrapper (objet)
struct SinglePubliciteResponse: Codable {
    let data: Publicite?
    let message: String?
}
