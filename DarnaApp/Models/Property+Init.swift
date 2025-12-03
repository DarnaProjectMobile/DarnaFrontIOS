//
//  Property+Init.swift
//  DarnaApp
//
//  Extension to add memberwise initializer for Property
//  Needed because the custom init(from: Decoder) removes the default memberwise initializer

import Foundation

extension Property {
    init(
        id: String,
        title: String,
        description: String?,
        price: Double,
        user: String? = nil,
        ownerName: String? = nil,
        images: [String]? = nil,
        type: String? = nil,
        location: String? = nil,
        nbrCollocateurMax: Int? = nil,
        nbrCollocateurActuel: Int? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.user = user
        self.ownerName = ownerName
        self.images = images
        self.type = type
        self.location = location
        self.nbrCollocateurMax = nbrCollocateurMax
        self.nbrCollocateurActuel = nbrCollocateurActuel
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
