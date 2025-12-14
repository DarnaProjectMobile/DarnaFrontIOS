import Foundation
import Combine

class AuthService {
    private let session: URLSession
    private let authManager = AuthManager.shared
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Login
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        let loginRequest = LoginRequest(email: email, password: password)
        
        guard let url = URL(string: "\(APIConfig.baseURL)/api/auth/login") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(loginRequest)
        } catch {
            return Fail(error: NetworkError.encodingError).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 401 {
                        throw NetworkError.authenticationError
                    } else {
                        throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                    }
                }
                
                return data
            }
            .decode(type: AuthResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] authResponse in
                self?.authManager.login(token: authResponse.token, user: authResponse.user)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Register
    func register(user: RegisterRequest) -> AnyPublisher<AuthResponse, Error> {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/auth/register") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            return Fail(error: NetworkError.encodingError).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 400 {
                        throw NetworkError.invalidRequest
                    } else {
                        throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                    }
                }
                
                return data
            }
            .decode(type: AuthResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] authResponse in
                self?.authManager.login(token: authResponse.token, user: authResponse.user)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - Logout
    func logout() {
        authManager.logout()
    }
    
    // MARK: - Reset Password
    func resetPassword(email: String) -> AnyPublisher<Bool, Error> {
        let resetRequest = ResetPasswordRequest(email: email)
        
        guard let url = URL(string: "\(APIConfig.baseURL)/api/auth/reset-password") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(resetRequest)
        } catch {
            return Fail(error: NetworkError.encodingError).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { _, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 404 {
                        throw NetworkError.notFound
                    } else {
                        throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                    }
                }
                
                return true
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Request Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
    let phoneNumber: String?
    let role: UserType
}

struct ResetPasswordRequest: Codable {
    let email: String
}
