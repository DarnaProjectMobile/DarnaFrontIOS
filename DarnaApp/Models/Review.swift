//
//  Review.swift
//  DarnaApp
//
//  Created by Apple Esprit on 7/11/2025.
//

import Foundation

/// Represents a user review for a property or colocation.
struct Review: Identifiable, Codable, Equatable {
    let id: String
    var userId: String         // ID of the user who posted the review
    var propertyId: String     // ID of the property being reviewed
    var propertyName: String   // Display name of the property
    var rating: Int            // 1–5 stars
    var comment: String
    var date: Date
    var userName: String       // Name of the user who posted the review
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case propertyId
        case propertyName
        case rating
        case comment
        case date
        case userName
    }
    
    // MARK: - Initializer
    init(
        id: String,
        userId: String,
        propertyId: String,
        propertyName: String,
        rating: Int,
        comment: String,
        date: Date = Date(),
        userName: String = ""
    ) {
        self.id = id
        self.userId = userId
        self.propertyId = propertyId
        self.propertyName = propertyName
        self.rating = rating
        self.comment = comment
        self.date = date
        self.userName = userName
    }
}

// MARK: - Sample Data for Previews or Testing
extension Review {
    static let sampleData: [Review] = [
        Review(
            id: "review_001",
            userId: "user_001",
            propertyId: "prop_001",
            propertyName: "Colocation Paris 11",
            rating: 5,
            comment: "Super logement, très calme et bien situé !",
            date: Date(),
            userName: "Amine B."
        ),
        Review(
            id: "review_002",
            userId: "user_002",
            propertyId: "prop_001",
            propertyName: "Colocation Paris 11",
            rating: 4,
            comment: "Jolie déco, bon rapport qualité prix.",
            date: Date().addingTimeInterval(-86400 * 3),
            userName: "Sara K."
        ),
        Review(
            id: "review_003",
            userId: "user_003",
            propertyId: "prop_001",
            propertyName: "Colocation Paris 11",
            rating: 3,
            comment: "Pas mal, mais voisinage un peu bruyant.",
            date: Date().addingTimeInterval(-86400 * 10),
            userName: "Omar L."
        )
    ]
}
