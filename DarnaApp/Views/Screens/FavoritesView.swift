//
//  FavoritesView.swift
//  DarnaApp
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @State private var favoriteProperties: [Property] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
   
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
                                await loadFavoriteProperties()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if favoriteProperties.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.fill")
                            .font(.largeTitle)
                            .foregroundColor(AppTheme.textSecondary)
                        Text("Aucun favori")
                            .font(.headline)
                        Text("Les annonces que vous ajoutez aux favoris apparaîtront ici.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(favoriteProperties) { property in
                                NavigationLink(value: property) {
                                    PropertyCardView(property: property)
                                }
                                .buttonStyle(.plain)
                                .contentShape(Rectangle())
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Mes favoris")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Property.self) { property in
                PropertyDetailPage(property: property)
            }
            .task {
                await loadFavoriteProperties()
            }
            .onReceive(NotificationCenter.default.publisher(for: .favoritesDidChange)) { _ in
                Task {
                    await loadFavoriteProperties()
                }
            }
        }
    }
   
    private func loadFavoriteProperties() async {
        isLoading = true
        errorMessage = nil
       
        do {
            // Fetch all properties
            let allProperties = try await PropertyService.shared.fetchProperties()
           
            // Filter to only show favorite properties
            let favoriteIds = favoritesManager.getFavoritePropertyIds()
            favoriteProperties = allProperties.filter { favoriteIds.contains($0.id) }
        } catch {
            errorMessage = "Impossible de charger les favoris."
        }
       
        isLoading = false
    }
}
