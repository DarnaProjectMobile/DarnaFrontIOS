//
//  Review.swift
//  DarnaApp
//
//  Created by Apple Esprit on 7/11/2025.
//

import Foundation

/// Represents a user review for a property or colocation.
struct Review: Identifiable, Codable, Equatable {
    let id: UUID
    var userId: String         // ID of the user who posted the review
    var propertyId: String     // ID of the property being reviewed
    var propertyName: String   // Display name of the property
    var rating: Int            // 1–5 stars
    var comment: String
    var date: Date
    
    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        userId: String,
        propertyId: String,
        propertyName: String,
        rating: Int,
        comment: String,
        date: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.propertyId = propertyId
        self.propertyName = propertyName
        self.rating = rating
        self.comment = comment
        self.date = date
    }
}

// MARK: - Sample Data for Previews or Testing
extension Review {
    static let sampleData: [Review] = [
        Review(
            userId: "user_001",
            propertyId: "prop_001",
            propertyName: "Colocation Paris 11",
            rating: 5,
            comment: "Super logement, très calme et bien situé !",
            date: Date()
        ),
        Review(
            userId: "user_001",
            propertyId: "prop_002",
            propertyName: "Studio Lyon",
            rating: 4,
            comment: "Jolie déco, bon rapport qualité prix.",
            date: Date().addingTimeInterval(-86400 * 3)
        ),
        Review(
            userId: "user_001",
            propertyId: "prop_003",
            propertyName: "Appartement Nice",
            rating: 3,
            comment: "Pas mal, mais voisinage un peu bruyant.",
            date: Date().addingTimeInterval(-86400 * 10)
        )
    ]
}
