//
//  AuthenticationManager.swift
//  DarnaApp
//
//  Created by Apple Esprit on 8/11/2025.
//

import Foundation
import Combine

extension Notification.Name {
    static let authenticationDidChange = Notification.Name("authenticationDidChange")
}

@MainActor
final class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    private init() {}
    
    

    // MARK: - Published Properties
    @Published private(set) var currentUser: User? = nil
    @Published private(set) var authToken: String? = nil

    // MARK: - Sign In
    func signIn(with response: SignInResponse) {
        currentUser = response.user
        authToken = response.token
        persistUser(response.user)
        persistToken(response.token)
        NotificationCenter.default.post(name: .authenticationDidChange, object: nil)
    }

    // MARK: - Load from Storage
    func loadCurrentUser() {
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
        authToken = UserDefaults.standard.string(forKey: "authToken")
    }

    // MARK: - Sign Out
    func signOut() {
        // Clear data safely
        currentUser = nil
        authToken = nil
        
        // Remove persisted session
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "authToken")
        
        // Notify about auth change
        NotificationCenter.default.post(name: .authenticationDidChange, object: nil)
        
        print("✅ User successfully signed out.")
    }

    // MARK: - Private Persistence Helpers
    private func persistUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }

    private func persistToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    
}
