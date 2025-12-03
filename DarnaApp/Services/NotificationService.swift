//
//  NotificationService.swift
//  DarnaApp
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Autorisation de notification accordée")
            } else {
                print("❌ Autorisation de notification refusée")
            }
        }
    }
    
    func scheduleNotification(title: String,
                              body: String,
                              trigger: UNNotificationTrigger,
                              identifier: String = UUID().uuidString) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erreur lors de la planification de la notification: \(error)")
            }
        }
    }
    
    func cancelNotification(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}


