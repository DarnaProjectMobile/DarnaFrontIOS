//
//  Publicite.swift
//  DarnaApp
//

import Foundation

// MARK: - PubliciteType Enum (correspond au backend)
enum PubliciteType: String, Codable {
    case reduction = "reduction"
    case promotion = "promotion"
    case jeu = "jeu"
    
    var displayName: String {
        switch self {
        case .reduction: return "Réduction"
        case .promotion: return "Promotion"
        case .jeu: return "Jeu"
        }
    }
    
    var uppercase: String {
        switch self {
        case .reduction: return "REDUCTION"
        case .promotion: return "PROMOTION"
        case .jeu: return "JEU"
        }
    }
    
    init?(from string: String) {
        let lowercased = string.lowercased()
        switch lowercased {
        case "reduction", "réduction":
            self = .reduction
        case "promotion", "promo":
            self = .promotion
        case "jeu", "game":
            self = .jeu
        default:
            // Par défaut, mapper vers PROMOTION si le type n'est pas reconnu
            self = .promotion
        }
    }
}

// MARK: - Publicite Model (correspond au backend NestJS)
struct Publicite: Identifiable, Codable, Equatable {
    let id: String           // _id du backend
    let titre: String
    let description: String
    let type: String
    let image: String?       // Le backend utilise "image"
    let imageUrl: String?    // Mappé depuis "image" dans le transform
    let details: String?     // Détails optionnels
    let qrCode: String?      // QR code optionnel
    let sponsorId: String?   // ID du sponsor (transformé depuis sponsor._id)
    let sponsorName: String? // Nom du sponsor (transformé depuis sponsor.username)
    let sponsorLogo: String?  // Logo du sponsor (transformé depuis sponsor.image)
    let createdAt: String?   // Date de création (timestamps)
    let updatedAt: String?   // Date de mise à jour (timestamps)
    
    // Champs optionnels pour compatibilité
    let pourcentageReduction: Double?
    let dateDebut: String?
    let dateFin: String?
    let dateExpiration: String?
    let partenaireId: String?
    let categorie: String?
    
