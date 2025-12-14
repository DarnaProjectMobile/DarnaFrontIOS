//
//  VisitReviewSheet.swift
//  DarnaApp
//
//  Modern, Clean & Static Design
//

import SwiftUI

struct VisitReviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: VisitViewModel
    private let visit: Visit
    
    @State private var draft: VisitReviewDraft
    @State private var isSubmitting = false
    
    init(viewModel: VisitViewModel, visit: Visit) {
        self.viewModel = viewModel
        self.visit = visit
        _draft = State(initialValue: VisitReviewDraft(visit: visit))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Static Background
                Color(red: 0.98, green: 0.98, blue: 0.99)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        premiumHeader
                            .padding(.top, 20)
                        
                        // Visit Info Card
                        visitInfoCard
                            .padding(.horizontal)
                        
                        // Rating Sections
                        VStack(spacing: 16) {
                            modernRatingSection(
                                title: "Accueil du colocataire",
                                icon: "person.fill",
                                colors: [.blue, .purple],
                                value: $draft.collector
                            )
                            
                            modernRatingSection(
                                title: "Propreté",
                                icon: "sparkles",
                                colors: [.green, .teal],
                                value: $draft.cleanliness
                            )
                            
                            modernRatingSection(
                                title: "Emplacement",
                                icon: "location.fill",
                                colors: [.orange, .red],
                                value: $draft.location
                            )
                            
                            modernRatingSection(
                                title: "Conformité",
                                icon: "checkmark.seal.fill",
                                colors: [.purple, .pink],
                                value: $draft.conformity
                            )
                        }
                        .padding(.horizontal)
                        
                        // Comment Section
                        commentSection
                            .padding(.horizontal)
                        
                        // Submit Button
                        submitButton
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Fermer")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Premium Header
    private var premiumHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: Color.orange.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text("Évaluer la visite")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.2),
                            Color(red: 0.2, green: 0.2, blue: 0.3)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Partagez votre expérience")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Visit Info Card
    private var visitInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "house.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("LOGEMENT")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(visit.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(visit.formattedDate)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
    }
    
    // MARK: - Modern Rating Section
    private func modernRatingSection(
        title: String,
        icon: String,
        colors: [Color],
        value: Binding<Int>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(colors[0].opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Interactive Stars (No Animation)
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        value.wrappedValue = star
                    } label: {
                        Image(systemName: star <= value.wrappedValue ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                star <= value.wrappedValue ?
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [.gray.opacity(0.3), .gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Comment Section
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                
                Text("Commentaire (optionnel)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            ZStack(alignment: .topLeading) {
                if draft.comment.isEmpty {
                    Text("Partagez votre expérience en détail...")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $draft.comment)
                    .font(.system(size: 15))
                    .frame(height: 120)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Alerts State
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    
    // ... inside body ...
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            Task {
                isSubmitting = true
                await viewModel.submitReview(draft: draft)
                isSubmitting = false
                
                if viewModel.errorMessage != nil {
                    showErrorAlert = true
                } else {
                    showSuccessAlert = true
                }
            }
        } label: {
            HStack(spacing: 12) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                    Text("Envoyer l'évaluation")
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color.yellow, Color.orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.orange.opacity(0.4), radius: 20, x: 0, y: 10)
        }
        .disabled(isSubmitting)
        .alert("Évaluation envoyée", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Votre évaluation a été ajoutée avec succès.")
        }
        .alert("Erreur", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Une erreur est survenue.")
        }
    }
}

