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
    @State private var searchText = ""
    
    private var filteredPublicites: [Publicite] {
        guard !searchText.isEmpty else { return viewModel.publicites }
        let query = searchText.lowercased()
        return viewModel.publicites.filter { publicite in
            publicite.titre.lowercased().contains(query) ||
            publicite.description.lowercased().contains(query) ||
            publicite.type.lowercased().contains(query)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                content
                if viewModel.isSponsor {
                    addButton
                }
            }
            .navigationTitle("Publicités")
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
            .task { await viewModel.loadPublicites() }
        }
        .tint(AppTheme.primary)
    }
    
    private var content: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 16) {
                searchBar
                if viewModel.isLoading && viewModel.publicites.isEmpty {
                    Spacer()
                    ProgressView().scaleEffect(1.5)
                    Spacer()
                } else if filteredPublicites.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPublicites) { publicite in
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
            .padding(.top)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Rechercher une publicité...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "megaphone.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primary.opacity(0.5))
            Text("Aucune publicité")
                .font(.title2)
                .fontWeight(.semibold)
            Text(viewModel.isSponsor ? "Créez votre première publicité" : "Aucune publicité disponible pour le moment")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private var addButton: some View {
        Button {
            showCreate = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(AppTheme.primary)
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 2)
                .padding(20)
        }
        .buttonStyle(.plain)
    }
}

