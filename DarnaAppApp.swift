//
//  DarnaAppApp.swift
//  DarnaApp
//
//  Created by Apple Esprit on 6/11/2025.
//

import SwiftUI

@main
struct DarnaAppApp: App {
    @StateObject private var authManager = AuthManager.shared
    let persistenceController = PersistenceController.shared
    
    init() {
        // Configuration de l'interface utilisateur
        setupAppearance()
        
        // Désactiver les logs réseau en production
        #if DEBUG
        // Activer les logs réseau en mode debug
        URLSession.shared.configuration.waitsForConnectivity = true
        URLSession.shared.configuration.timeoutIntervalForRequest = 30
        URLSession.shared.configuration.timeoutIntervalForResource = 60
        #else
        // Désactiver les logs réseau en production
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        #endif
        
        // Demander l'autorisation pour les notifications
        NotificationService.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                // Vue principale de l'application
                MainTabView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(authManager)
            } else {
                // Vue de connexion si l'utilisateur n'est pas connecté
                LoginView()
                    .environmentObject(authManager)
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - Configuration de l'apparence
    private func setupAppearance() {
        // Configuration de la barre de navigation
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configuration de la barre d'onglets
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}
