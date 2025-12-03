//  SponsorAdsView.swift
//  DarnaApp

import SwiftUI

struct SponsorAdsView: View {
    @StateObject private var viewModel = PubliciteViewModel()
    @State private var showCreate = false
    @State private var editPublicite: Publicite?
    @State private var showDeleteConfirmation = false
    @State private var publiciteToDelete: Publicite?
    
    var isSponsor: Bool {
        viewModel.isSponsor  // true si role == sponsor
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.publicites.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.publicites.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Publicités")
            .toolbar {
                if isSponsor {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showCreate = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(AppTheme.onPrimary)
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.primary)
                    }
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
                        Task { await viewModel.deletePublicite(id: publicite.id) }
                    }
                }
            } message: {
                Text("Cette action est irréversible.")
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
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "megaphone.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primary.opacity(0.5))
            Text("Aucune publicité")
                .font(.title2).fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimary)
            Text(isSponsor ? "Créez votre première publicité" : "Pas encore d’annonces")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.publicites) { publicite in
                    PubliciteCardView(
                        publicite: publicite,
                        isSponsor: isSponsor,
                        onAdd: isSponsor ? {
                            // ouvre le formulaire d’ajout (en repartant sur une feuille vide)
                            showCreate = true
                        } : nil,
                        onEdit: isSponsor ? {
                            editPublicite = publicite
                        } : nil,
                        onDelete: isSponsor ? {
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
