//
//  PubliciteService.swift
//  DarnaApp
//

import Foundation

protocol PubliciteServiceProtocol {
    func fetchPublicites() async throws -> [Publicite]
    func createPublicite(_ publicite: PubliciteDTO) async throws -> Publicite
    func updatePublicite(id: String, publicite: PubliciteDTO) async throws -> Publicite
    func deletePublicite(id: String) async throws
}

final class PubliciteService: PubliciteServiceProtocol {
    static let shared = PubliciteService()
    
    private let session: URLSession
    private let baseURL: String
    
    init(
        session: URLSession = .shared,
        baseURL: String = "\(APIConfig.baseURL)/publicite"
    ) {
        self.session = session
        self.baseURL = baseURL
    }
    
    // MARK: - Request builder
    private func request(
        endpoint: String = "",
        method: String,
        body: Data? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw PubliciteAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = AuthManager.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        return request
    }
    
    // MARK: - Public APIs
    func fetchPublicites() async throws -> [Publicite] {
        let request = try request(method: "GET")
        let (data, response) = try await session.data(for: request)
        try PubliciteAPIError.validate(response: response, data: data)
        return try decodePublicites(from: data)
    }
    
    func createPublicite(_ publicite: PubliciteDTO) async throws -> Publicite {
        let body = try JSONEncoder().encode(publicite)
        let request = try request(method: "POST", body: body)
        let (data, response) = try await session.data(for: request)
        try PubliciteAPIError.validate(response: response, data: data)
        return try decodePublicite(from: data)
    }
    
    func updatePublicite(id: String, publicite: PubliciteDTO) async throws -> Publicite {
        let body = try JSONEncoder().encode(publicite)
        let request = try request(endpoint: "/\(id)", method: "PATCH", body: body)
        let (data, response) = try await session.data(for: request)
        try PubliciteAPIError.validate(response: response, data: data)
        return try decodePublicite(from: data)
    }
    
    func deletePublicite(id: String) async throws {
        let request = try request(endpoint: "/\(id)", method: "DELETE")
        let (_, response) = try await session.data(for: request)
        try PubliciteAPIError.validate(response: response, data: nil)
    }
    
    // MARK: - Decoding helpers
    private func decodePublicites(from data: Data) throws -> [Publicite] {
        do {
            return try JSONDecoder().decode([Publicite].self, from: data)
        } catch {
            let wrapper = try JSONDecoder().decode(PubliciteListResponse.self, from: data)
            if let publicites = wrapper.data { return publicites }
            throw PubliciteAPIError.decoding(error)
        }
    }
    
    private func decodePublicite(from data: Data) throws -> Publicite {
        do {
            return try JSONDecoder().decode(Publicite.self, from: data)
        } catch {
            let wrapper = try JSONDecoder().decode(SinglePubliciteResponse.self, from: data)
            if let publicite = wrapper.data { return publicite }
            throw PubliciteAPIError.decoding(error)
        }
    }
}

// MARK: - Error handling
enum PubliciteAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case http(statusCode: Int, message: String?)
    case decoding(Error)
    case unauthorized
    
    static func validate(response: URLResponse?, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PubliciteAPIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw PubliciteAPIError.unauthorized
        default:
            let message = data.flatMap { String(data: $0, encoding: .utf8) }
            throw PubliciteAPIError.http(statusCode: httpResponse.statusCode, message: message)
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalide pour l’API Publicité."
        case .invalidResponse:
            return "Réponse inattendue du serveur."
        case .http(let status, let message):
            return "Erreur serveur (\(status)). \(message ?? "")"
        case .decoding(let error):
            return "Erreur de décodage: \(error.localizedDescription)"
        case .unauthorized:
            return "Session expirée. Veuillez vous reconnecter."
        }
    }
}



