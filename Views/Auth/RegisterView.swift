import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // En-tête
                    VStack(spacing: 10) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Créer un compte")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 30)
                    
                    // Formulaire d'inscription
                    VStack(spacing: 15) {
                        // Nom complet
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Nom complet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Jean Dupont", text: $viewModel.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                        }
                        
                        // Email
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
                        
                        // Téléphone (optionnel)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Téléphone (optionnel)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("06 12 34 56 78", text: $viewModel.phoneNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.phonePad)
                        }
                        
                        // Mot de passe
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Mot de passe")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            SecureField("••••••••", text: $viewModel.password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Minimum 8 caractères")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Confirmation mot de passe
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Confirmer le mot de passe")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            SecureField("••••••••", text: $viewModel.confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Type de compte
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Je suis")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Picker("Type de compte", selection: $viewModel.userType) {
                                Text("Client").tag(UserType.client)
                                Text("Collecteur").tag(UserType.collector)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(.vertical, 5)
                        
                        // Bouton d'inscription
                        Button(action: {
                            viewModel.register()
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            } else {
                                Text("S'inscrire")
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
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Inscription", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Annuler") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.isSuccess ? "Succès" : "Erreur"),
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
class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var userType: UserType = .client
    
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var isSuccess = false
    @Published var errorMessage: String?
    
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()
    
    func register() {
        // Validation des champs
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Veuillez remplir tous les champs obligatoires"
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Les mots de passe ne correspondent pas"
            showAlert = true
            return
        }
        
        guard password.count >= 8 else {
            errorMessage = "Le mot de passe doit contenir au moins 8 caractères"
            showAlert = true
            return
        }
        
        isLoading = true
        
        let registerRequest = RegisterRequest(
            name: name,
            email: email,
            password: password,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            role: userType
        )
        
        authService.register(user: registerRequest)
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
                    self?.errorMessage = "Votre compte a été créé avec succès !"
                    self?.showAlert = true
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Preview
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
