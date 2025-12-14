//
//  ModernHeaderView.swift
//  DarnaApp
//
//  Header moderne avec menu hamburger, titre et notifications
//

import SwiftUI

struct ModernHeaderView: View {
    let title: String
    var onMenuTap: () -> Void = {}
    var onNotificationTap: () -> Void = {}
    
    var body: some View {
        HStack {
            // Menu hamburger
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Titre
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Notifications
            Button(action: onNotificationTap) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.title3)
                        .foregroundColor(.primary)
                    
                    // Badge de notification (optionnel)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -4)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ModernHeaderView(title: "Offres Étudiantes")
}
