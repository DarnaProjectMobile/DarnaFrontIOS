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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // 🏠 Home
            HomePage()
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
                .tag(0)
            
            // 📢 Publicités
            PubliciteListView()
                .tabItem {
                    Label("Publicités", systemImage: "megaphone.fill")
                }
                .tag(1)
            
            // 📅 Visits
          //  VisitManagementView()
           //     .tabItem {
           //         Label("Visites", systemImage: "calendar")
           //     }
           //     .tag(2)
            
            // 👤 Profile
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
