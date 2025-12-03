//
//  VisitAPIService.swift
//  DarnaApp
//
//

import Foundation

protocol VisitAPIServiceProtocol {
    func fetchMyVisits() async throws -> [Visit]
    func fetchCollocatorVisits() async throws -> [Visit]
    func createVisit(_ payload: VisitCreationPayload) async throws -> Visit
    func updateVisit(id: String, payload: VisitUpdatePayload) async throws -> Visit
    func deleteVisit(id: String) async throws
    func cancelVisit(id: String) async throws -> Visit
    func acceptVisit(id: String) async throws -> Visit
    func rejectVisit(id: String) async throws -> Visit
    func validateVisit(id: String) async throws -> Visit
    func submitReview(id: String, payload: VisitReviewPayload) async throws -> VisitReview
    func fetchReviews(for id: String) async throws -> [VisitReview]
    func fetchReceivedReviews() async throws -> [VisitReview]
}

final class VisitAPIService: VisitAPIServiceProtocol {
    static let shared = VisitAPIService()
    
    private let baseURL = ServerConfig.baseURL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        decoder = JSONDecoder()
        encoder = JSONEncoder()
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Public API
    
    func fetchMyVisits() async throws -> [Visit] {
        try await get(endpoint: "/visite/my-visites")
    }
    
    func fetchCollocatorVisits() async throws -> [Visit] {
        try await get(endpoint: "/visite/my-logements-visites")
    }
    
    func createVisit(_ payload: VisitCreationPayload) async throws -> Visit {
        try await post(endpoint: "/visite", body: payload)
    }
    
    func updateVisit(id: String, payload: VisitUpdatePayload) async throws -> Visit {
        try await patch(endpoint: "/visite/\(id)", body: payload)
    }
    
    func deleteVisit(id: String) async throws {
        let _: EmptyPayload = try await request(
            endpoint: "/visite/\(id)",
            method: "DELETE",
            body: nil as EmptyPayload?
        )
    }
    
    func cancelVisit(id: String) async throws -> Visit {
        try await post(endpoint: "/visite/\(id)/cancel", body: EmptyPayload())
    }
    
    func acceptVisit(id: String) async throws -> Visit {
        try await post(endpoint: "/visite/\(id)/accept", body: EmptyPayload())
    }
    
    func rejectVisit(id: String) async throws -> Visit {
        try await post(endpoint: "/visite/\(id)/reject", body: EmptyPayload())
    }
    
    func validateVisit(id: String) async throws -> Visit {
        try await post(endpoint: "/visite/\(id)/validate", body: EmptyPayload())
    }
    
    func submitReview(id: String, payload: VisitReviewPayload) async throws -> VisitReview {
        try await post(endpoint: "/visite/\(id)/review", body: payload)
    }
    
    func fetchReviews(for id: String) async throws -> [VisitReview] {
        print("🔍 API: Fetching reviews for visit ID: \(id)")
        print("🔍 API: Endpoint: \(baseURL)/visite/\(id)/reviews")
        let reviews: [VisitReview] = try await get(endpoint: "/visite/\(id)/reviews")
        print("✅ API: Received \(reviews.count) reviews for visit \(id)")
        return reviews
    }
    
    func fetchReceivedReviews() async throws -> [VisitReview] {
        print("🔍 API: Fetching ALL received reviews for collocator")
        print("🔍 API: Endpoint: \(baseURL)/reviews/me/feedbacks")
        let reviews: [VisitReview] = try await get(endpoint: "/reviews/me/feedbacks")
        print("✅ API: Received \(reviews.count) total reviews")
        return reviews
    }
    
    // MARK: - Request Builders
    
    private func get<T: Decodable>(endpoint: String) async throws -> T {
        try await request(endpoint: endpoint, method: "GET", body: nil as EmptyPayload?)
    }
    
    private func post<T: Decodable, Body: Encodable>(endpoint: String, body: Body) async throws -> T {
        try await request(endpoint: endpoint, method: "POST", body: body)
    }
    
    private func patch<T: Decodable, Body: Encodable>(endpoint: String, body: Body) async throws -> T {
        try await request(endpoint: endpoint, method: "PATCH", body: body)
    }
    
    private func request<T: Decodable, Body: Encodable>(
        endpoint: String,
        method: String,
        body: Body? = nil
    ) async throws -> T {
        let request = try await makeRequest(endpoint: endpoint, method: method, body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            if let message = try? decoder.decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(message.message)
            }
            throw NetworkError.serverError("Erreur serveur: \(httpResponse.statusCode)")
        }
        
        if T.self == EmptyPayload.self {
            // swiftlint:disable:next force_cast
            return EmptyPayload() as! T
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ VisitAPI decode error:", error)
            throw NetworkError.decodingError
        }
    }
    
    private func makeRequest<Body: Encodable>(
        endpoint: String,
        method: String,
        body: Body? = nil
    ) async throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = await MainActor.run {
            AuthenticationManager.shared.authToken
        }
        
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body {
            request.httpBody = try encoder.encode(body)
        }
        
        return request
    }
}

private struct EmptyPayload: Encodable, Decodable {}

