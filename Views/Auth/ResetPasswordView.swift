import SwiftUI

struct ResetPasswordView: View {
    @StateObject private var viewModel = ResetPasswordViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // En-tête
                VStack(spacing: 10) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Réinitialisation du mot de passe")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Entrez votre email pour recevoir un lien de réinitialisation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
                
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
                .padding(.horizontal, 25)
                .padding(.top, 20)
                
                // Bouton de réinitialisation
                Button(action: {
                    viewModel.resetPassword()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    } else {
                        Text("Envoyer le lien de réinitialisation")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 25)
                .padding(.top, 20)
                
                Spacer()
                
                // Lien de retour à la connexion
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Retour à la connexion")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitle("Mot de passe oublié", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Annuler") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.isSuccess ? "Email envoyé" : "Erreur"),
                    message: Text(viewModel.errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) {
                        if viewModel.isSuccess {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }
}

// MARK: - ViewModel
class ResetPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var isSuccess = false
    @Published var errorMessage: String?
    
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()
    
    func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Veuillez entrer votre adresse email"
            showAlert = true
            return
        }
        
        // Validation basique de l'email
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "Veuillez entrer une adresse email valide"
            showAlert = true
            return
        }
        
        isLoading = true
        
        authService.resetPassword(email: email)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.isSuccess = false
                        self?.showAlert = true
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.isSuccess = true
                    self?.errorMessage = "Un email de réinitialisation a été envoyé à \(self?.email ?? "votre adresse email")."
                    self?.showAlert = true
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Preview
struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
