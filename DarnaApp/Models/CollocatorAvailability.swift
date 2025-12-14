//
//  CollocatorAvailability.swift
//  DarnaApp
//
//  Model for collocator's personal availability schedule

import Foundation

// MARK: - Collocator Availability

struct CollocatorAvailability: Codable, Identifiable {
    let id: String
    let userId: String
    let availableDays: [Int]? // 0 = Sunday, 1 = Monday, etc.
    let availableTimeSlots: [TimeSlot]?
    let unavailableDates: [String]? // ISO date strings for specific blocked dates
    let availableDates: [String]? // ISO date strings for specific available dates
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case availableDays
        case availableTimeSlots
        case unavailableDates
        case availableDates
    }
}

struct TimeSlot: Codable {
    let startTime: String // "09:00"
    let endTime: String   // "17:00"
}

// MARK: - Availability Response

struct AvailabilityResponse: Codable {
    let available: Bool
    let availableDates: [String]?
    let unavailableDates: [String]?
    let message: String?
}
