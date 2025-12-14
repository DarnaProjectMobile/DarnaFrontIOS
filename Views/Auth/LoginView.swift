import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // En-tête
                VStack(spacing: 10) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Darna App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Connectez-vous pour continuer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                .padding(.bottom, 30)
                
                // Formulaire de connexion
                VStack(spacing: 15) {
                    // Champ email
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("votre@email.com", text: $viewModel.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // Champ mot de passe
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Mot de passe")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        SecureField("••••••••", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Bouton de connexion
                    Button(action: {
                        viewModel.login()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        } else {
                            Text("Se connecter")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.top, 10)
                    
                    // Lien mot de passe oublié
                    Button(action: {
                        // Action pour réinitialiser le mot de passe
                        viewModel.showResetPassword = true
                    }) {
                        Text("Mot de passe oublié ?")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $viewModel.showResetPassword) {
                        ResetPasswordView()
                    }
                    .padding(.top, 5)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Lien vers l'inscription
                HStack {
                    Text("Vous n'avez pas de compte ?")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    NavigationLink(destination: RegisterView()) {
                        Text("S'inscrire")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 30)
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Erreur"),
                    message: Text(viewModel.errorMessage ?? "Une erreur inconnue est survenue"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - ViewModel
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var showResetPassword = false
    @Published var errorMessage: String?
    
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Veuillez remplir tous les champs"
            showAlert = true
            return
        }
        
        isLoading = true
        
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showAlert = true
                    }
                },
                receiveValue: { _ in
                    // La connexion réussie est gérée par le AuthManager
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthManager.shared)
    }
}
