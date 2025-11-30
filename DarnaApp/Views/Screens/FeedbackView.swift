//
//  FeedbackView.swift
//  DarnaApp
//
//  Created by Qoder Assistant on 30/11/2025.
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var reason = ""
    @State private var details = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    // Predefined reasons for feedback
    let feedbackReasons = [
        "Problème technique",
        "Contenu inapproprié",
        "Suggestions d'amélioration",
        "Problème de navigation",
        "Autre"
    ]
    
    var body: some View {
        Form {
                Section(header: Text("Raison du feedback")) {
                    Picker("Raison", selection: $reason) {
                        Text("Sélectionnez une raison").tag("")
                        ForEach(feedbackReasons, id: \.self) { reason in
                            Text(reason).tag(reason)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Détails")) {
                    TextEditor(text: $details)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.vertical, 4)
                }
                
                Section {
                    Button(action: submitFeedback) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text("Envoyer le feedback")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(reason.isEmpty || details.isEmpty || isLoading)
                }
            }
            .navigationTitle("Envoyer un feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") {
                    if alertTitle == "Succès" {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func submitFeedback() {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                try await FeedbackService.shared.sendFeedback(reason: reason, details: details)
                await MainActor.run {
                    isLoading = false
                    alertTitle = "Succès"
                    alertMessage = "Votre feedback a été envoyé avec succès. Merci pour votre contribution !"
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertTitle = "Erreur"
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}