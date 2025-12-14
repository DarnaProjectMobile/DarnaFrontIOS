import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Onglet Accueil
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Accueil", systemImage: "house.fill")
            }
            .tag(0)
            
            // Onglet Visites
            NavigationView {
                if let userId = authManager.currentUser?.id {
                    VisitListView(
                        userType: authManager.currentUser?.role ?? .client,
                        userId: userId
                    )
                } else {
                    Text("Chargement...")
                }
            }
            .tabItem {
                Label("Visites", systemImage: "calendar")
            }
            .tag(1)
            
            // Onglet Publicités
            NavigationView {
                PubliciteListView()
            }
            .tabItem {
                Label("Publicités", systemImage: "megaphone.fill")
            }
            .tag(2)
            
            // Onglet Profil
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
            .tag(3)
        }
        .accentColor(.blue)
    }
}

// MARK: - Vues des onglets

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // En-tête
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bienvenue")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Gérez vos visites facilement")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Bouton de notification
                    Button(action: {
                        // Action pour les notifications
                    }) {
                        Image(systemName: "bell.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .overlay(
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 5, y: -5),
                                alignment: .topTrailing
                            )
                    }
                }
                .padding()
                
                // Section des statistiques
                VStack(alignment: .leading, spacing: 15) {
                    Text("Aperçu")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        StatCard(
                            title: "Visites à venir",
                            value: "5",
                            icon: "calendar.badge.clock",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "En attente",
                            value: "2",
                            icon: "clock.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        StatCard(
                            title: "Terminées",
                            value: "12",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Annulées",
                            value: "1",
                            icon: "xmark.circle.fill",
                            color: .red
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Actions rapides
                VStack(alignment: .leading, spacing: 15) {
                    Text("Actions rapides")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        ActionButton(
                            title: "Nouvelle visite",
                            icon: "plus.circle.fill",
                            color: .blue
                        ) {
                            // Action pour ajouter une visite
                        }
                        
                        ActionButton(
                            title: "Scanner QR",
                            icon: "qrcode.viewfinder",
                            color: .green
                        ) {
                            // Action pour scanner un QR code
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Accueil")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Composants

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(10)
        }
    }
}

// MARK: - Preview

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthManager.shared)
    }
}
