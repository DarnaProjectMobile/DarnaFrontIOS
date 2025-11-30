//
//  Feedback.swift
//  DarnaApp
//
//  Created by Qoder Assistant on 30/11/2025.
//

import Foundation

// MARK: - Feedback Model
struct Feedback: Codable, Identifiable {
    let id: String
    let reason: String
    let details: String
    let user: String
    
    // Optional fields that may not exist in all backend versions
    let isResolved: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case reason
        case details
        case user
        case isResolved
        case createdAt
        case updatedAt
    }
    
    // Handle missing fields gracefully
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        reason = try container.decode(String.self, forKey: .reason)
        details = try container.decode(String.self, forKey: .details)
        user = try container.decode(String.self, forKey: .user)
        isResolved = try container.decodeIfPresent(Bool.self, forKey: .isResolved) ?? false
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}

// MARK: - Create Feedback Request
struct CreateFeedbackRequest: Codable {
    let reason: String
    let details: String
}

// MARK: - Feedback Response
struct FeedbackResponse: Codable {
    let feedback: Feedback
}