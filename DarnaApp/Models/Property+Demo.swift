//
//  Property+Demo.swift
//  DarnaApp
//
//  Extension pour créer des propriétés de démonstration

import Foundation

extension Property {
    /// Initialiseur pour créer des propriétés de démonstration
    init(
        id: String,
        title: String,
        description: String,
        price: Double,
        images: [String],
        type: String,
        location: String,
        nbrCollocateurMax: Int,
        nbrCollocateurActuel: Int,
        startDate: Date,
        endDate: Date
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.images = images
        self.type = type
        self.location = location
        self.nbrCollocateurMax = nbrCollocateurMax
        self.nbrCollocateurActuel = nbrCollocateurActuel
        self.startDate = startDate
        self.endDate = endDate
        self.user = nil
        self.ownerName = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
