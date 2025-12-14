//
//  MockPaymentSheet.swift
//  DarnaApp
//
//  Interface simulée de paiement (sans dépendance Stripe)
//

import SwiftUI

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

#Preview {
    MockPaymentSheet(amount: "10 TND", onComplete: {
        print("Payment completed!")
    })
}
