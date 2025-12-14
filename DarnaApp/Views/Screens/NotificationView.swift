//
//  NotificationView.swift
//  DarnaApp
//
//  Vue simple pour la liste des notifications (Placeholder)
//

import SwiftUI

struct NotificationView: View {
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if notificationService.notifications.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Aucune notification")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Vous serez notifié des mises à jour importantes ici.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(notificationService.notifications) { notification in
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primary.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(AppTheme.primary)
                                        .font(.system(size: 18))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notification.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(notification.body)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    
                                    Text(formatDate(notification.date))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                if !notificationService.notifications.isEmpty {
                    Button("Effacer tout") {
                        notificationService.clearAll()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

#Preview {
    NotificationView()
}
