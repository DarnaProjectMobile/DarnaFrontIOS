//
//  KeychainHelper.swift
//  DarnaApp
//
//  Secure storage for credentials using iOS Keychain
//

import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    private let service = "com.darna.app"
    private let emailKey = "savedEmail"
    private let passwordKey = "savedPassword"
    private let rememberMeKey = "rememberMe"
    
    // MARK: - Save Credentials
    func saveCredentials(email: String, password: String) {
        // Save email in UserDefaults (not sensitive)
        UserDefaults.standard.set(email, forKey: emailKey)
        
        // Save password in Keychain (sensitive)
        savePassword(password)
        
        // Save remember me preference
        UserDefaults.standard.set(true, forKey: rememberMeKey)
        
        print("✅ Credentials saved securely")
    }
    
    // MARK: - Load Credentials
    func loadCredentials() -> (email: String?, password: String?) {
        guard UserDefaults.standard.bool(forKey: rememberMeKey) else {
            return (nil, nil)
        }
        
        let email = UserDefaults.standard.string(forKey: emailKey)
        let password = loadPassword()
        
        return (email, password)
    }
    
    // MARK: - Clear Credentials
    func clearCredentials() {
        UserDefaults.standard.removeObject(forKey: emailKey)
        UserDefaults.standard.removeObject(forKey: rememberMeKey)
        deletePassword()
        print("✅ Credentials cleared")
    }
    
    // MARK: - Check if Remember Me is enabled
    func isRememberMeEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: rememberMeKey)
    }
    
    // MARK: - Private Keychain Operations
    
    private func savePassword(_ password: String) {
        guard let passwordData = password.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: passwordKey,
            kSecValueData as String: passwordData
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("✅ Password saved to Keychain")
        } else {
            print("❌ Failed to save password to Keychain: \(status)")
        }
    }
    
    private func loadPassword() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: passwordKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let password = String(data: data, encoding: .utf8) {
            return password
        }
        
        return nil
    }
    
    private func deletePassword() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: passwordKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
