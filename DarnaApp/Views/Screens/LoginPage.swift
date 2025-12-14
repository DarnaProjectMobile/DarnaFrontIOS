//
//  LoginPage.swift
//  DarnaApp
//

import SwiftUI

struct LoginPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var rememberMe = false
    @State private var navigateToRegister = false
    @State private var navigateToMainApp = false
   
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showErrorAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
               
                VStack(spacing: 0) {
                    // MARK: - Logo and App Name
                    VStack(spacing: 12) {
                        Image("att.nSAoTaQL2jEs-WGWDx7oFOQ7lJ86N_j3nid3TQe9SOQ")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                   
                    // MARK: - Welcome Message
                    Text("Welcome to Darna")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.bottom, 40)
                   
                    // MARK: - Input Fields
                    VStack(spacing: 20) {
                        // Email
                        TextField("Email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                       
                        // Password
                        HStack {
                            if showPassword {
                                TextField("Password", text: $password)
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            Button {
                                showPassword.toggle()
                            } label: {
                                Text(showPassword ? "Hide" : "Show")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                   
                    // MARK: - Remember Me + Forgot Password
                    HStack {
                        Button {
                            rememberMe.toggle()
                            // Clear credentials if user unchecks "Remember Me"
                            if !rememberMe {
                                KeychainHelper.shared.clearCredentials()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                    .foregroundColor(rememberMe ? AppTheme.primary : AppTheme.textSecondary)
                                Text("Remember Me")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        }
                       
                        Spacer()
                       
                        Button {
                            // TODO: Forgot password action
                        } label: {
                            Text("Forgot password?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                   
                    // MARK: - Sign In Button
                    Button {
                        Task {
                            await handleLogin()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppTheme.primary)
                                .cornerRadius(12)
                        } else {
                            Text("Sign In")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppTheme.primary)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                   
                    // MARK: - Register
                    HStack(spacing: 4) {
                        Text("Don't Have An Account?")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                       
                        Button {
                            navigateToRegister = true
                        } label: {
                            Text("Register Now")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                   
                    Spacer()
                }
                // MARK: - Error Alert
                .alert(isPresented: $showErrorAlert) {
                    Alert(
                        title: Text("Login Failed"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                CreateAccountPage()
            }
            .fullScreenCover(isPresented: $navigateToMainApp) {
                MainAppView()
            }
            .onAppear {
                loadSavedCredentials()
            }
        }
    }
   
    // MARK: - Handle Login Logic
    @MainActor
    private func handleLogin() async {
        // Basic validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            showErrorAlert = true
            return
        }
       
        isLoading = true
        defer { isLoading = false }
       
        do {
            let response = try await NetworkService.shared.login(email: email, password: password)
            print("✅ Login successful for:", response.user.username)
           
            // Save credentials if "Remember Me" is checked
            if rememberMe {
                KeychainHelper.shared.saveCredentials(email: email, password: password)
            } else {
                // Clear credentials if "Remember Me" is unchecked
                KeychainHelper.shared.clearCredentials()
            }
           
            // Navigate if successful
            navigateToMainApp = true
           
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        } catch {
            errorMessage = "An unknown error occurred. Please try again."
            showErrorAlert = true
        }
    }
    
    // MARK: - Load Saved Credentials
    private func loadSavedCredentials() {
        let credentials = KeychainHelper.shared.loadCredentials()
        
        if let savedEmail = credentials.email {
            email = savedEmail
            rememberMe = true
        }
        
        if let savedPassword = credentials.password {
            password = savedPassword
        }
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}
