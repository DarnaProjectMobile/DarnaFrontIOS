import Foundation
import Combine

// Enum pour gérer les erreurs réseau
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
    case serverError(String)
    case unauthorized
    case notFound
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .invalidResponse:
            return "Réponse invalide du serveur"
        case .statusCode(let code):
            return "Erreur serveur: \(code)"
        case .decodingError(let error):
            return "Erreur de décodage: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Non autorisé. Veuillez vous reconnecter."
        case .notFound:
            return "Ressource non trouvée"
        case .unknown:
            return "Une erreur inconnue est survenue"
        }
    }
}

class VisitService: ObservableObject {
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    // Token d'authentification (à gérer avec votre système d'authentification)
    private var authToken: String? {
        // Récupérer le token depuis le stockage sécurisé (Keychain)
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Configuration de la requête
    private func createRequest(
        endpoint: String,
        method: String,
        body: Data? = nil,
        queryItems: [URLQueryItem]? = nil
    ) -> URLRequest? {
        guard var urlComponents = URLComponents(string: endpoint) else { return nil }
        
        // Ajouter les paramètres de requête
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Ajout des en-têtes par défaut
        APIConfig.defaultHeaders.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Ajout du token d'authentification si disponible
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Ajout du corps de la requête si nécessaire
        if let body = body {
            request.httpBody = body
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    // MARK: - Gestion des réponses
    private func handleResponse<T: Decodable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidResponse))
            }
            return
        }
        
        // Vérifier le code de statut HTTP
        switch httpResponse.statusCode {
        case 200...299:
            // Succès
            if let data = data, !data.isEmpty {
                do {
                    let decoder = JSONDecoder.iso8601
                    let decodedData = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingError(error)))
                    }
                }
            } else {
                // Pour les réponses sans corps (comme les suppressions)
                if let emptyResponse = EmptyResponse() as? T {
                    DispatchQueue.main.async {
                        completion(.success(emptyResponse))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.invalidResponse))
                    }
                }
            }
            
        case 401:
            // Non autorisé
            DispatchQueue.main.async {
                // Déconnexion de l'utilisateur
                NotificationCenter.default.post(name: .userDidLogout, extension: nil)
                completion(.failure(NetworkError.unauthorized))
            }
            
        case 404:
            // Non trouvé
            DispatchQueue.main.async {
                completion(.failure(NetworkError.notFound))
            }
            
        case 400...499:
            // Erreur client
            let errorMessage = parseError(from: data) ?? "Erreur de requête"
            DispatchQueue.main.async {
                completion(.failure(NetworkError.serverError(errorMessage)))
            }
            
        case 500...599:
            // Erreur serveur
            DispatchQueue.main.async {
                completion(.failure(NetworkError.serverError("Erreur serveur. Veuillez réessayer plus tard.")))
            }
            
        default:
            // Autres erreurs
            DispatchQueue.main.async {
                completion(.failure(NetworkError.unknown))
            }
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let statusError = NetworkError.serverError(statusCode: httpResponse.statusCode)
            completion(.failure(statusError))
            return
        }
        
        guard let data = data, !data.isEmpty else {
            completion(.failure(NetworkError.noData))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedData = try decoder.decode(T.self, from: data)
            completion(.success(decodedData))
        } catch {
            print("Decoding error: \(error)")
            completion(.failure(NetworkError.decodingError))
        }
    }
    
    // MARK: - Fetch All Visits
    func fetchVisits(userId: String, userType: UserType, completion: @escaping (Result<[Visit], Error>) -> Void) {
        let endpoint = "\(APIConfig.Endpoints.visits)/\(userType.rawValue)/\(userId)"
        
        guard let request = createRequest(endpoint: endpoint, method: "GET") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let visits = try decoder.decode([Visit].self, from: data)
                completion(.success(visits))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Create Visit
    func createVisit(_ visit: CreateVisitRequest, completion: @escaping (Result<Visit, Error>) -> Void) {
        guard let url = URL(string: APIConfig.Endpoints.visits) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(visit) else {
            completion(.failure(NetworkError.encodingError))
            return
        }
        
        guard var request = createRequest(endpoint: APIConfig.Endpoints.visits, method: "POST", body: jsonData) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(visit)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let createdVisit = try decoder.decode(Visit.self, from: data)
                completion(.success(createdVisit))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Update Visit
    func updateVisit(id: String, with updateData: UpdateVisitRequest, completion: @escaping (Result<Visit, Error>) -> Void) {
        let endpoint = "\(APIConfig.Endpoints.visits)/\(id)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(updateData)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let updatedVisit = try decoder.decode(Visit.self, from: data)
                completion(.success(updatedVisit))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Delete Visit
    func deleteVisit(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "\(APIConfig.Endpoints.visits)/\(id)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = session.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(true))
            } else {
                completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
            }
        }
        
        task.resume()
    }
}

// MARK: - Enums
enum UserType: String, Codable {
    case client
    case collector
    case admin
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidRequest
    case serverError(statusCode: Int)
    case noData
    case decodingError
    case encodingError
    case authenticationError
    case notFound
    case serverUnavailable
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("URL invalide", comment: "Invalid URL")
        case .invalidResponse:
            return NSLocalizedString("Réponse invalide du serveur", comment: "Invalid server response")
        case .invalidRequest:
            return NSLocalizedString("Requête invalide", comment: "Invalid request")
        case .serverError(let statusCode):
            return NSLocalizedString("Erreur serveur: \(statusCode)", comment: "Server error")
        case .noData:
            return NSLocalizedString("Aucune donnée reçue", comment: "No data received")
        case .decodingError:
            return NSLocalizedString("Erreur lors du décodage des données", comment: "Data decoding error")
        case .encodingError:
            return NSLocalizedString("Erreur lors de l'encodage des données", comment: "Data encoding error")
        case .authenticationError:
            return NSLocalizedString("Erreur d'authentification", comment: "Authentication error")
        case .notFound:
            return NSLocalizedString("Ressource non trouvée", comment: "Resource not found")
        case .serverUnavailable:
            return NSLocalizedString("Serveur indisponible", comment: "Server unavailable")
        case .networkError(let error):
            return NSLocalizedString("Erreur réseau: \(error.localizedDescription)", comment: "Network error")
        }
    }
}

// MARK: - Extensions

extension Encodable {
    func toJSONData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
}

extension Data {
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: self)
    }
}
