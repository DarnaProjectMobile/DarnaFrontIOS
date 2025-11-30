//
//  Feedback.swift
//  DarnaApp
//
//  Created by Qoder Assistant on 30/11/2025.
//

import Foundation

// MARK: - Feedback Model
struct Feedback: Codable {
    let reason: String
    let details: String
}

// MARK: - Create Feedback Request
struct CreateFeedbackRequest: Codable {
    let reason: String
    let details: String
}