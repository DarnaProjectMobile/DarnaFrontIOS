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
            
            // 🏠 Home - Conditionnel selon le rôle
            if let role = authManager.currentUser?.role?.lowercased(), 
               (role == "colocataire" || role == "collocator") {
                
                // Tableau de bord Colocataire
                CollocatorDashboardView()
                    .tabItem {
                        Label("Accueil", systemImage: "house.fill")
                    }
                    .tag(0)
            } else {
                // Page d'accueil Client (recherche d'annonces)
                HomePage()
                    .tabItem {
                        Label("Accueil", systemImage: "house.fill")
                    }
                    .tag(0)
            }
            
            // Pour les clients uniquement
            if let role = authManager.currentUser?.role?.lowercased(),
               !(role == "colocataire" || role == "collocator") {
                
                // 📢 Publicités (Client)
                PubliciteListView()
                    .tabItem {
                        Label("Publicités", systemImage: "megaphone.fill")
                    }
                    .tag(1)
                
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
