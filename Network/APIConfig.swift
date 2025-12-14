import Foundation

struct APIConfig {
    static let baseURL = "http://192.168.117.242:3002"
    
    enum Endpoints {
        static let visits = "\(APIConfig.baseURL)/api/visits"
        // Ajoutez d'autres endpoints ici au besoin
    }
    
    static var defaultHeaders: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    // Ajoutez ici la logique d'authentification si nécessaire
    static func authHeaders(token: String) -> [String: String] {
        var headers = defaultHeaders
        headers["Authorization"] = "Bearer \(token)"
        return headers
    }
}
