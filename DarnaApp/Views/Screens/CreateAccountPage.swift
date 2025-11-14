//
//  CreateAccountPage.swift
//  DarnaApp
//

import SwiftUI

struct CreateAccountPage: View {
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Form Fields
    @State private var fullName = ""
    @State private var birthDate = ""
    @State private var email = ""
    @State private var phoneNumber = "+216"
    @State private var selectedGender = ""
    @State private var password = ""
    @State private var showPassword = false
    
    @State private var navigateToScanner = false
    @State private var showValidationErrors = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    let genders = ["Femme", "Homme"]
    
    // MARK: - Validation
    var isFullNameValid: Bool { fullName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 }
    var isBirthDateValid: Bool { !birthDate.isEmpty }
    var isEmailValid: Bool {
        let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    var isPhoneValid: Bool { phoneNumber.hasPrefix("+216") && phoneNumber.count == 12 }
    var isGenderValid: Bool { !selectedGender.isEmpty }
    var isPasswordValid: Bool { password.count >= 6 }
    var isFormValid: Bool {
        isFullNameValid && isBirthDateValid && isEmailValid && isPhoneValid && isGenderValid && isPasswordValid
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.96, blue: 0.98)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        VStack(spacing: 24) {
                            
                            // MARK: Header
                            VStack(spacing: 16) {
                                ZStack {
                                    LinearGradient(
                                        colors: [Color(red: 0.4, green: 0.7, blue: 1.0),
                                                 Color(red: 0.4, green: 0.9, blue: 0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                }
                                
                                Text("Créer votre compte")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text("Remplissez vos informations pour commencer")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 30)
                            
                            // MARK: - Form Fields
                            VStack(spacing: 20) {
                                InputField(label: "Nom complet", icon: "person.fill", text: $fullName,
                                           placeholder: "Entrez votre nom complet",
                                           isValid: isFullNameValid || !showValidationErrors,
                                           errorMessage: "Nom trop court (min. 3 caractères)")
                                
                                InputField(label: "Date de naissance", icon: "calendar", text: $birthDate,
                                           placeholder: "JJ/MM/AAAA",
                                           isValid: isBirthDateValid || !showValidationErrors,
                                           errorMessage: "Veuillez entrer une date")
                                
                                InputField(label: "Email", icon: "envelope.fill", text: $email,
                                           placeholder: "exemple@email.com",
                                           keyboardType: .emailAddress,
                                           isValid: isEmailValid || !showValidationErrors,
                                           errorMessage: "Email invalide")
                                
                                InputField(label: "Numéro de téléphone", icon: "phone.fill", text: $phoneNumber,
                                           placeholder: "+216XXXXXXXX",
                                           keyboardType: .phonePad,
                                           isValid: isPhoneValid || !showValidationErrors,
                                           errorMessage: "Numéro invalide (+216 + 8 chiffres)")
                                
                                // Password Field
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Mot de passe")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    HStack {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(AppTheme.textSecondary)
                                            .frame(width: 20)
                                        
                                        if showPassword {
                                            TextField("Entrez votre mot de passe", text: $password)
                                        } else {
                                            SecureField("Entrez votre mot de passe", text: $password)
                                        }
                                        
                                        Button {
                                            showPassword.toggle()
                                        } label: {
                                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isPasswordValid || !showValidationErrors ? Color.clear : Color.red, lineWidth: 1)
                                    )
                                    
                                    if !isPasswordValid && showValidationErrors {
                                        Text("Mot de passe trop court (min. 6 caractères)")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                // Gender Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Genre")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Menu {
                                        ForEach(genders, id: \.self) { gender in
                                            Button(gender) { selectedGender = gender }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedGender.isEmpty ? "Sélectionnez" : selectedGender)
                                                .foregroundColor(selectedGender.isEmpty ? .gray : AppTheme.textPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(AppTheme.textSecondary)
                                                .font(.system(size: 12))
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                    
                                    if !isGenderValid && showValidationErrors {
                                        Text("Veuillez sélectionner un genre")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            
                            // MARK: - Create Account Button
                            Button {
                                Task {
                                    if isFormValid {
                                        isLoading = true
                                        errorMessage = nil
                                        do {
                                            let _ = try await NetworkService.shared.register(
                                                fullName: fullName,
                                                email: email,
                                                password: password,
                                                birthDate: birthDate,
                                                phoneNumber: phoneNumber.replacingOccurrences(of: "+216", with: ""),
                                                gender: selectedGender
                                            )
                                            print("✅ Compte créé avec succès")
                                            navigateToScanner = true
                                        } catch {
                                            if let netError = error as? NetworkError {
                                                errorMessage = netError.errorDescription
                                            } else {
                                                errorMessage = error.localizedDescription
                                            }
                                        }
                                        isLoading = false
                                    } else {
                                        showValidationErrors = true
                                    }
                                }
                            } label: {
                                if isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, minHeight: 56)
                                } else {
                                    HStack {
                                        Image(systemName: "person.crop.circle.badge.plus")
                                            .font(.system(size: 18))
                                        Text("Créer un compte")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        LinearGradient(
                                            colors: [AppTheme.primary, Color(red: 0.2, green: 0.8, blue: 0.4)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                            }
                            .disabled(isLoading)
                            .padding(.horizontal, 24)
                            .padding(.top, 10)
                            
                            // MARK: - Error Message
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // MARK: - Terms
                            Text("En continuant, vous acceptez nos conditions d'utilisation")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                        }
                        .background(Color.white)
                        .cornerRadius(24)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Retour")
                        }
                        .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToScanner) {
                ScannerPage()
            }
        }
    }
}

// MARK: - Input Field Component
struct InputField: View {
    var label: String
    var icon: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    var isValid: Bool = true
    var errorMessage: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 20)
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isValid ? Color.clear : Color.red, lineWidth: 1)
            )
            
            if !isValid {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
