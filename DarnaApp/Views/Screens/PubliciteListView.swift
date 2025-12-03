//
//  PubliciteListView.swift
//  DarnaApp
//

import SwiftUI
	
struct PubliciteListView: View {
    @StateObject private var viewModel = PubliciteViewModel()
    @State private var showCreate = false
    @State private var editPublicite: Publicite?
    @State private var showDeleteConfirmation = false
    @State private var publiciteToDelete: Publicite?
    
    var isSponsor: Bool {
        viewModel.isSponsor
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                
                contentView
                
                // Bouton flottant d'ajout
                if isSponsor {
                    Button(action: {
                        showCreate = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(AppTheme.primary)
                            .clipShape(Circle())
                            .shadow(radius: 4, x: 0, y: 2)
                            .padding(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Publicités")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sponsor") {}
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.primary)
                }
            }
            .sheet(isPresented: $showCreate) {
                PubliciteFormView(viewModel: viewModel)
            }
            .sheet(item: $editPublicite) { publicite in
                PubliciteFormView(viewModel: viewModel, editingPublicite: publicite)
            }
            .alert("Supprimer la publicité", isPresented: $showDeleteConfirmation) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
                    if let publicite = publiciteToDelete {
                        Task {
                            await viewModel.deletePublicite(id: publicite.id)
                        }
                    }
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer cette publicité ? Cette action est irréversible.")
            }
            .alert("Erreur", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Une erreur est survenue")
            }
            .alert("Succès", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.successMessage)
            }
            .task {
                await viewModel.loadPublicites()
            }
        }
        .tint(AppTheme.primary)
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                // Barre de recherche
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher une publicité...", text: .constant(""))
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Filtres
                HStack {
                    Menu {
                        Button("Tous les types") {}
                        Button("Promotion") {}
                        Button("Réduction") {}
                        Button("Bon plan") {}
                    } label: {
                        HStack {
                            Text("Tous les types")
                            Image(systemName: "chevron.down")
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    Menu {
                        Button("Plus récentes") {}
                        Button("Plus anciennes") {}
                        Button("Par popularité") {}
                    } label: {
                        HStack {
                            Text("Plus récentes")
                            Image(systemName: "chevron.down")
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                if viewModel.isLoading && viewModel.publicites.isEmpty {
                    Spacer()
                    ProgressView().scaleEffect(1.5)
                    Spacer()
                } else if viewModel.publicites.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "megaphone.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.primary.opacity(0.5))
                        Text("Aucune publicité")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text(viewModel.isSponsor ? "Créez votre première publicité" : "Aucune publicité disponible pour le moment")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.publicites) { publicite in
                                PubliciteCardView(
                                    publicite: publicite,
                                    isSponsor: viewModel.isSponsor,
                                    onEdit: viewModel.isSponsor ? { editPublicite = publicite } : nil,
                                    onDelete: viewModel.isSponsor ? {
                                        publiciteToDelete = publicite
                                        showDeleteConfirmation = true
                                    } : nil
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable { await viewModel.refresh() }
                }
            }
        }
    }
}
