//
//  DarnaAppApp.swift
//  DarnaApp
//
//  Created by Apple Esprit on 6/11/2025.
//

import SwiftUI

@main
struct DarnaAppApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Demander l'autorisation pour les notifications
        NotificationService.shared.requestAuthorization()
        
        // Configurer Stripe
        StripeConfig.configureIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginPage()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
