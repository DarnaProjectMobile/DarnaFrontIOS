//
//  PropertyService.swift
//  DarnaApp
//

import Foundation

final class PropertyService {
    static let shared = PropertyService()
    private init() {}

    // ✅ Centralized server URL — replace with your machine’s IP
    private let baseURL = "http://172.20.10.2:3000"

    // MARK: - Fetch all properties
    func fetchProperties() async throws -> [Property] {
        guard let url = URL(string: "\(baseURL)/annonces") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Optional auth token
        let token = await MainActor.run {
            AuthenticationManager.shared.authToken
        }
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if !(200..<300).contains(httpResponse.statusCode) {
            print("❌ Fetch properties failed with status:", httpResponse.statusCode)
            print("📦 Response body:", String(data: data, encoding: .utf8) ?? "nil")
            throw NetworkError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Property].self, from: data)
        } catch {
            print("❌ Decode error:", error)
            throw NetworkError.decodingError
        }
    }

    // MARK: - Create new property
    func createProperty(title: String,
                        description: String,
                        price: Double,
                        location: String,
                        type: String,
                        startDate: Date,
                        endDate: Date,
                        imageUrl: String?) async throws -> Property {
        guard let url = URL(string: "\(baseURL)/annonces") else {
            throw NetworkError.invalidURL
        }

        let (user, token) = await MainActor.run {
            (
                AuthenticationManager.shared.currentUser,
                AuthenticationManager.shared.authToken
            )
        }

        guard let user else {
            throw NetworkError.unauthorized
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // ✅ Match backend field names
        let body: [String: Any?] = [
            "title": title,
            "description": description,
            "price": price,
            "user": user.id,
            "image": imageUrl,
            "type": type,
            "location": location,
            "startDate": isoFormatter.string(from: startDate),
            "endDate": isoFormatter.string(from: endDate)
        ]

        let sanitized = body.compactMapValues { $0 }
        request.httpBody = try JSONSerialization.data(withJSONObject: sanitized)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "No response body"
            print("❌ Property creation failed:")
            print("📡 Status:", httpResponse.statusCode)
            print("📦 Server says:", serverMessage)

            if let data = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = data["message"] {
                throw NetworkError.serverError(String(describing: message))
            } else {
                throw NetworkError.invalidResponse
            }
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let property = try decoder.decode(Property.self, from: data)
            print("✅ Property created successfully:", property.title)
            return property
        } catch {
            print("❌ Decode error:", error)
            throw NetworkError.decodingError
        }
    }

    // MARK: - Update property
    func updateProperty(id: String,
                        title: String,
                        description: String,
                        price: Double,
                        location: String,
                        type: String,
                        startDate: Date,
                        endDate: Date,
                        imageUrl: String?) async throws -> Property {
        guard let url = URL(string: "\(baseURL)/annonces/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        let (_, token) = await MainActor.run {
            (
                AuthenticationManager.shared.currentUser,
                AuthenticationManager.shared.authToken
            )
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let body: [String: Any?] = [
            "title": title,
            "description": description,
            "price": price,
            "location": location,
            "type": type,
            "startDate": isoFormatter.string(from: startDate),
            "endDate": isoFormatter.string(from: endDate),
            "image": imageUrl
        ]
        
        let sanitized = body.compactMapValues { $0 }
        request.httpBody = try JSONSerialization.data(withJSONObject: sanitized)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "No response body"
            print("❌ Property update failed:")
            print("📡 Status:", httpResponse.statusCode)
            print("📦 Server says:", serverMessage)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = json["message"] {
                throw NetworkError.serverError(String(describing: message))
            }
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Property.self, from: data)
        } catch {
            print("❌ Decode error:", error)
            throw NetworkError.decodingError
        }
    }

    // MARK: - Delete property
    func deleteProperty(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/annonces/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        let token = await MainActor.run {
            AuthenticationManager.shared.authToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw NetworkError.serverError("Suppression impossible : \(message)")
        }
    }
}
