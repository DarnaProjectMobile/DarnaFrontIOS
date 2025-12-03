//
//  PushNotificationManager.swift
//  DarnaApp
//

import Foundation
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import UIKit

final class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()
    
    private let tokenStorageKey = "fcmDeviceToken"
    private var hasRequestedAuthorization = false
    
    private override init() {
        super.init()
    }
    
    func configureIfNeeded() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        requestAuthorizationIfNeeded()
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    private func requestAuthorizationIfNeeded() {
        guard hasRequestedAuthorization == false else { return }
        hasRequestedAuthorization = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ Notification authorization error: \(error.localizedDescription)")
            } else {
                print(granted ? "✅ Push authorization granted" : "⚠️ Push authorization denied")
            }
        }
    }
    
    private func cacheToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenStorageKey)
    }
    
    private var cachedToken: String? {
        UserDefaults.standard.string(forKey: tokenStorageKey)
    }
    
    func syncTokenWithBackendIfNeeded() {
        guard let token = cachedToken else { return }
        Task {
            do {
                try await NetworkService.shared.registerDeviceToken(token)
                print("✅ Device token synced with backend")
            } catch {
                print("❌ Failed to sync device token: \(error.localizedDescription)")
            }
        }
    }
    
    func unregisterDeviceTokenFromBackend() {
        guard let token = cachedToken else { return }
        Task {
            do {
                try await NetworkService.shared.removeDeviceToken(token)
                print("✅ Device token removed from backend")
            } catch {
                print("⚠️ Failed to remove device token: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Messaging Delegate
extension PushNotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        cacheToken(token)
        syncTokenWithBackendIfNeeded()
        print("📲 Received FCM token: \(token)")
    }
}

// MARK: - User Notification Center Delegate
extension PushNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

