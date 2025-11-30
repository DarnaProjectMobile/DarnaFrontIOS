//
//  ReviewService.swift
//  DarnaApp
//
//  Created by Qoder Assistant on 30/11/2025.
//

import Foundation

enum ReviewError: Error, LocalizedError {
    case invalidURL
    case noAuthToken
    case encodingError
    case decodingError
    case serverError(String)
    case invalidResponse
    case unauthorized
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "L'URL du serveur est invalide."
        case .noAuthToken:
            return "Vous devez être connecté pour effectuer cette action."
        case .encodingError:
            return "Erreur lors de la préparation des données."
        case .decodingError:
            return "Erreur de décodage des données."
        case .serverError(let message):
            return message
        case .invalidResponse:
            return "Réponse du serveur invalide."
        case .unauthorized:
            return "Vous n'êtes pas autorisé à effectuer cette action."
        case .notFound:
            return "Élément non trouvé."
        }
    }
}

struct CreateReviewRequest: Codable {
    let propertyId: String
    let rating: Int
    let comment: String
}

struct UpdateReviewRequest: Codable {
    let rating: Int
    let comment: String
}

final class ReviewService {
    static let shared = ReviewService()
    
    private let baseURL = "http://10.42.113.107:3000/reviews"
    
    private init() {}
    
    /// Fetch all reviews for a specific property
    /// - Parameter propertyId: The ID of the property
    /// - Returns: Array of reviews
    func fetchReviews(for propertyId: String) async throws -> [Review] {
        guard let url = URL(string: "\(baseURL)?property=\(propertyId)") else {
            throw ReviewError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if available
        if let token = await AuthenticationManager.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReviewError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let reviews = try JSONDecoder().decode([Review].self, from: data)
                return reviews
            } catch {
                throw ReviewError.decodingError
            }
        case 401:
            throw ReviewError.unauthorized
        default:
            throw ReviewError.serverError("Erreur lors de la récupération des avis.")
        }
    }
    
    /// Fetch reviews by current user for a specific property
    /// - Parameter propertyId: The ID of the property
    /// - Returns: Array of reviews by current user for the property
    func fetchUserReviews(for propertyId: String) async throws -> [Review] {
        guard let userId = await AuthenticationManager.shared.currentUser?.id else {
            throw ReviewError.noAuthToken
        }
        
        guard let url = URL(string: "\(baseURL)?property=\(propertyId)&user=\(userId)") else {
            throw ReviewError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        guard let token = await AuthenticationManager.shared.authToken else {
            throw ReviewError.noAuthToken
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReviewError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let reviews = try JSONDecoder().decode([Review].self, from: data)
                return reviews
            } catch {
                throw ReviewError.decodingError
            }
        case 401:
            throw ReviewError.unauthorized
        default:
            throw ReviewError.serverError("Erreur lors de la récupération des avis.")
        }
    }
    
    /// Create a new review
    /// - Parameters:
    ///   - propertyId: The ID of the property being reviewed
    ///   - rating: Rating from 1-5 stars
    ///   - comment: Review comment
    /// - Returns: The created review
    func createReview(propertyId: String, rating: Int, comment: String) async throws -> Review {
        guard let url = URL(string: baseURL) else {
            throw ReviewError.invalidURL
        }
        
        guard let token = await AuthenticationManager.shared.authToken else {
            throw ReviewError.noAuthToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let reviewRequest = CreateReviewRequest(propertyId: propertyId, rating: rating, comment: comment)
        request.httpBody = try JSONEncoder().encode(reviewRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReviewError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 201:
            do {
                let review = try JSONDecoder().decode(Review.self, from: data)
                return review
            } catch {
                throw ReviewError.decodingError
            }
        case 400:
            throw ReviewError.serverError("Données invalides.")
        case 401:
            throw ReviewError.unauthorized
        case 409:
            throw ReviewError.serverError("Vous avez déjà publié un avis pour ce logement.")
        default:
            throw ReviewError.serverError("Erreur lors de la publication de l'avis.")
        }
    }
    
    /// Update an existing review
    /// - Parameters:
    ///   - reviewId: The ID of the review to update
    ///   - rating: New rating from 1-5 stars
    ///   - comment: New review comment
    /// - Returns: The updated review
    func updateReview(reviewId: String, rating: Int, comment: String) async throws -> Review {
        guard let url = URL(string: "\(baseURL)/\(reviewId)") else {
            throw ReviewError.invalidURL
        }
        
        guard let token = await AuthenticationManager.shared.authToken else {
            throw ReviewError.noAuthToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let updateRequest = UpdateReviewRequest(rating: rating, comment: comment)
        request.httpBody = try JSONEncoder().encode(updateRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReviewError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let review = try JSONDecoder().decode(Review.self, from: data)
                return review
            } catch {
                throw ReviewError.decodingError
            }
        case 400:
            throw ReviewError.serverError("Données invalides.")
        case 401:
            throw ReviewError.unauthorized
        case 403:
            throw ReviewError.unauthorized
        case 404:
            throw ReviewError.notFound
        default:
            throw ReviewError.serverError("Erreur lors de la mise à jour de l'avis.")
        }
    }
    
    /// Delete a review
    /// - Parameter reviewId: The ID of the review to delete
    func deleteReview(reviewId: String) async throws {
        guard let url = URL(string: "\(baseURL)/\(reviewId)") else {
            throw ReviewError.invalidURL
        }
        
        guard let token = await AuthenticationManager.shared.authToken else {
            throw ReviewError.noAuthToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReviewError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200, 204:
            // Success
            return
        case 401:
            throw ReviewError.unauthorized
        case 403:
            throw ReviewError.unauthorized
        case 404:
            throw ReviewError.notFound
        default:
            throw ReviewError.serverError("Erreur lors de la suppression de l'avis.")
        }
    }
}