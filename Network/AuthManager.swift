import Foundation
import Security
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    private let tokenKey = "com.darna.authToken"
    private let userKey = "com.darna.userData"
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private init() {
        // Vérifier si un token existe au démarrage
        if let _ = authToken {
            isAuthenticated = true
            // Charger les informations de l'utilisateur si disponibles
            if let userData = UserDefaults.standard.data(forKey: userKey) {
                currentUser = try? JSONDecoder().decode(User.self, from: userData)
            }
        }
    }
    
    var authToken: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
            isAuthenticated = (newValue != nil)
            if newValue == nil {
                // Supprimer les données utilisateur lors de la déconnexion
                UserDefaults.standard.removeObject(forKey: userKey)
                currentUser = nil
            }
            objectWillChange.send()
        }
    }
    
    func saveUser(_ user: User) {
        currentUser = user
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    func login(token: String, user: User) {
        authToken = token
        saveUser(user)
    }
    
    func logout() {
        authToken = nil
    }
    
    // Vérifier si l'utilisateur a un rôle spécifique
    func hasRole(_ role: UserType) -> Bool {
        return currentUser?.role == role
    }
}

// Modèle utilisateur
struct User: Codable {
    let id: String
    let email: String
    let name: String
    let role: UserType
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email, name, role, phoneNumber
    }
}

// Réponse de l'API de connexion
struct AuthResponse: Codable {
    let token: String
    let user: User
}
