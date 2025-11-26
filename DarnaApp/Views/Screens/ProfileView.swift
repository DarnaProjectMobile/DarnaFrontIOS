//
//  ProfileView.swift
//  DarnaApp
//

import SwiftUI

struct ProfileView: View {
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var showLogoutAlert = false
    
    // Observe the current user from AuthenticationManager
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var favoritesManager = FavoritesManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - Header
                        VStack(spacing: 10) {
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                    .frame(height: 230)
                                    .overlay(
                                        VStack(spacing: 10) {
                                            // Profile image
                                            ZStack {
                                                Circle()
                                                    .strokeBorder(Color.gray.opacity(0.2), lineWidth: 2)
                                                    .background(Circle().fill(Color.white))
                                                    .frame(width: 90, height: 90)
                                                
                                                Image(systemName: "person.fill")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            // Display user's name and email dynamically
                                            Text(authManager.currentUser?.username ?? "Utilisateur")
                                                .font(.system(size: 22, weight: .bold))
                                                .foregroundColor(.black)
                                            
                                            Text(authManager.currentUser?.email ?? "email@exemple.com")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                            
                                            Button(action: { showEditProfile = true }) {
                                                Text("Modifier le profil")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 8)
                                                    .background(Color.blue.opacity(0.1))
                                                    .foregroundColor(.blue)
                                                    .cornerRadius(20)
                                            }
                                            .padding(.top, 4)
                                        }
                                    )
                                    .padding(.horizontal)
                                
                                Button(action: { showSettings = true }) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.gray)
                                        .padding(10)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                                .padding(.trailing, 40)
                                .padding(.top, 20)
                            }
                        }
                        .padding(.top, 10)
                        
                        // MARK: - Stats Row
                        HStack(spacing: 16) {
                            StatCard(icon: "house.fill", title: "Logements", value: "5")
                            
                            NavigationLink(destination: UserReviewsListView()) {
                                StatCard(icon: "star.fill", title: "Avis", value: "12")
                            }
                            
                            NavigationLink(destination: FavoritesView()) {
                                StatCard(icon: "heart.fill", title: "Favoris", value: "\(favoritesManager.getFavoritePropertyIds().count)")
                            }
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Reservations Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Gestion des réservations")
                            
                            NavigationLink(destination: MyReservationsView()) {
                                ProfileRow(icon: "clock.badge.questionmark", title: "Demandes en attente")
                            }
                            
                            NavigationLink(destination: AcceptedClientsView()) {
                                ProfileRow(icon: "person.crop.circle.badge.checkmark", title: "Clients acceptés")
                            }
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Account Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Mon compte")
                            
                            ProfileRow(icon: "person.crop.circle.fill", title: "Informations personnelles")
                            ProfileRow(icon: "creditcard.fill", title: "Moyens de paiement")
                            ProfileRow(icon: "lock.fill", title: "Sécurité du compte")
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Settings Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Paramètres")
                            
                            ProfileRow(icon: "bell.fill", title: "Notifications")
                            ProfileRow(icon: "globe", title: "Langue et région")
                            ProfileRow(icon: "moon.fill", title: "Mode sombre")
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Help Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Aide et support")
                            
                            ProfileRow(icon: "questionmark.circle.fill", title: "Centre d’aide")
                            ProfileRow(icon: "envelope.fill", title: "Nous contacter")
                            
                            Button {
                                showLogoutAlert = true
                            } label: {
                                ProfileRow(icon: "arrowshape.turn.up.left.fill", title: "Se déconnecter", isDestructive: true)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            
            // Logout confirmation alert
            .alert("Se déconnecter", isPresented: $showLogoutAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Déconnexion", role: .destructive) {
                    handleLogout()
                }
            } message: {
                Text("Voulez-vous vraiment vous déconnecter ?")
            }
        }
    }
    
    @MainActor
    private func handleLogout() {
        Task {
            AuthenticationManager.shared.signOut()
            // Post notification to dismiss MainAppView
            NotificationCenter.default.post(name: .shouldDismissMainApp, object: nil)
        }
    }
}

// MARK: - StatCard Component
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
            }
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.black)
            .padding(.bottom, 4)
    }
}

// MARK: - ProfileRow
struct ProfileRow: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : .blue)
            }
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(isDestructive ? .red : .black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
