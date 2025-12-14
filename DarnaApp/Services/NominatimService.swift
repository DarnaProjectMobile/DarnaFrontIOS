//
//  NominatimService.swift
//  DarnaApp
//
//  OpenStreetMap Nominatim geocoding service
//

import Foundation
import CoreLocation

// MARK: - Nominatim Response Models

struct NominatimResult: Codable, Identifiable {
    let placeId: Int
    let lat: String
    let lon: String
    let displayName: String
    let type: String?
    let importance: Double?
   
    var id: Int { placeId }
   
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude = Double(lat), let longitude = Double(lon) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
   
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case lat
        case lon
        case displayName = "display_name"
        case type
        case importance
    }
}

struct NominatimReverseResult: Codable {
    let placeId: Int?
    let lat: String?
    let lon: String?
    let displayName: String?
    let address: NominatimAddress?
   
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case lat
        case lon
        case displayName = "display_name"
        case address
    }
}

struct NominatimAddress: Codable {
    let road: String?
    let houseNumber: String?
    let suburb: String?
    let city: String?
    let town: String?
    let village: String?
    let state: String?
    let postcode: String?
    let country: String?
   
    enum CodingKeys: String, CodingKey {
        case road
        case houseNumber = "house_number"
        case suburb
        case city
        case town
        case village
        case state
        case postcode
        case country
    }
   
    var formattedAddress: String {
        var components: [String] = []
       
        if let road = road {
            if let houseNumber = houseNumber {
                components.append("\(houseNumber) \(road)")
            } else {
                components.append(road)
            }
        }
       
        if let suburb = suburb {
            components.append(suburb)
        }
       
        if let city = city ?? town ?? village {
            components.append(city)
        }
       
        if let state = state {
            components.append(state)
        }
       
        if let country = country {
            components.append(country)
        }
       
        return components.joined(separator: ", ")
    }
}

// MARK: - Nominatim Service

enum NominatimError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError
    case noResults
    case rateLimited
   
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .networkError(let error):
            return "Erreur réseau: \(error.localizedDescription)"
        case .decodingError:
            return "Erreur de lecture des données"
        case .noResults:
            return "Aucun résultat trouvé"
        case .rateLimited:
            return "Trop de requêtes. Veuillez réessayer dans quelques secondes."
        }
    }
}

final class NominatimService {
    static let shared = NominatimService()
   
    private let baseURL = "https://nominatim.openstreetmap.org"
    private let userAgent = "DarnaApp/1.0 (iOS)"
   
    // Rate limiting: Nominatim allows max 1 request per second
    private var lastRequestTime: Date?
    private let minRequestInterval: TimeInterval = 1.0
   
    private init() {}
   
    // MARK: - Search (Forward Geocoding)
   
    /// Search for locations by address query
    func search(query: String, limit: Int = 5) async throws -> [NominatimResult] {
        try await enforceRateLimit()
       
        guard var urlComponents = URLComponents(string: "\(baseURL)/search") else {
            throw NominatimError.invalidURL
        }
       
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "addressdetails", value: "1")
        ]
       
        guard let url = urlComponents.url else {
            throw NominatimError.invalidURL
        }
       
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
       
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            lastRequestTime = Date()
           
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NominatimError.networkError(URLError(.badServerResponse))
            }
           
            if httpResponse.statusCode == 429 {
                throw NominatimError.rateLimited
            }
           
            guard httpResponse.statusCode == 200 else {
                throw NominatimError.networkError(URLError(.badServerResponse))
            }
           
            let results = try JSONDecoder().decode([NominatimResult].self, from: data)
            return results
           
        } catch let error as NominatimError {
            throw error
        } catch is DecodingError {
            throw NominatimError.decodingError
        } catch {
            throw NominatimError.networkError(error)
        }
    }
   
    // MARK: - Reverse Geocoding
   
    /// Get address from coordinates
    func reverse(latitude: Double, longitude: Double) async throws -> NominatimReverseResult {
        try await enforceRateLimit()
       
        guard var urlComponents = URLComponents(string: "\(baseURL)/reverse") else {
            throw NominatimError.invalidURL
        }
       
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "addressdetails", value: "1")
        ]
       
        guard let url = urlComponents.url else {
            throw NominatimError.invalidURL
        }
       
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
       
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            lastRequestTime = Date()
           
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NominatimError.networkError(URLError(.badServerResponse))
            }
           
            if httpResponse.statusCode == 429 {
                throw NominatimError.rateLimited
            }
           
            guard httpResponse.statusCode == 200 else {
                throw NominatimError.networkError(URLError(.badServerResponse))
            }
           
            let result = try JSONDecoder().decode(NominatimReverseResult.self, from: data)
            return result
           
        } catch let error as NominatimError {
            throw error
        } catch is DecodingError {
            throw NominatimError.decodingError
        } catch {
            throw NominatimError.networkError(error)
        }
    }
   
    // MARK: - Rate Limiting
   
    private func enforceRateLimit() async throws {
        if let lastRequest = lastRequestTime {
            let elapsed = Date().timeIntervalSince(lastRequest)
            if elapsed < minRequestInterval {
                let delay = minRequestInterval - elapsed
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }
}

// MARK: - Coordinate Formatting Helper

extension CLLocationCoordinate2D {
    var formattedString: String {
        String(format: "Lat: %.5f / Lon: %.5f", latitude, longitude)
    }
}
