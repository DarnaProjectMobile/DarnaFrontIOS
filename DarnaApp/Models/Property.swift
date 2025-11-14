//
//  Property.swift
//  DarnaApp
//

import Foundation

struct Property: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let price: Double
    let user: String?
    let image: String?
    let type: String?
    let location: String?
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
    var flatmatesCount: Int = 0
    var has360Tour: Bool = false

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, price, user, image, type, location, startDate, endDate, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        price = try container.decode(Double.self, forKey: .price)

        if let userString = try? container.decode(String.self, forKey: .user) {
            user = userString
        } else if let userDict = try? container.decode([String: String].self, forKey: .user) {
            user = userDict["_id"] ?? userDict["id"]
        } else {
            user = nil
        }

        image = try container.decodeIfPresent(String.self, forKey: .image)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        location = try container.decodeIfPresent(String.self, forKey: .location)

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