    // Champs optionnels selon le type
    let detailReduction: DetailReduction?
    let detailPromotion: DetailPromotion?
    let detailJeu: DetailJeu?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case titre
        case description
        case type
        case image
        case imageUrl
        case details
        case qrCode
        case sponsorId
        case sponsorName
        case sponsorLogo
        case createdAt
        case updatedAt
        // Champs optionnels pour compatibilité
        case pourcentageReduction
        case dateDebut
        case dateFin
        case dateExpiration
        case partenaireId
        case categorie
        case detailReduction
        case detailPromotion
        case detailJeu
    }
    
    // Initializer public pour créer des instances manuellement
    init(
        id: String,
        titre: String,
        description: String,
        type: String,
        image: String? = nil,
        imageUrl: String? = nil,
        details: String? = nil,
        qrCode: String? = nil,
        sponsorId: String? = nil,
        sponsorName: String? = nil,
        sponsorLogo: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        pourcentageReduction: Double? = nil,
        dateDebut: String? = nil,
        dateFin: String? = nil,
        dateExpiration: String? = nil,
        partenaireId: String? = nil,
        categorie: String? = nil,
        detailReduction: DetailReduction? = nil,
        detailPromotion: DetailPromotion? = nil,
        detailJeu: DetailJeu? = nil
    ) {
        self.id = id
        self.titre = titre
        self.description = description
        self.type = type
        self.image = image
        self.imageUrl = imageUrl ?? image
        self.details = details
        self.qrCode = qrCode
        self.sponsorId = sponsorId
        self.sponsorName = sponsorName
        self.sponsorLogo = sponsorLogo
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.pourcentageReduction = pourcentageReduction
        self.dateDebut = dateDebut
        self.dateFin = dateFin
        self.dateExpiration = dateExpiration
        self.partenaireId = partenaireId
        self.categorie = categorie
        self.detailReduction = detailReduction
        self.detailPromotion = detailPromotion
        self.detailJeu = detailJeu
    }
    
    // Initializer personnalisé pour mapper image vers imageUrl si nécessaire
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        titre = try container.decode(String.self, forKey: .titre)
        description = try container.decode(String.self, forKey: .description)
        type = try container.decode(String.self, forKey: .type)
        
        // Mapper image vers imageUrl si imageUrl n'existe pas
        image = try container.decodeIfPresent(String.self, forKey: .image)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl) ?? image
        
        details = try container.decodeIfPresent(String.self, forKey: .details)
        qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
        sponsorId = try container.decodeIfPresent(String.self, forKey: .sponsorId)
        sponsorName = try container.decodeIfPresent(String.self, forKey: .sponsorName)
        sponsorLogo = try container.decodeIfPresent(String.self, forKey: .sponsorLogo)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        
        // Champs optionnels pour compatibilité
        pourcentageReduction = try container.decodeIfPresent(Double.self, forKey: .pourcentageReduction)
        dateDebut = try container.decodeIfPresent(String.self, forKey: .dateDebut)
        dateFin = try container.decodeIfPresent(String.self, forKey: .dateFin)
        dateExpiration = try container.decodeIfPresent(String.self, forKey: .dateExpiration)
        partenaireId = try container.decodeIfPresent(String.self, forKey: .partenaireId)
        categorie = try container.decodeIfPresent(String.self, forKey: .categorie)
        detailReduction = try container.decodeIfPresent(DetailReduction.self, forKey: .detailReduction)
        detailPromotion = try container.decodeIfPresent(DetailPromotion.self, forKey: .detailPromotion)
        detailJeu = try container.decodeIfPresent(DetailJeu.self, forKey: .detailJeu)
    }
    
    // MARK: - Encodable Conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(titre, forKey: .titre)
        try container.encode(description, forKey: .description)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(details, forKey: .details)
        try container.encodeIfPresent(qrCode, forKey: .qrCode)
        try container.encodeIfPresent(sponsorId, forKey: .sponsorId)
        try container.encodeIfPresent(sponsorName, forKey: .sponsorName)
        try container.encodeIfPresent(sponsorLogo, forKey: .sponsorLogo)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(pourcentageReduction, forKey: .pourcentageReduction)
        try container.encodeIfPresent(dateDebut, forKey: .dateDebut)
        try container.encodeIfPresent(dateFin, forKey: .dateFin)
        try container.encodeIfPresent(dateExpiration, forKey: .dateExpiration)
        try container.encodeIfPresent(partenaireId, forKey: .partenaireId)
        try container.encodeIfPresent(categorie, forKey: .categorie)
        try container.encodeIfPresent(detailReduction, forKey: .detailReduction)
        try container.encodeIfPresent(detailPromotion, forKey: .detailPromotion)
        try container.encodeIfPresent(detailJeu, forKey: .detailJeu)
    }
    
    // MARK: - Dates calculées
    var dateDebutDate: Date? {
        guard let dateDebut = dateDebut else { return nil }
        return parseDate(from: dateDebut)
    }
    
    var dateFinDate: Date? {
        guard let dateFin = dateFin else { return nil }
        return parseDate(from: dateFin)
    }
    
    var createdAtDate: Date? {
        guard let createdAt = createdAt else { return nil }
        return parseDate(from: createdAt)
    }
    
    var updatedAtDate: Date? {
        guard let updatedAt = updatedAt else { return nil }
        return parseDate(from: updatedAt)
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
    
    // MARK: - Computed Properties
    var publiciteType: PubliciteType? {
        PubliciteType(from: type)
    }
    
    var dateExpirationDate: Date? {
        guard let dateExpiration = dateExpiration else { return nil }
        return parseDate(from: dateExpiration)
    }
    
    var isActive: Bool {
        // Si pas de date d'expiration, vérifier dateDebut/dateFin
        if let expiration = dateExpirationDate {
            return Date() <= expiration
        }
        guard let debut = dateDebutDate, let fin = dateFinDate else { return true }
        let now = Date()
        return now >= debut && now <= fin
    }
    
    var discountText: String {
        if let reduction = detailReduction, let pourcentage = reduction.pourcentage {
            return "-\(Int(pourcentage))%"
        }
        if let pourcentage = pourcentageReduction {
            return "-\(Int(pourcentage))%"
        }
        return publiciteType?.displayName ?? type
    }
}

// MARK: - Detail Structures
struct DetailReduction: Codable, Equatable {
    let pourcentage: Double?
    let conditionsUtilisation: String?
}

struct DetailPromotion: Codable, Equatable {
    let offre: String?
    let conditions: String?
}

struct DetailJeu: Codable, Equatable {
    let description: String?
    let gains: [String]?
    let reductions: [ReductionJeu]? // Réductions disponibles dans le jeu
    let nombreCases: Int?
    let probabilites: [Double]?
}

struct ReductionJeu: Codable, Equatable, Identifiable {
    let id: String
    let pourcentage: Double
    let conditions: String?
    let qrCode: String? // QR code généré pour cette réduction
    
    init(id: String = UUID().uuidString, pourcentage: Double, conditions: String? = nil, qrCode: String? = nil) {
        self.id = id
        self.pourcentage = pourcentage
        self.conditions = conditions
        self.qrCode = qrCode
    }
}

struct RecompenseJeu: Identifiable, Codable {
    var id = UUID()
    var text: String
    var pourcentage: Double
    var probabilite: Double
    
    enum CodingKeys: String, CodingKey {
        case text, pourcentage, probabilite
    }
}

// MARK: - Create/Update DTO (correspond au CreatePubliciteDto du backend)
struct PubliciteDTO: Codable {
    let titre: String
    let description: String
    let image: String        // Le backend attend "image", pas "imageUrl"
    let type: String         // reduction, promotion, jeu (en minuscules)
    let details: String?     // Optionnel
    let categorie: String?   // Catégorie de l'annonce
    
    enum CodingKeys: String, CodingKey {
        case titre
        case description
        case image
        case type
        case details
        case categorie
    }
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
