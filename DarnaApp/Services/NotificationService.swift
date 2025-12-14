//
//  NotificationService.swift
//  DarnaApp
//
//

import Foundation
import UserNotifications
import Combine // Required for @Published

enum NotificationType: String, Codable {
    case visitConfirmed
    case visitCancelled
    case visitReminder
    case info
}

class NotificationService: NSObject, ObservableObject { // Inherit from NSObject and ObservableObject
    static let shared = NotificationService()
    
    // MARK: - Persistence
    
    struct AppNotification: Identifiable, Codable {
        let id: String
        let title: String
        let body: String
        let date: Date
        var isRead: Bool
        var type: NotificationType?
        var relatedId: String?
    }
    
    private let storageKey = "saved_notifications"
    
    @Published var notifications: [AppNotification] = []
    
    override private init() { // Change to override private init()
        super.init()
        loadNotifications()
    }
    
    private func saveNotification(title: String, body: String) {
        let newNotif = AppNotification(
            id: UUID().uuidString,
            title: title,
            body: body,
            date: Date(),
            isRead: false,
            type: .info,
            relatedId: nil
        )
        notifications.insert(newNotif, at: 0)
        persistNotifications()
    }
    
    private func persistNotifications() {
        if let data = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadNotifications() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([AppNotification].self, from: data) {
            notifications = decoded
        }
    }
    
    func markAllAsRead() {
        for i in 0..<notifications.count {
            notifications[i].isRead = true
        }
        persistNotifications()
    }
    
    func clearAll() {
        notifications.removeAll()
        persistNotifications()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Autorisation de notification accordée")
            } else {
                print("❌ Autorisation de notification refusée")
            }
        }
    }
    
    
    // MARK: - Visit Notifications
    
    /// Planifie tous les rappels pour une visite confirmée
    /// - Rappel 2 jours avant (si possible)
    /// - Rappel 1 jour avant (si possible)
    /// - Rappel le jour J (matin)
    func scheduleVisitReminders(for visit: Visit) {
        guard let visitDate = visit.visitDate, visit.status == .confirmed else { return }
        
        let visitId = visit.id
        let title = visit.title
        
        // 1. Rappel 2 jours avant
        scheduleNotification(
            id: "\(visitId)_2days",
            title: "Visite dans 2 jours",
            body: "Rappel : Vous avez une visite prévue pour '\(title)' le \(formatDate(visitDate)).",
            date: Calendar.current.date(byAdding: .day, value: -2, to: visitDate)
        )
        
        // 2. Rappel 1 jour avant
        scheduleNotification(
            id: "\(visitId)_1day",
            title: "Visite demain",
            body: "N'oubliez pas ! Visite pour '\(title)' demain à \(formatTime(visitDate)).",
            date: Calendar.current.date(byAdding: .day, value: -1, to: visitDate)
        )
        
        // 3. Rappel le jour même (2 heures avant)
        scheduleNotification(
            id: "\(visitId)_today",
            title: "Visite aujourd'hui",
            body: "C'est le grand jour ! Visite prévue pour '\(title)' à \(formatTime(visitDate)).",
            date: Calendar.current.date(byAdding: .hour, value: -2, to: visitDate)
        )
        
        print("📅 Rappels planifiés pour la visite : \(title)")
    }
    
    /// Planifie une notification à une date spécifique
    private func scheduleNotification(id: String, title: String, body: String, date: Date?) {
        guard let date = date, date > Date() else { return }
        
        // ... (iOS System Notification)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Auto-Generation from History
    
    func generateNotifications(from visits: [Visit]) {
        print("🔔 Génération des notifications depuis l'historique...")
        var newNotifications: [AppNotification] = []
        
        for visit in visits {
            let title = visit.logementTitle ?? "Visite"
            var notif: AppNotification?
            
            // On génère une notification si la visite est dans un état final/important
            
            switch visit.status {
            case .confirmed:
                notif = AppNotification(
                    id: UUID().uuidString,
                    title: "Visite Confirmée",
                    body: "Votre visite pour \(title) a été confirmée.",
                    date: visit.visitDate ?? Date(),
                    isRead: false,
                    type: .visitConfirmed,
                    relatedId: visit.id
                )
            case .refused:
                notif = AppNotification(
                    id: UUID().uuidString,
                    title: "Visite Refusée",
                    body: "Votre demande pour \(title) a été refusée.",
                    date: visit.visitDate ?? Date(),
                    isRead: false,
                    type: .visitCancelled,
                    relatedId: visit.id
                )
            case .cancelled:
                notif = AppNotification(
                    id: UUID().uuidString,
                    title: "Visite Annulée",
                    body: "Vous avez annulé la visite de \(title).",
                    date: visit.visitDate ?? Date(),
                    isRead: false,
                    type: .visitCancelled,
                    relatedId: visit.id
                )
            case .completed:
                 notif = AppNotification(
                    id: UUID().uuidString,
                    title: "Visite Terminée",
                    body: "N'oubliez pas de laisser un avis sur \(title) !",
                    date: visit.visitDate ?? Date(),
                    isRead: false,
                    type: .visitReminder,
                    relatedId: visit.id
                )
            default:
                break
            }
            
            if let n = notif {
                // Vérifier si cette notification existe déjà (basé sur relatedId et Type)
                // pour ne pas spammer à chaque lancement
                if !notifications.contains(where: { $0.relatedId == n.relatedId && $0.type == n.type }) {
                    newNotifications.append(n)
                }
            }
        }
        
        if !newNotifications.isEmpty {
            notifications.append(contentsOf: newNotifications)
            // Trier par date décroissante
            notifications.sort { $0.date > $1.date }
            persistNotifications()
            print("✅ \(newNotifications.count) nouvelles notifications générées.")
        } else {
            print("🔕 Aucune nouvelle notification à générer.")
        }
    }
    
    // MARK: - Instant Feedback Notifications
    
    func sendInstantNotification(title: String, body: String) {
        // 1. Ajouter à l'historique in-app
        saveNotification(title: title, body: body)
        
        // 2. Envoyer notification système
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(for visitId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "\(visitId)_2days",
            "\(visitId)_1day",
            "\(visitId)_today"
        ])
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}
