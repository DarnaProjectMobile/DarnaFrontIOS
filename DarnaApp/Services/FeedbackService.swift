//
//  FeedbackService.swift
//  DarnaApp
//
//  Created by Qoder Assistant on 30/11/2025.
//

import Foundation

enum FeedbackError: Error, LocalizedError {
    case invalidURL
    case noAuthToken
    case encodingError
    case serverError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "L'URL du serveur est invalide."
        case .noAuthToken:
            return "Vous devez être connecté pour envoyer un feedback."
        case .encodingError:
            return "Erreur lors de la préparation des données."
        case .serverError(let message):
            return message
        case .invalidResponse:
            return "Réponse du serveur invalide."
        }
    }
}

final class FeedbackService {
    static let shared = FeedbackService()
    
    private let baseURL = "http://10.42.113.107:3000/reports"
    
    private init() {}
    
    /// Send feedback to the NestJS backend
    /// - Parameters:
    ///   - reason: The reason for the feedback
    ///   - details: Detailed description of the feedback
    /// - Returns: The created Feedback object
    /// - Throws: FeedbackError if the request fails
    func sendFeedback(reason: String, details: String) async throws -> Feedback {
        guard let url = URL(string: baseURL) else {
            throw FeedbackError.invalidURL
        }
        
        // Get auth token from AuthenticationManager
        guard let token = await AuthenticationManager.shared.authToken else {
            throw FeedbackError.noAuthToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let feedback = CreateFeedbackRequest(reason: reason, details: details)
        request.httpBody = try JSONEncoder().encode(feedback)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FeedbackError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200, 201:
            // Parse and return the created feedback
            let feedbackResponse = try JSONDecoder().decode(Feedback.self, from: data)
            print("✅ Feedback envoyé avec succès")
            return feedbackResponse
        case 400, 401:
            throw FeedbackError.serverError("Erreur d'authentification. Veuillez vous reconnecter.")
        case 500:
            throw FeedbackError.serverError("Erreur serveur. Veuillez réessayer plus tard.")
        default:
            // Try to parse error message from response
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw FeedbackError.serverError(errorResponse.message)
            } else {
                throw FeedbackError.serverError("Erreur inconnue lors de l'envoi du feedback.")
            }
        }
    }
    
    /// Fetch all feedbacks for the current user
    /// - Returns: Array of Feedback objects
    /// - Throws: FeedbackError if the request fails
    func fetchUserFeedbacks() async throws -> [Feedback] {
        guard let url = URL(string: "\(baseURL)/my") else {
            throw FeedbackError.invalidURL
        }
        
        // Get auth token from AuthenticationManager
        guard let token = await AuthenticationManager.shared.authToken else {
            throw FeedbackError.noAuthToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FeedbackError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            let feedbacks = try JSONDecoder().decode([Feedback].self, from: data)
            return feedbacks
        case 400, 401:
            throw FeedbackError.serverError("Erreur d'authentification. Veuillez vous reconnecter.")
        case 500:
            throw FeedbackError.serverError("Erreur serveur. Veuillez réessayer plus tard.")
        default:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw FeedbackError.serverError(errorResponse.message)
            } else {
                throw FeedbackError.serverError("Erreur lors de la récupération des feedbacks.")
            }
        }
    }
}