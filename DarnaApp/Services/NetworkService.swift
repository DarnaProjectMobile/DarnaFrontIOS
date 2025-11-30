//
//  NetworkService.swift
//  DarnaApp
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case invalidResponse
    case unauthorized
    case emailAlreadyExists
    case encodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "L’adresse du serveur est invalide."
        case .noData: return "Aucune donnée reçue du serveur."
        case .decodingError: return "Erreur lors de la lecture des données."
        case .serverError(let message): return message
        case .invalidResponse: return "Réponse du serveur invalide."
        case .unauthorized: return "Identifiants incorrects."
        case .emailAlreadyExists: return "Cet email est déjà enregistré."
        case .encodingError: return "Erreur lors de la préparation des données."
        }
    }
}

// MARK: - Network Service (DarnaApp)
final class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "http://10.42.113.107:3000"
    
    private init() {}
    
    // MARK: - LOGIN
    func login(email: String, password: String) async throws -> SignInResponse {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let body = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200, 201:
            do {
                let signInResponse = try JSONDecoder().decode(SignInResponse.self, from: data)
                print("✅ Connexion réussie :", signInResponse.user.username)
                
                await MainActor.run {
                    AuthenticationManager.shared.signIn(with: signInResponse)
                }
                return signInResponse

            } catch {
                print("❌ Erreur de décodage:", error)
                throw NetworkError.decodingError
            }

        case 401:
            throw NetworkError.unauthorized
        default:
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw NetworkError.serverError(errorResponse.message)
            } catch {
                throw NetworkError.serverError("Une erreur inconnue est survenue.")
            }
        }
    }

    // MARK: - REGISTER (Fixed + Improved)
    func register(
        username: String,
        fullName: String,
        email: String,
        password: String,
        birthDate: String,
        phoneNumber: String,
        gender: String,
        role: String
    ) async throws -> User {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            throw NetworkError.invalidURL
        }

        // ✅ Convert "JJ/MM/AAAA" → "YYYY-MM-DD"
        func convertToISODate(_ input: String) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            if let date = formatter.date(from: input) {
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: date)
            }
            return input
        }

        // ✅ Prepare sanitized values
        let isoBirthDate = convertToISODate(birthDate)
        let cleanPhone = phoneNumber.replacingOccurrences(of: "+216", with: "")
        let genderValue = gender == "Homme" ? "Male" : "Female"
        // Role is already in correct backend format (client/collocator/sponsor)
        let roleValue = role.lowercased()

        let payload: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "role": roleValue,
            "dateDeNaissance": isoBirthDate,
            "numTel": cleanPhone,
            "gender": genderValue
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: payload) else {
            throw NetworkError.encodingError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        // 🪵 Debug Logs
        print("📤 Sending register request to:", url)
        print("📦 Payload:", payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        // 🪵 Log backend response
        print("🧭 REGISTER RESPONSE STATUS:", httpResponse.statusCode)
        print("📩 RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "Empty body")

        switch httpResponse.statusCode {
        case 201:
            do {
                // ✅ Decode directly to User since backend returns user object
                let user = try JSONDecoder().decode(User.self, from: data)
                print("✅ Utilisateur inscrit :", user.username)
                return user
            } catch {
                let raw = String(data: data, encoding: .utf8) ?? "Empty"
                print("❌ Erreur de décodage (register):", raw)
                throw NetworkError.decodingError
            }

        case 400:
            throw NetworkError.emailAlreadyExists

        default:
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = json["message"] as? String {
                throw NetworkError.serverError(message)
            } else {
                throw NetworkError.serverError("Erreur inconnue du serveur.")
            }
        }
    }

    // MARK: - LOGOUT
    func logout(userId: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/logout") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["userId": userId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            print("✅ Déconnexion réussie")
            await AuthenticationManager.shared.signOut()
        default:
            let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw NetworkError.serverError("Échec de la déconnexion : \(message)")
        }
    }

    // MARK: - JWT Decoder
    func decodeJWT(token: String) -> [String: Any]? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }
        
        var base64 = String(parts[1])
        while base64.count % 4 != 0 { base64.append("=") }
        
        guard let data = Data(base64Encoded: base64) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
