//
//  AddPubliciteView.swift
//  DarnaApp
//
//  Vue pour ajouter une nouvelle publicité avec popup de paiement

import SwiftUI
import PhotosUI
#if canImport(StripePaymentSheet)
import StripePaymentSheet
#endif

struct AddPubliciteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PubliciteViewModel
    @State private var showPaymentPopup = false
    @State private var showForm = false
    
    #if canImport(StripePaymentSheet)
    @State private var paymentSheet: PaymentSheet?
    @State private var showStripeSheet = false
    @State private var isLoadingPayment = false
    @State private var paymentErrorMessage: String?
    #else
    // Mock payment (sans Stripe)
    @State private var showMockPayment = false
    #endif
    
    var body: some View {
        ZStack {
            if showForm {
                PubliciteFormView(viewModel: viewModel)
            } else {
                paymentPopupView
            }
        }
        .onAppear {
            // Afficher le popup de paiement pour tout le monde
            showPaymentPopup = true
            #if canImport(StripePaymentSheet)
            preparePayment()
            #endif
        }
        #if canImport(StripePaymentSheet)
        .paymentSheet(isPresented: $showStripeSheet, paymentSheet: paymentSheet ?? PaymentSheet(paymentIntentClientSecret: "", configuration: PaymentSheet.Configuration()), onCompletion: onPaymentCompletion)
        #else
        .sheet(isPresented: $showMockPayment) {
            MockPaymentSheet(amount: "10 TND") {
                withAnimation {
                    showPaymentPopup = false
                    showForm = true
                }
            }
        }
        #endif
    }
    
    private var paymentPopupView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 24) {
                // Icône Stripe
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primary)
                
                Text("Paiement requis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Pour publier une publicité, un paiement de 10 TND est requis.")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Détails du paiement
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Montant:")
                        Spacer()
                        Text("10 TND")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(AppTheme.textPrimary)
                    
                    Divider()
                    
                    HStack {
                        Text("Méthode:")
                        Spacer()
                        HStack {
                            Image(systemName: "creditcard")
                            Text("Carte bancaire")
                        }
                        .foregroundColor(AppTheme.primary)
                    }
                    .foregroundColor(AppTheme.textPrimary)
                }
                .padding()
                .background(AppTheme.card)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Boutons
                VStack(spacing: 12) {
                    Button {
                        #if canImport(StripePaymentSheet)
                        if paymentSheet != nil {
                            showStripeSheet = true
                        } else {
                            preparePayment()
                        }
                        #else
                        // Afficher l'interface de paiement simulée
                        showMockPayment = true
                        #endif
                    } label: {
                        HStack {
                            #if canImport(StripePaymentSheet)
                            if isLoadingPayment {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "lock.fill")
                                Text("Payer avec Stripe")
                            }
                            #else
                            Image(systemName: "lock.fill")
                            Text("Payer avec Stripe")
                            #endif
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primary)
                        .cornerRadius(12)
                    }
                    
                    #if canImport(StripePaymentSheet)
                    if let error = paymentErrorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    #endif
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Annuler")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(AppTheme.background)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding()
            
            Spacer()
        }
        .background(Color.black.opacity(0.3))
        .ignoresSafeArea()
    }
    
    #if canImport(StripePaymentSheet)
    private func preparePayment() {
        isLoadingPayment = true
        paymentErrorMessage = nil
        
        Task {
            do {
                // 10 TND = 10 EUR pour l'exemple (le backend gère la devise)
                let clientSecret = try await PaymentService.shared.createPaymentIntent(amount: 10)
                
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "Darna App"
                configuration.allowsDelayedPaymentMethods = true
                
                DispatchQueue.main.async {
                    self.paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
                    self.isLoadingPayment = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error loading payment sheet: \(error)")
                    self.paymentErrorMessage = "Erreur: \(error.localizedDescription)"
                    self.isLoadingPayment = false
                }
            }
        }
    }
    
    private func onPaymentCompletion(result: PaymentSheetResult) {
        switch result {
        case .completed:
            withAnimation {
                showPaymentPopup = false
                showForm = true
            }
        case .canceled:
            print("Payment canceled")
        case .failed(let error):
            paymentErrorMessage = error.localizedDescription
        }
    }
    #endif
}

// MARK: - Mock Payment Sheet (Interface simulée sans Stripe)
struct MockPaymentSheet: View {
    @Environment(\.dismiss) private var dismiss
    let amount: String
    let onComplete: () -> Void
    
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var cardHolder = ""
    @State private var isProcessing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppTheme.primary)
                        
                        Text("Paiement sécurisé")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(amount)
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(.top)
                    
                    // Formulaire de carte simulé
                    VStack(alignment: .leading, spacing: 20) {
                        // Numéro de carte
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Numéro de carte")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            HStack {
                                TextField("1234 5678 9012 3456", text: $cardNumber)
                                    .keyboardType(.numberPad)
                                    .onChange(of: cardNumber) { newValue in
                                        cardNumber = formatCardNumber(newValue)
                                    }
                                
                                Image(systemName: "creditcard")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        HStack(spacing: 16) {
                            // Date d'expiration
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Expiration")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                TextField("MM/AA", text: $expiryDate)
                                    .keyboardType(.numberPad)
                                    .onChange(of: expiryDate) { newValue in
                                        expiryDate = formatExpiry(newValue)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            
                            // CVV
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CVV")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                TextField("123", text: $cvv)
                                    .keyboardType(.numberPad)
                                    .onChange(of: cvv) { newValue in
                                        if newValue.count > 3 {
                                            cvv = String(newValue.prefix(3))
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Titulaire de la carte
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nom du titulaire")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextField("JEAN DUPONT", text: $cardHolder)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Informations de sécurité
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                        Text("Paiement sécurisé par Stripe")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Bouton de paiement
                    Button {
                        processPayment()
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Traitement en cours...")
                            } else {
                                Image(systemName: "lock.fill")
                                Text("Payer \(amount)")
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? AppTheme.primary : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isProcessing)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Paiement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        cardNumber.count >= 19 &&
        expiryDate.count == 5 &&
        cvv.count == 3 &&
        !cardHolder.isEmpty
    }
    
    private func processPayment() {
        isProcessing = true
        
        // Simuler un délai de traitement
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isProcessing = false
            onComplete()
            dismiss()
        }
    }
    
    private func formatCardNumber(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }
        let limitedDigits = String(digits.prefix(16))
        var formatted = ""
        
        for (index, char) in limitedDigits.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted.append(char)
        }
        
        return formatted
    }
    
    private func formatExpiry(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }
        let limitedDigits = String(digits.prefix(4))
        
        if limitedDigits.count <= 2 {
            return limitedDigits
        } else {
            let month = limitedDigits.prefix(2)
            let year = limitedDigits.dropFirst(2)
            return "\(month)/\(year)"
        }
    }
}
