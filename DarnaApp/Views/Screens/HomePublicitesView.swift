//
//  HomePublicitesView.swift
//  DarnaApp
//
//  Écran d'accueil avec marques partenaires et promotions

import SwiftUI

struct HomePublicitesView: View {
    @StateObject private var viewModel = PubliciteViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var selectedSponsorId: String? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header avec recherche
                    headerSection
                    
                    // Filtres par catégorie
                    categoryFilters
                    
                    // Marques partenaires
                    partnerBrandsSection
                    
                    // Toutes les promotions
                    promotionsSection
                }
                .padding(.bottom, 20)
            }
            .background(AppTheme.background)
            .navigationTitle("Offres Étudiantes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Menu hamburger
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Notifications
                    } label: {
                        Image(systemName: "bell")
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
            .task {
                await viewModel.loadPublicites()
            }
            .onChange(of: searchText) { newValue in
                viewModel.searchText = newValue
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Barre de recherche
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Rechercher une marque...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocorrectionDisabled()
                
                Button {
                    // Filtres
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .foregroundColor(AppTheme.primary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Category Filters
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PubliciteViewModel.Category.allCases, id: \.self) { category in
                    CategoryChip(
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Nos Marques Partenaires")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                if viewModel.isSponsor {
                    Button {
                        // Ajouter une publicité
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .padding(.horizontal)
            
            if viewModel.partnerBrands.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Aucune marque partenaire")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.partnerBrands, id: \.id) { brand in
                            PartnerBrandCard(
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
    }
    
    // MARK: - Promotions Section
    private var promotionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Toutes les Promotions")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                if viewModel.isSponsor {
                    Button {
                        // Ajouter une publicité
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .padding(.horizontal)
            
            if viewModel.isLoading && viewModel.filteredPublicites.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if filteredPromotions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "megaphone.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.primary.opacity(0.5))
                    Text("Aucune promotion disponible")
                        .font(.headline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(filteredPromotions) { publicite in
                        NavigationLink(destination: PubliciteDetailView(publicite: publicite)) {
                            PromotionCardView(publicite: publicite)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // Filtrer les promotions par sponsor sélectionné
    private var filteredPromotions: [Publicite] {
        if let selectedSponsorId = selectedSponsorId {
            return viewModel.filteredPublicites.filter { $0.sponsorId == selectedSponsorId }
        }
        return viewModel.filteredPublicites
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? AppTheme.primary : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

// MARK: - Partner Brand Card
struct PartnerBrandCard: View {
    let name: String
    let logoUrl: String?
    let isSelected: Bool
    let action: () -> Void
    
    // Couleurs pour les marques (utilisées si pas de logo)
    private var brandColor: Color {
        let colors: [Color] = [
            Color(red: 0.2, green: 0.25, blue: 0.35),  // Bleu foncé
            Color(red: 0.25, green: 0.25, blue: 0.35), // Gris-Bleu
            Color(red: 0.95, green: 0.7, blue: 0.15),  // Jaune/Or
            Color(red: 0.25, green: 0.3, blue: 0.4),   // Bleu marine
            Color(red: 0.3, green: 0.25, blue: 0.35),  // Violet foncé
        ]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppTheme.primary.opacity(0.2) : Color.clear)
                        .frame(width: 70, height: 70)
                    
                    if let logoUrl = logoUrl, let url = URL(string: logoUrl) {
                        // Logo depuis URL
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
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
                            .stroke(AppTheme.primary, lineWidth: 3)
                            .frame(width: 60, height: 60)
                    }
                }
                
                Text(name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
        }
    }
    
    private var brandInitial: some View {
        ZStack {
            Circle()
                .fill(brandColor)
                .frame(width: 60, height: 60)
            
            Text(String(name.prefix(1).uppercased()))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Promotion Card View
struct PromotionCardView: View {
    let publicite: Publicite
    
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
                
                // Boutons d'action
                HStack(spacing: 12) {
                    Button {
                        // Favoris
                    } label: {
                        Image(systemName: "heart")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Button {
                        // Partager
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(12)
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .clipped()
            
            // Contenu
            VStack(alignment: .leading, spacing: 8) {
                // Sponsor
                if let sponsorName = publicite.sponsorName {
                    Text(sponsorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.primary)
                }
                
                // Offre
                Text(publicite.titre)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
                // Date d'expiration
                if let expiration = publicite.dateExpirationDate {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("Expire le \(formatDate(expiration))")
                            .font(.caption)
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppTheme.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var imagePlaceholder: some View {
        ZStack {
            AppTheme.primaryLight
            Image(systemName: "photo.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.primary.opacity(0.5))
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

