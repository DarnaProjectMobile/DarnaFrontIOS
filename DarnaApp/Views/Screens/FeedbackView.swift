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
    @State private var feedbacks: [Feedback] = []
    @State private var isLoadingFeedbacks = true
    
    // Predefined reasons for feedback
    let feedbackReasons = [
        "Problème technique",
        "Contenu inapproprié",
        "Suggestions d'amélioration",
        "Problème de navigation",
        "Autre"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // MARK: - Feedback Form
                Form {
                    Section(header: Text("Raison du feedback").font(.caption).textCase(nil)) {
                        Picker("Raison", selection: $reason) {
                            Text("Sélectionnez une raison").tag("")
                            ForEach(feedbackReasons, id: \.self) { reason in
                                Text(reason).tag(reason)
                            }
                        }
                        .pickerStyle(.navigationLink) // Modern picker style
                    }
                    
                    Section(header: Text("Détails").font(.caption).textCase(nil)) {
                        TextEditor(text: $details)
                            .frame(height: 100)
                            .multilineTextAlignment(.leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
                            .padding(.vertical, 4)
                    }
                }
                // Retiré le .frame(height: 350) pour un layout dynamique
                
                
                // MARK: - Feedbacks List Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mes feedbacks")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .animation(nil) // Désactiver l'animation sur ce texte
                    
                    if isLoadingFeedbacks {
                        HStack {
                            Spacer()
                            ProgressView("Chargement...")
                                .progressViewStyle(.circular)
                            Spacer()
                        }
                        .padding()
                        .frame(height: 100)
                    } else if feedbacks.isEmpty {
                        Text("Aucun feedback pour le moment")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(feedbacks) { feedback in
                                    FeedbackCard(feedback: feedback)
                                        .transition(.slide)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, geometry.safeAreaInsets.bottom + 80) // Espace pour le bouton
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .frame(maxHeight: .infinity) // Prend l'espace restant
                
                // MARK: - Submit Button
                Button(action: submitFeedback) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        }
                        Text("Envoyer le feedback")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(buttonBackgroundColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 10) // Ajustement pour la barre d'accueil
                .buttonStyle(.plain) // Retire le style par défaut dans le Form
                .disabled(reason.isEmpty || details.isEmpty || isLoading)
                .background(Color(.systemGroupedBackground)) // Assure que le fond du bouton est cohérent
            }
            .animation(.easeInOut(duration: 0.3), value: isLoadingFeedbacks) // Animation sur la liste
            .animation(.spring(), value: isLoading) // Animation sur le bouton de chargement
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
                    // Clear form but don't dismiss
                    reason = ""
                    details = ""
                }
            }
        } message: {
            Text(alertMessage)
        }
        .task {
            await loadFeedbacks()
        }
    }
    
    // MARK: - Computed Properties
    private var buttonBackgroundColor: Color {
        return (reason.isEmpty || details.isEmpty || isLoading) ? Color.gray : Color.blue
    }
    
    // MARK: - Functions (NOT TOUCHED)
    private func submitFeedback() {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let newFeedback = try await FeedbackService.shared.sendFeedback(reason: reason, details: details)
                await MainActor.run {
                    isLoading = false
                    alertTitle = "Succès"
                    alertMessage = "Votre feedback a été envoyé avec succès. Merci pour votre contribution !"
                    showAlert = true
                    // Add new feedback to the beginning of the list
                    feedbacks.insert(newFeedback, at: 0)
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
    
    private func loadFeedbacks() async {
        do {
            let loadedFeedbacks = try await FeedbackService.shared.fetchUserFeedbacks()
            await MainActor.run {
                feedbacks = loadedFeedbacks.sorted {
                    // Handle optional createdAt values safely
                    guard let date1 = $0.createdAt, let date2 = $1.createdAt else {
                        // If either date is missing, sort by ID or put newer items first
                        return $0.id > $1.id
                    }
                    return date1 > date2
                }
                isLoadingFeedbacks = false
            }
        } catch {
            await MainActor.run {
                isLoadingFeedbacks = false
                print("❌ Erreur lors du chargement des feedbacks: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Feedback Card Component
struct FeedbackCard: View {
    let feedback: Feedback
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(feedback.reason ?? "Pas de raison")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Resolution Status Badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(feedback.isResolved ?? false ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(feedback.isResolved ?? false ? "Résolu" : "En attente")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(feedback.isResolved ?? false ? .green : .orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(feedback.isResolved ?? false ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                )
            }
            
            Text(feedback.details ?? "Pas de détails")
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            if let createdAt = feedback.createdAt {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text(formatDate(createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: dateString) else {
            return dateString
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

// MARK: - Preview
// NOTE: Vous devez définir la structure `Feedback` et la classe `FeedbackService`
// pour que la Preview fonctionne correctement dans un environnement de projet réel.
struct FeedbackView_Previews: PreviewProvider {
    // Structure factice pour la Preview si non définie ailleurs
    struct MockFeedback: Identifiable, Codable {
        let id: String
        let reason: String?
        let details: String?
        let isResolved: Bool?
        let createdAt: String?
    }
    
    static var previews: some View {
        NavigationView {
            FeedbackView()
        }
    }
}
