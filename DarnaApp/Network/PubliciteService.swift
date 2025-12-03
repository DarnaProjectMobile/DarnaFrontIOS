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

class PubliciteService: PubliciteServiceProtocol {
    static let shared = PubliciteService()
    
    // Utilise la configuration centralisée du serveur
    private let baseURL = "\(ServerConfig.baseURL)/publicite"
    
    private init() {}
    
    // MARK: - Helper pour récupérer le user et le token sur le MainActor
    @MainActor
    private func getAuthContext() -> (user: User?, token: String?) {
        (
            AuthenticationManager.shared.currentUser,
            AuthenticationManager.shared.authToken
        )
    }
    
    // MARK: - Helper pour créer les requêtes avec JWT
    private func createRequest(url: URL, method: String, token: String?, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Token JWT ajouté")
        } else {
            print("⚠️ Aucun token JWT trouvé")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    // MARK: - Fetch All Publicites
    func fetchPublicites() async throws -> [Publicite] {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        print("🌐 GET \(baseURL)")
        
        // Récupérer le token
        let (_, token) = await getAuthContext()
        let request = createRequest(url: url, method: "GET", token: token)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📥 Status Code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    print("❌ Unauthorized")	
                    throw APIError.httpError(statusCode: 401)
                }
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
            
            // Debug: afficher la réponse
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Response: \(jsonString.prefix(500))")
            }
            
            do {
                // Essayer de décoder comme un tableau direct
                let publicites = try JSONDecoder().decode([Publicite].self, from: data)
                print("✅ \(publicites.count) publicités chargées")
                return publicites
            } catch {
                // Essayer de décoder comme une réponse wrapper
                do {
                    let response = try JSONDecoder().decode(PubliciteListResponse.self, from: data)
                    if let publicites = response.data {
                        print("✅ \(publicites.count) publicités chargées (wrapper)")
                        return publicites
                    }
                    throw APIError.decodingError(NSError(domain: "No data in response", code: -1))
                } catch {
                    print("❌ Erreur de décodage: \(error)")
                    throw APIError.decodingError(error)
                }
            }
        } catch let error as APIError {
            throw error
        } catch {
            print("❌ Network Error: \(error)")
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Create Publicite
    func createPublicite(_ publicite: PubliciteDTO) async throws -> Publicite {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        print("🌐 POST \(baseURL)")
        
        let body = try JSONEncoder().encode(publicite)
        if let jsonString = String(data: body, encoding: .utf8) {
            print("📤 Body: \(jsonString)")
        }
        
        let (_, token) = await getAuthContext()
        let request = createRequest(url: url, method: "POST", token: token, body: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📥 Status Code: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw APIError.httpError(statusCode: 401)
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            // Essayer de décoder comme un objet direct
            let publicite = try JSONDecoder().decode(Publicite.self, from: data)
            print("✅ Publicité créée: \(publicite.id)")
            return publicite
        } catch {
            // Essayer de décoder comme une réponse wrapper
            do {
                let response = try JSONDecoder().decode(SinglePubliciteResponse.self, from: data)
                if let publicite = response.data {
                    print("✅ Publicité créée: \(publicite.id) (wrapper)")
                    return publicite
                }
                throw APIError.decodingError(NSError(domain: "No data in response", code: -1))
            } catch {
                print("❌ Erreur de décodage: \(error)")
                throw APIError.decodingError(error)
            }
        }
    }
    
    // MARK: - Update Publicite
    func updatePublicite(id: String, publicite: PubliciteDTO) async throws -> Publicite {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw APIError.invalidURL
        }
        
        print("🌐 PATCH \(baseURL)/\(id)")
        
        let body = try JSONEncoder().encode(publicite)
        let (_, token) = await getAuthContext()
        let request = createRequest(url: url, method: "PATCH", token: token, body: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📥 Status Code: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw APIError.httpError(statusCode: 401)
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            // Essayer de décoder comme un objet direct
            let publicite = try JSONDecoder().decode(Publicite.self, from: data)
            print("✅ Publicité mise à jour: \(publicite.id)")
            return publicite
        } catch {
            // Essayer de décoder comme une réponse wrapper
            do {
                let response = try JSONDecoder().decode(SinglePubliciteResponse.self, from: data)
                if let publicite = response.data {
                    print("✅ Publicité mise à jour: \(publicite.id) (wrapper)")
                    return publicite
                }
                throw APIError.decodingError(NSError(domain: "No data in response", code: -1))
            } catch {
                print("❌ Erreur de décodage: \(error)")
                throw APIError.decodingError(error)
            }
        }
    }
    
    // MARK: - Delete Publicite
    func deletePublicite(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw APIError.invalidURL
        }
        
        print("🌐 DELETE \(baseURL)/\(id)")
        
        let (_, token) = await getAuthContext()
        let request = createRequest(url: url, method: "DELETE", token: token)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📥 Status Code: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw APIError.httpError(statusCode: 401)
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        print("✅ Publicité supprimée: \(id)")
    }
}
