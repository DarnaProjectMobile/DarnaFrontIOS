import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingLogoutAlert = false
    
    var body: some View {
        List {
            // Section d'en-tête avec les informations de l'utilisateur
            Section {
                HStack(spacing: 16) {
                    // Avatar de l'utilisateur
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        Text(authManager.currentUser?.name.prefix(1).uppercased() ?? "U")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authManager.currentUser?.name ?? "Utilisateur")
                            .font(.headline)
                        
                        Text(authManager.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let role = authManager.currentUser?.role {
                            Text(role.rawValue.capitalized)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(role == .collector ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2))
                                .foregroundColor(role == .collector ? .orange : .blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Section des paramètres
            Section(header: Text("COMPTE")) {
                NavigationLink(destination: EditProfileView()) {
                    ProfileRow(icon: "person.fill", title: "Modifier le profil", color: .blue)
                }
                
                if authManager.currentUser?.role == .collector {
                    NavigationLink(destination: AvailabilityView()) {
                        ProfileRow(icon: "calendar", title: "Disponibilités", color: .green)
                    }
                }
                
                NavigationLink(destination: NotificationsView()) {
                    ProfileRow(icon: "bell.fill", title: "Notifications", color: .purple)
                }
                
                NavigationLink(destination: SecurityView()) {
                    ProfileRow(icon: "lock.fill", title: "Sécurité", color: .orange)
                }
            }
            
            // Section d'aide
            Section(header: Text("AIDE")) {
                NavigationLink(destination: HelpCenterView()) {
                    ProfileRow(icon: "questionmark.circle.fill", title: "Centre d'aide", color: .gray)
                }
                
                NavigationLink(destination: ContactSupportView()) {
                    ProfileRow(icon: "envelope.fill", title: "Contacter le support", color: .blue)
                }
                
                Button(action: {
                    // Action pour évaluer l'application
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(YOUR_APP_ID)?action=write-review") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    ProfileRow(icon: "star.fill", title: "Évaluer l'application", color: .yellow)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Section à propos
            Section {
                NavigationLink(destination: AboutView()) {
                    ProfileRow(icon: "info.circle.fill", title: "À propos", color: .gray)
                }
                
                NavigationLink(destination: LegalView()) {
                    ProfileRow(icon: "doc.text.fill", title: "Mentions légales", color: .gray)
                }
            }
            
            // Bouton de déconnexion
            Section {
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    HStack {
                        Spacer()
                        Text("Se déconnecter")
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Se déconnecter"),
                    message: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
                    primaryButton: .destructive(Text("Déconnexion")) {
                        authManager.logout()
                    },
                    secondaryButton: .cancel()
                )
            }
            
            // Version de l'application
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Darna App")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            Text("Version \(version)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadUserData()
        }
    }
}

// MARK: - Composants

struct ProfileRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
                .background(color.opacity(0.2))
                .cornerRadius(6)
                .padding(4)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color(.systemGray3))
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ViewModel

class ProfileViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadUserData() {
        // Charger les données supplémentaires de l'utilisateur si nécessaire
    }
}

// MARK: - Vues liées au profil

struct EditProfileView: View {
    var body: some View {
        Text("Modifier le profil")
            .navigationTitle("Modifier le profil")
    }
}

struct AvailabilityView: View {
    var body: some View {
        Text("Gérer les disponibilités")
            .navigationTitle("Disponibilités")
    }
}

struct NotificationsView: View {
    var body: some View {
        Text("Paramètres de notification")
            .navigationTitle("Notifications")
    }
}

struct SecurityView: View {
    var body: some View {
        Text("Paramètres de sécurité")
            .navigationTitle("Sécurité")
    }
}

struct HelpCenterView: View {
    var body: some View {
        Text("Centre d'aide")
            .navigationTitle("Aide")
    }
}

struct ContactSupportView: View {
    var body: some View {
        Text("Contacter le support")
            .navigationTitle("Support")
    }
}

struct AboutView: View {
    var body: some View {
        Text("À propos de l'application")
            .navigationTitle("À propos")
    }
}

struct LegalView: View {
    var body: some View {
        Text("Mentions légales")
            .navigationTitle("Mentions légales")
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthManager.shared
        authManager.login(
            token: "mock_token",
            user: User(
                id: "1",
                email: "test@example.com",
                name: "John Doe",
                role: .collector,
                phoneNumber: "0612345678"
            )
        )
        
        return NavigationView {
            ProfileView()
                .environmentObject(authManager)
        }
    }
}
