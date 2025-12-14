//
//  MainAppView.swift
//  DarnaApp
//

import SwiftUI
import Combine

struct MainAppView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    @ObservedObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // 🏠 Home - Page d'accueil pour tous (Client & Colocataire)
            HomePage()
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
                .tag(0)
            
            // 📢 Publicités (Pour tous)
            PubliciteListView()
                .tabItem {
                    Label("Publicités", systemImage: "megaphone.fill")
                }
                .tag(1)
            
            // Pour les clients uniquement (Réservation)
            if let role = authManager.currentUser?.role?.lowercased(),
               !(role == "colocataire" || role == "collocator") {
                
                // 📅 Réserver (Client)
                VisitManagementView(initialSection: .reserve)
                    .tabItem {
                        Label("Réserver", systemImage: "calendar")
                    }
                    .tag(2)
            }
            
            // 👤 Profile (Commun)
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onReceive(NotificationCenter.default.publisher(for: .shouldDismissMainApp)) { _ in
            dismiss()
        }
    }
}
