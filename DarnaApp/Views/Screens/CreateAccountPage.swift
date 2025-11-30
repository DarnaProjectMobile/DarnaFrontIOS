//
//  CreateAccountPage.swift
//  DarnaApp
//

import SwiftUI

enum UserRole: String, CaseIterable {
    case client = "Client"
    case owner = "Collocator"
    case admin = "Sponsor"
    
    // Backend value mapping
    var backendValue: String {
        switch self {
        case .client: return "client"
        case .owner: return "collocator"
        case .admin: return "sponsor"
        }
    }
}

enum Gender: String, CaseIterable {
    case female = "Femme"
    case male = "Homme"
}

struct CreateAccountPage: View {
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Step 1: Username, Full Name, Role
    @State private var username = ""
    @State private var fullName = ""
    @State private var selectedRole: UserRole = .client
    
    // MARK: - Step 2: Email, Birth Date, Phone, Gender
    @State private var email = ""
    @State private var birthDate = Date()
    @State private var phoneNumber = "+216"
    @State private var selectedGender: Gender = .male
    
    // MARK: - Step 3: Password
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    // MARK: - UI State
    @State private var currentStep = 1
    @State private var navigateToScanner = false
    @State private var showValidationErrors = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // MARK: - Validation
    var isUsernameValid: Bool { username.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 }
    var isFullNameValid: Bool { fullName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 }
    var isEmailValid: Bool {
        let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    var isPhoneValid: Bool { phoneNumber.hasPrefix("+216") && phoneNumber.count == 12 }
    var isPasswordValid: Bool { password.count >= 6 }
    var passwordsMatch: Bool { password == confirmPassword && !password.isEmpty }
    
    var passwordStrength: Double {
        var strength = 0.0
        if password.count >= 6 { strength += 0.25 }
        if password.count >= 10 { strength += 0.25 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil &&
           password.range(of: "[a-z]", options: .regularExpression) != nil { strength += 0.25 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { strength += 0.25 }
        return strength
    }
    
    var passwordStrengthColor: Color {
        if passwordStrength < 0.5 { return .red }
        else if passwordStrength < 0.75 { return .orange }
        else { return .green }
    }
    
    var passwordStrengthText: String {
        if passwordStrength < 0.5 { return "Faible" }
        else if passwordStrength < 0.75 { return "Moyen" }
        else { return "Fort" }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#4A90E2"), Color(hex: "#50E3C2")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                        .padding(.top, 50)
                    
                    // Progress Bar
                    progressBar
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            stepContent
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                        .padding(.bottom, 120)
                    }
                    
                    Spacer()
                    
                    // Navigation Buttons
                    navigationButtons
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToScanner) {
                ScannerPage()
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Créer un Compte")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text("Étape \(currentStep) sur 3")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(1...3, id: \.self) { step in
                RoundedRectangle(cornerRadius: 4)
                    .fill(step <= currentStep ? Color.white : Color.white.opacity(0.3))
                    .frame(height: 4)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private var stepContent: some View {
        Group {
            switch currentStep {
            case 1: step1View
            case 2: step2View
            case 3: step3View
            default: EmptyView()
            }
        }
        .id(currentStep)
    }
    
    // MARK: - Step 1: Username, Full Name, Role
    private var step1View: some View {
        VStack(spacing: 20) {
            Text("Informations de base")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            modernTextField(
                icon: "person.circle.fill",
                placeholder: "Nom d'utilisateur",
                text: $username
            )
            
            modernTextField(
                icon: "person.text.rectangle.fill",
                placeholder: "Nom complet",
                text: $fullName
            )
            
            // Role Selection
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "briefcase.fill")
                        .foregroundColor(.white)
                    Text("Rôle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 10) {
                    ForEach(UserRole.allCases, id: \.self) { role in
                        roleButton(role)
                    }
                }
            }
        }
    }
    
    private func roleButton(_ role: UserRole) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedRole = role
            }
        } label: {
            HStack {
                Image(systemName: selectedRole == role ? "checkmark.circle.fill" : "circle")
                Text(role.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            .foregroundColor(selectedRole == role ? Color(hex: "#4A90E2") : .gray)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedRole == role ? Color(hex: "#4A90E2") : Color.clear, lineWidth: 2)
            )
            .shadow(color: selectedRole == role ? Color(hex: "#4A90E2").opacity(0.3) : .clear, radius: 8, y: 4)
        }
    }
    
    // MARK: - Step 2: Email, Birth Date, Phone, Gender
    private var step2View: some View {
        VStack(spacing: 20) {
            Text("Informations personnelles")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            modernTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress
            )
            
            // Date Picker
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.white)
                    Text("Date de naissance")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .colorScheme(.light)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            }
            
            modernTextField(
                icon: "phone.fill",
                placeholder: "Téléphone (+216XXXXXXXX)",
                text: $phoneNumber,
                keyboardType: .phonePad
            )
            
            // Gender Selection
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.white)
                    Text("Genre")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 12) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        genderButton(gender)
                    }
                }
            }
        }
    }
    
    private func genderButton(_ gender: Gender) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedGender = gender
            }
        } label: {
            HStack {
                Image(systemName: gender == .male ? "person.fill" : "person.fill")
                Text(gender.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(selectedGender == gender ? .white : Color(hex: "#4A90E2"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                selectedGender == gender
                    ? LinearGradient(colors: [Color(hex: "#4A90E2"), Color(hex: "#50E3C2")],
                                     startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color.white, Color.white],
                                     startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
            .shadow(color: selectedGender == gender ? Color(hex: "#4A90E2").opacity(0.4) : .clear, radius: 8, y: 4)
        }
    }
    
    // MARK: - Step 3: Password
    private var step3View: some View {
        VStack(spacing: 20) {
            Text("Sécurité du compte")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            modernSecureField(
                icon: "lock.fill",
                placeholder: "Mot de passe",
                text: $password,
                showPassword: $showPassword
            )
            
            modernSecureField(
                icon: "lock.fill",
                placeholder: "Confirmer le mot de passe",
                text: $confirmPassword,
                showPassword: $showConfirmPassword
            )
            
            // Password Strength
            if !password.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Force du mot de passe")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(passwordStrengthColor)
                                .frame(width: geometry.size.width * passwordStrength, height: 6)
                                .animation(.spring(response: 0.3), value: password)
                        }
                    }
                    .frame(height: 6)
                    
                    Text(passwordStrengthText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(passwordStrengthColor)
                }
            }
            
            // Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 1 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        currentStep -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Précédent")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "#4A90E2"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                }
            }
            
            Button {
                handleNextOrSubmit()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(currentStep == 3 ? "Créer un Compte" : "Suivant")
                            .font(.system(size: 16, weight: .bold))
                        if currentStep < 3 {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF8E53")],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
                .shadow(color: Color(hex: "#FF6B6B").opacity(0.4), radius: 10, y: 5)
            }
            .disabled(isLoading)
        }
    }
    
    // MARK: - Handle Next/Submit
    private func handleNextOrSubmit() {
        if currentStep < 3 {
            if validateStep() {
                withAnimation(.spring(response: 0.3)) {
                    currentStep += 1
                }
            }
        } else {
            submitRegistration()
        }
    }
    
    private func validateStep() -> Bool {
        switch currentStep {
        case 1:
            if !isUsernameValid {
                errorMessage = "Le nom d'utilisateur doit contenir au moins 3 caractères."
                return false
            }
            if !isFullNameValid {
                errorMessage = "Le nom complet doit contenir au moins 3 caractères."
                return false
            }
            errorMessage = nil
            return true
            
        case 2:
            if !isEmailValid {
                errorMessage = "Veuillez entrer un email valide."
                return false
            }
            if !isPhoneValid {
                errorMessage = "Le numéro de téléphone doit être au format +216XXXXXXXX."
                return false
            }
            errorMessage = nil
            return true
            
        case 3:
            if !isPasswordValid {
                errorMessage = "Le mot de passe doit contenir au moins 6 caractères."
                return false
            }
            if !passwordsMatch {
                errorMessage = "Les mots de passe ne correspondent pas."
                return false
            }
            errorMessage = nil
            return true
            
        default:
            return false
        }
    }
    
    private func submitRegistration() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let birthDateString = dateFormatter.string(from: birthDate)
                
                let _ = try await NetworkService.shared.register(
                    username: username,
                    fullName: fullName,
                    email: email,
                    password: password,
                    birthDate: birthDateString,
                    phoneNumber: phoneNumber,
                    gender: selectedGender.rawValue,
                    role: selectedRole.backendValue
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
        }
    }
    
    // MARK: - Modern TextField
    private func modernTextField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#4A90E2"))
                .frame(width: 24)
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
    
    private func modernSecureField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        showPassword: Binding<Bool>
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#4A90E2"))
                .frame(width: 24)
            
            if showPassword.wrappedValue {
                TextField(placeholder, text: text)
            } else {
                SecureField(placeholder, text: text)
            }
            
            Button {
                showPassword.wrappedValue.toggle()
            } label: {
                Image(systemName: showPassword.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

