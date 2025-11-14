//
//  VisitEvaluationView.swift
//  DarnaApp
//

import SwiftUI

struct VisitEvaluationView: View {
    @Environment(\.dismiss) var dismiss
    let visit: VisitModel
    @ObservedObject var visitStore: VisitStore
    
    @State private var rating: Int = 0
    @State private var review: String = ""
    @State private var hoveredStar: Int = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 20) {
                        Text("Comment s'est passée la visite?")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        // Star Rating
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { index in
                                Button {
                                    rating = index
                                } label: {
                                    Image(systemName: index <= rating ? "star.fill" : "star")
                                        .font(.system(size: 40))
                                        .foregroundColor(index <= rating ? .yellow : .gray.opacity(0.3))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Section("Votre avis (optionnel)") {
                    TextEditor(text: $review)
                        .frame(height: 150)
                }
                
                Section {
                    Button {
                        submitEvaluation()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Soumettre l'évaluation")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(rating == 0)
                }
            }
            .navigationTitle("Évaluer la visite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func submitEvaluation() {
        var updatedVisit = visit
        updatedVisit.rating = rating
        updatedVisit.review = review.isEmpty ? nil : review
        updatedVisit.status = .completed
        visitStore.update(updatedVisit)
        dismiss()
    }
}

