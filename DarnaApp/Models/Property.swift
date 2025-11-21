//
//  Property.swift
//  DarnaApp
//

import Foundation

struct Property: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String?
    let price: Double
    let user: String?
    let ownerName: String?
    let images: [String]?
    let type: String?
    let location: String?
    let nbrCollocateurMax: Int?
    let nbrCollocateurActuel: Int?
    let startDate: Date?
    let endDate: Date?
    let createdAt: Date?
    let updatedAt: Date?

    // Optional local fields
    var tags: [String] = []
    var calmLevel: String = ""
    var calmLevelDescription: String = ""
    var lifestyle: String = ""
    var lifestyleDescription: String = ""
    var homeEnergy: String = ""
    var homeEnergyDescription: String = ""
    var availability: String = ""
    var flatmatesCount: Int {
        nbrCollocateurActuel ?? 0
    }
    
    // Computed property for backward compatibility with image (single)
    var image: String? {
        images?.first
    }
    var has360Tour: Bool = false

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, price, user, images, type, location, nbrCollocateurMax, nbrCollocateurActuel, startDate, endDate, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        price = try container.decode(Double.self, forKey: .price)

        if let userString = try? container.decode(String.self, forKey: .user) {
            user = userString
            ownerName = nil
        } else if let embeddedUser = try? container.decode(EmbeddedUser.self, forKey: .user) {
            user = embeddedUser.resolvedId
            ownerName = embeddedUser.resolvedName
        } else {
            user = nil
            ownerName = nil
        }

        // Handle images: decode as array (backend returns array)
        images = try container.decodeIfPresent([String].self, forKey: .images)
        
        type = try container.decodeIfPresent(String.self, forKey: .type)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        nbrCollocateurMax = try container.decodeIfPresent(Int.self, forKey: .nbrCollocateurMax)
        nbrCollocateurActuel = try container.decodeIfPresent(Int.self, forKey: .nbrCollocateurActuel)

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let startString = try container.decodeIfPresent(String.self, forKey: .startDate) {
            startDate = isoFormatter.date(from: startString)
        } else {
            startDate = nil
        }
        if let endString = try container.decodeIfPresent(String.self, forKey: .endDate) {
            endDate = isoFormatter.date(from: endString)
        } else {
            endDate = nil
        }

        if let createdString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = isoFormatter.date(from: createdString)
        } else {
            createdAt = nil
        }
        if let updatedString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = isoFormatter.date(from: updatedString)
        } else {
            updatedAt = nil
        }
    }
}

private struct EmbeddedUser: Codable {
    let id: String?
    let mongoId: String?
    let username: String?
    let name: String?
    let fullName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case mongoId = "_id"
        case username
        case name
        case fullName
    }
    
    var resolvedId: String? {
        mongoId ?? id
    }
    
    var resolvedName: String? {
        username ?? name ?? fullName
    }
}

extension Property {
    static func == (lhs: Property, rhs: Property) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
