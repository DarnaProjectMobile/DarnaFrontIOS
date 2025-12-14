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
    @State private var selectedCategory: String? = nil
    @State private var selectedSponsorId: String? = nil
    
    var isSponsor: Bool {
        viewModel.isSponsor
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                contentView
                
                // Bouton flottant d'ajout (visible seulement pour les sponsors)
                if viewModel.isSponsor {
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
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isSponsor {
                        Button("Sponsor") {}
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                AddPubliciteView(viewModel: viewModel)
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
            .onChange(of: searchText) { newValue in
                viewModel.searchText = newValue
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
            
            ScrollView {
                VStack(spacing: 20) {
                    // Barre de recherche
                    searchBar
                    
                    // Filtres par catégorie (chips horizontaux)
                    categoryFilters
                    
                    // Marques partenaires
                    if !viewModel.partnerBrands.isEmpty {
                        partnerBrandsSection
                    }
                    
                    // Liste des publicités
                    publicitesList
                }
                .padding(.vertical)
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Rechercher une publicité...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .autocorrectionDisabled()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Category Filters
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PubliciteViewModel.Category.allCases, id: \.self) { category in
                    CategoryFilterChip(
                        title: category.rawValue,
                        isSelected: category.rawValue == (selectedCategory ?? "Tout")
                    ) {
                        selectedCategory = category == .tout ? nil : category.rawValue
                        viewModel.selectedCategory = selectedCategory
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Partner Brands Section
    private var partnerBrandsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nos Marques Partenaires")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Button {
                    // Voir toutes les marques
                } label: {
                    Text("Voir tout")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.primary)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.partnerBrands, id: \.id) { brand in
                        PartnerBrandBadge(
                            name: brand.name,
                            logoUrl: brand.logo,
                            isSelected: selectedSponsorId == brand.id
                        ) {
                            // Toggle filter par sponsor
                            if selectedSponsorId == brand.id {
                                selectedSponsorId = nil
                            } else {
                                selectedSponsorId = brand.id
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Publicites List
    private var publicitesList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Toutes les Promotions")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal)
            
            if viewModel.isLoading && viewModel.publicites.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if filteredPublicites.isEmpty {
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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(filteredPublicites) { publicite in
                        NavigationLink {
                            PubliciteDetailView(publicite: publicite)
                        } label: {
                            CompactPubliciteCard(
                                publicite: publicite,
                                isSponsor: viewModel.isSponsor,
                                onEdit: viewModel.isSponsor && viewModel.canEdit(publicite) ? {
                                    editPublicite = publicite
                                } : nil,
                                onDelete: viewModel.isSponsor && viewModel.canDelete(publicite) ? {
                                    publiciteToDelete = publicite
                                    showDeleteConfirmation = true
                                } : nil
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // Filtrer les publicités par sponsor sélectionné
    private var filteredPublicites: [Publicite] {
        var filtered = viewModel.filteredPublicites
        
        if let selectedSponsorId = selectedSponsorId {
            filtered = filtered.filter { $0.sponsorId == selectedSponsorId }
        }
        
        return filtered
    }
}

// MARK: - Category Filter Chip
struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : AppTheme.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primary : AppTheme.primary.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

// MARK: - Partner Brand Badge
struct PartnerBrandBadge: View {
    let name: String
    let logoUrl: String?
    let isSelected: Bool
    let action: () -> Void
    
    private var brandColor: Color {
        let colors: [Color] = [
            Color(red: 0.2, green: 0.25, blue: 0.35),
            Color(red: 0.25, green: 0.25, blue: 0.35),
            Color(red: 0.95, green: 0.7, blue: 0.15),
            Color(red: 0.25, green: 0.3, blue: 0.4),
            Color(red: 0.3, green: 0.25, blue: 0.35),
        ]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppTheme.primary.opacity(0.15) : Color.clear)
                        .frame(width: 66, height: 66)
                    
                    if let logoUrl = logoUrl, let url = URL(string: logoUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(Circle())
                            case .failure(_), .empty:
                                brandInitial
                            @unknown default:
                                brandInitial
                            }
                        }
                    } else {
                        brandInitial
                    }
                    
                    if isSelected {
                        Circle()
                            .stroke(AppTheme.primary, lineWidth: 2.5)
                            .frame(width: 56, height: 56)
                    }
                }
                
                Text(name)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 70)
            }
        }
    }
    
    private var brandInitial: some View {
        ZStack {
            Circle()
                .fill(brandColor)
                .frame(width: 56, height: 56)
            
            Text(String(name.prefix(1).uppercased()))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Compact Publicite Card
struct CompactPubliciteCard: View {
    let publicite: Publicite
    let isSponsor: Bool
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topTrailing) {
                if let imageUrl = publicite.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure(_), .empty:
                            imagePlaceholder
                        @unknown default:
                            imagePlaceholder
                        }
                    }
                } else {
                    imagePlaceholder
                }
                
                // Badge Type + Expiration
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 6) {
                        Text(publicite.type.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(6)
                        
                        if isExpiringSoon {
                            Text("Expiré")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(6)
                        }
                    }
                }
                .padding(12)
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .clipped()
            
            // Contenu
            VStack(alignment: .leading, spacing: 8) {
                // Sponsor
                if let sponsorName = publicite.sponsorName {
                    Text(sponsorName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                // Titre
                Text(publicite.titre)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
                // Description
                Text(publicite.description)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
                
                // Date et Actions
                HStack {
                    if let expiration = publicite.dateExpirationDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(formatDateShort(expiration))
                                .font(.caption2)
                        }
                        .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Boutons d'action pour les sponsors
                    if isSponsor {
                        HStack(spacing: 8) {
                            if let onEdit = onEdit {
                                Button {
                                    onEdit()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 13, weight: .semibold))
                                        Text("Modifier")
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.blue.opacity(0.18))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            
                            if let onDelete = onDelete {
                                Button {
                                    onDelete()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 13, weight: .semibold))
                                        Text("Supprimer")
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.red.opacity(0.18))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppTheme.card)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
    
    private var imagePlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.primaryLight, AppTheme.primary.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "photo.fill")
                .font(.system(size: 30))
                .foregroundColor(AppTheme.primary.opacity(0.4))
        }
    }
    
    private var isExpiringSoon: Bool {
        guard let expiration = publicite.dateExpirationDate else { return false }
        return expiration < Date()
    }
    
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}
