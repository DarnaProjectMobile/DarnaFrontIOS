//
//  UserModel.swift
//  DarnaApp
//
//  Created by Apple Esprit on 8/11/2025.
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let password: String?

    let role: String?
    let dateNaissance: String?
    let gender: String?
    let image: String?
    let resetCode: String?
    let credits: Int?
    let ratingAvg: Double?
    let badges: [String]?
    let verificationCode: String?
    let isVerified: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username
        case email
        case password
        case role
        case dateNaissance
        case gender
        case image
        case resetCode
        case credits
        case ratingAvg
        case badges
        case verificationCode
        case isVerified
    }
}

// MARK: - Login Response
struct SignInResponse: Codable {
    let user: User
    let token: String

    enum CodingKeys: String, CodingKey {
        case user
        case token = "access_token"
    }
}


// MARK: - Register Response
struct RegisterResponse: Codable {
    let user: User
}

// MARK: - Error Response
struct ErrorResponse: Codable {
    let message: String
}
