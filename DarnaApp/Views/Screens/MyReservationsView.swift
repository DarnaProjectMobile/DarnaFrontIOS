//
//  MyReservationsView.swift
//  DarnaApp
//

import SwiftUI

struct MyReservationsView: View {
    @State private var properties: [Property] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Chargement...")
                        .progressViewStyle(.circular)
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Réessayer") {
                            Task {
                                await loadProperties()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if properties.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "house.fill")
                            .font(.largeTitle)
                            .foregroundColor(AppTheme.textSecondary)
                        Text("Aucune annonce")
                            .font(.headline)
                        Text("Vous n'avez pas encore créé d'annonces.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(properties) { property in
                                NavigationLink(destination: PropertyBookingsView(property: property)) {
                                    PropertyReservationCard(property: property)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Demandes en attente")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadProperties()
            }
        }
    }
    
    private func loadProperties() async {
        isLoading = true
        errorMessage = nil
        
        do {
            properties = try await PropertyService.shared.fetchUserProperties()
        } catch {
            errorMessage = "Impossible de charger vos annonces."
        }
        
        isLoading = false
    }
}

struct PropertyReservationCard: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(property.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("\(Int(property.price)) DT/mois")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
            }
            
            if let location = property.location, !location.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(location)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            HStack {
                Label("\(property.nbrCollocateurActuel ?? 0)/\(property.nbrCollocateurMax ?? 0) colocataires", systemImage: "person.3.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

