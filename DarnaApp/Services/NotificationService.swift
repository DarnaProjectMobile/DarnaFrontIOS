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
    
    func scheduleVisitReminder(for visit: VisitModel, hoursBefore: Int = 24) {
        let content = UNMutableNotificationContent()
        content.title = "Rappel de visite"
        content.body = "Vous avez une visite prévue dans \(hoursBefore)h pour \(visit.propertyTitle)"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        guard let reminderDate = calendar.date(byAdding: .hour, value: -hoursBefore, to: visit.scheduledDate),
              reminderDate > Date() else {
            return
        }
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: visit.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erreur lors de la planification de la notification: \(error)")
            } else {
                print("✅ Notification planifiée pour \(reminderDate)")
            }
        }
    }
    
    func sendVisitRequestNotification(to ownerEmail: String, visit: VisitModel) {
        // Simuler l'envoi d'email
        print("📧 Email envoyé à \(ownerEmail)")
        print("   Sujet: Nouvelle demande de visite")
        print("   Contenu: \(visit.tenantName) a demandé une visite pour \(visit.propertyTitle) le \(formatDate(visit.scheduledDate))")
        
        // Notification push locale
        let content = UNMutableNotificationContent()
        content.title = "Nouvelle demande de visite"
        content.body = "\(visit.tenantName) souhaite visiter \(visit.propertyTitle)"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendVisitStatusNotification(to tenantEmail: String, visit: VisitModel) {
        let statusMessage = visit.status == .accepted ? "acceptée" : 
                           visit.status == .rejected ? "refusée" : 
                           "reportée"
        
        // Simuler l'envoi d'email
        print("📧 Email envoyé à \(tenantEmail)")
        print("   Sujet: Votre demande de visite a été \(statusMessage)")
        print("   Contenu: Votre visite pour \(visit.propertyTitle) a été \(statusMessage)")
        
        // Notification push locale
        let content = UNMutableNotificationContent()
        content.title = "Statut de votre visite"
        content.body = "Votre visite pour \(visit.propertyTitle) a été \(statusMessage)"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(for visitId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [visitId.uuidString])
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

