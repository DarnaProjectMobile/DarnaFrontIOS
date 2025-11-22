//
//  PropertyService.swift
//  DarnaApp
//

import Foundation

final class PropertyService {
    static let shared = PropertyService()
    private init() {}
    
    // ✅ Centralized server URL — replace with your machine’s IP
    private let baseURL = "http://10.147.89.155:3000"
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
                        images: [String],
                        nbrCollocateurMax: Int,
                        nbrCollocateurActuel: Int = 0) async throws -> Property {
        guard let url = URL(string: "\(baseURL)/annonces") else {
            throw NetworkError.invalidURL
        }

        let token = await MainActor.run {
            AuthenticationManager.shared.authToken
        }

        guard token != nil else {
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

        // ✅ Match backend CreateAnnonceDto structure
        let body: [String: Any] = [
            "title": title,
            "description": description,
            "price": price,
            "location": location,
            "type": type,
            "images": images,
            "nbrCollocateurMax": nbrCollocateurMax,
            "nbrCollocateurActuel": nbrCollocateurActuel,
            "startDate": isoFormatter.string(from: startDate),
            "endDate": isoFormatter.string(from: endDate)
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

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
                        title: String? = nil,
                        description: String? = nil,
                        price: Double? = nil,
                        location: String? = nil,
                        type: String? = nil,
                        startDate: Date? = nil,
                        endDate: Date? = nil,
                        images: [String]? = nil,
                        nbrCollocateurMax: Int? = nil,
                        nbrCollocateurActuel: Int? = nil) async throws -> Property {
        guard let url = URL(string: "\(baseURL)/annonces/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        let token = await MainActor.run {
            AuthenticationManager.shared.authToken
        }
        
        guard token != nil else {
            throw NetworkError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Build body with only provided fields (partial update like UpdateAnnonceDto)
        var body: [String: Any] = [:]
        if let title = title { body["title"] = title }
        if let description = description { body["description"] = description }
        if let price = price { body["price"] = price }
        if let location = location { body["location"] = location }
        if let type = type { body["type"] = type }
        if let images = images { body["images"] = images }
        if let nbrCollocateurMax = nbrCollocateurMax { body["nbrCollocateurMax"] = nbrCollocateurMax }
        if let nbrCollocateurActuel = nbrCollocateurActuel { body["nbrCollocateurActuel"] = nbrCollocateurActuel }
        if let startDate = startDate { body["startDate"] = isoFormatter.string(from: startDate) }
        if let endDate = endDate { body["endDate"] = isoFormatter.string(from: endDate) }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
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
    
    // MARK: - Fetch single property by ID
    func fetchProperty(id: String) async throws -> Property {
        guard let url = URL(string: "\(baseURL)/annonces/\(id)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if !(200..<300).contains(httpResponse.statusCode) {
            print("❌ Fetch property failed with status:", httpResponse.statusCode)
            print("📦 Response body:", String(data: data, encoding: .utf8) ?? "nil")
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
    
    // MARK: - Book property
    func bookProperty(id: String, bookingStartDate: Date) async throws -> Property {
        guard let url = URL(string: "\(baseURL)/annonces/\(id)/book") else {
            throw NetworkError.invalidURL
        }
        
        let token = await MainActor.run {
            AuthenticationManager.shared.authToken
        }
        
        guard token != nil else {
            throw NetworkError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Normalize date to start of day in UTC to avoid timezone issues
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: bookingStartDate)
        guard let normalizedDate = calendar.date(from: components) else {
            throw NetworkError.encodingError
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Use UTC
        
        let body: [String: Any] = [
            "bookingStartDate": isoFormatter.string(from: normalizedDate)
        ]
        
        print("📤 Booking request body:", body)
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "No response body"
            print("❌ Property booking failed:")
            print("📡 Status:", httpResponse.statusCode)
            print("📦 Server says:", serverMessage)
            
            // Try to extract error message from response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let message = json["message"] as? String {
                    throw NetworkError.serverError(message)
                } else if let error = json["error"] as? String {
                    throw NetworkError.serverError(error)
                } else if let message = json["message"] {
                    throw NetworkError.serverError(String(describing: message))
                }
            }
            
            // If no specific message, provide a generic one based on status code
            if httpResponse.statusCode == 500 {
                throw NetworkError.serverError("Erreur interne du serveur. Veuillez réessayer plus tard.")
            } else if httpResponse.statusCode == 400 {
                throw NetworkError.serverError("Requête invalide. Vérifiez la date de réservation.")
            } else if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            } else {
                throw NetworkError.serverError("Erreur: \(httpResponse.statusCode)")
            }
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let property = try decoder.decode(Property.self, from: data)
            print("✅ Property booked successfully:", property.title)
            return property
        } catch {
            print("❌ Decode error:", error)
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Fetch user's properties (owned by current user)
    func fetchUserProperties() async throws -> [Property] {
        guard let url = URL(string: "\(baseURL)/annonces") else {
            throw NetworkError.invalidURL
        }
        
        let token = await MainActor.run {
            AuthenticationManager.shared.authToken
        }
        
        guard token != nil else {
            throw NetworkError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if !(200..<300).contains(httpResponse.statusCode) {
            print("❌ Fetch user properties failed with status:", httpResponse.statusCode)
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let allProperties = try decoder.decode([Property].self, from: data)
            
            // Filter to only return properties owned by current user
            let currentUserId = await MainActor.run {
                AuthenticationManager.shared.currentUser?.id
            }
            
            guard let userId = currentUserId else {
                throw NetworkError.unauthorized
            }
            
            return allProperties.filter { $0.user == userId }
        } catch {
            print("❌ Decode error:", error)
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Fetch property with bookings
    func fetchPropertyWithBookings(id: String) async throws -> PropertyWithBookings {
        guard let url = URL(string: "\(baseURL)/annonces/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        let token = await MainActor.run {
            AuthenticationManager.shared.authToken
        }
        
        guard token != nil else {
            throw NetworkError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if !(200..<300).contains(httpResponse.statusCode) {
            print("❌ Fetch property with bookings failed with status:", httpResponse.statusCode)
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // Decode property first
            let property = try decoder.decode(Property.self, from: data)
            
            // Parse bookings from JSON
            var bookings: [Booking] = []
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let bookingsArray = json["bookings"] as? [[String: Any]] {
                for bookingDict in bookingsArray {
                    if let bookingData = try? JSONSerialization.data(withJSONObject: bookingDict) {
                        if let booking = try? decoder.decode(Booking.self, from: bookingData) {
                            bookings.append(booking)
                        }
                    }
                }
            }
            
            return PropertyWithBookings(property: property, bookings: bookings)
        } catch {
            print("❌ Decode error:", error)
            throw NetworkError.decodingError
        }
    }
}
