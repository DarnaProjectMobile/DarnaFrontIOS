//
//  OffresEtudiantesView.swift
//  DarnaApp
//
//  Vue principale des offres étudiantes - Design moderne
//

import SwiftUI

struct OffresEtudiantesView: View {
    @StateObject private var viewModel = PubliciteViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var showAddPublicite = false
    @State private var showAddMarque = false
    @State private var publiciteToEdit: Publicite? = nil
    @State private var publiciteToDelete: Publicite? = nil
    @State private var showDeleteAlert = false
    
    // Catégories disponibles
    private let categories = ["Tout", "Nourriture", "Tech", "Loisirs", "Vêtement", "Santé", "Transport"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header personnalisé
                        ModernHeaderView(
                            title: "Offres Étudiantes",
                            onMenuTap: {
                                print("Menu tapped")
                            },
                            onNotificationTap: {
                                print("Notifications tapped")
                            }
                        )
                        
                        // Barre de recherche
                        ModernSearchBar(
                            searchText: $searchText,
                            placeholder: "Rechercher une marque...",
                            onFilterTap: {
                                print("Filter tapped")
                            }
                        )
                        .onChange(of: searchText) { newValue in
                            viewModel.searchText = newValue
                        }
                        
                        // Catégories (chips horizontales)
                        CategoryChipsView(
                            selectedCategory: $selectedCategory,
                            categories: categories
                        )
                        .onChange(of: selectedCategory) { newValue in
                            viewModel.selectedCategory = newValue
                        }
                        
                        // Marques partenaires
                        MarquePartenaireView(
                            marques: viewModel.partnerBrands,
                            onAddTap: {
                                showAddMarque = true
                            }
                        )
                        .padding(.top, 8)
                        
                        // Section "Toutes les Promotions"
                        promotionsSection
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.loadPublicites()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .alert("Supprimer la publicité", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) {
                    publiciteToDelete = nil
                }
                Button("Supprimer", role: .destructive) {
                    if let publicite = publiciteToDelete {
                        Task {
                            let success = await viewModel.deletePublicite(id: publicite.id)
                            if success {
                                publiciteToDelete = nil
                            }
                        }
                    }
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer cette publicité ?")
            }
            .alert("Erreur", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Une erreur est survenue")
            }
            .alert("Succès", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.successMessage)
            }
            .sheet(isPresented: $showAddPublicite) {
                PubliciteFormView()
            }
            .sheet(item: $publiciteToEdit) { publicite in
                PubliciteFormView(publicite: publicite)
            }
        }
    }
    
    // MARK: - Section Promotions
    private var promotionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header avec titre et bouton +
            HStack {
                Text("Toutes les Promotions")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Bouton + visible uniquement pour les sponsors
                if viewModel.isSponsor {
                    Button(action: {
                        showAddPublicite = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal)
            
            // Liste des publicités
            if viewModel.isLoading && viewModel.filteredPublicites.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if viewModel.filteredPublicites.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredPublicites) { publicite in
                        NavigationLink(destination: PubliciteDetailView(publicite: publicite)) {
                            ModernPubliciteCard(
                                publicite: publicite,
                                canEdit: viewModel.canEdit(publicite),
                                onEdit: {
                                    publiciteToEdit = publicite
                                },
                                onDelete: {
                                    publiciteToDelete = publicite
                                    showDeleteAlert = true
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "megaphone.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.5))
            
            Text("Aucune promotion disponible")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if viewModel.isSponsor {
                Button(action: {
                    showAddPublicite = true
                }) {
                    Text("Créer une publicité")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    OffresEtudiantesView()
}
