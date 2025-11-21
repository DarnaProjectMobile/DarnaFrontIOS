//
//  PropertyDetailPage.swift
//  DarnaApp
//

import SwiftUI

struct PropertyDetailPage: View {
    let property: Property
    
    @State private var selectedTab: DetailTab = .details
    
    private enum DetailTab: Int, CaseIterable {
        case details, tour, photos
        
        var title: String {
            switch self {
            case .details: return "Details"
            case .tour: return "Visite 360°"
            case .photos: return "Photos"
            }
        }
        
        var icon: String {
            switch self {
            case .details: return "doc.text.fill"
            case .tour: return "eye.fill"
            case .photos: return "camera.fill"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                tabSelector
                tabContent
                contactButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Détails")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image("house")
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(property.location?.isEmpty == false ? property.location! : property.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(property.type ?? "Type non spécifié")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 16) {
                Label("3 colocataires", systemImage: "person.3.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
            }
            
            capsuleToolbar
        }
    }
    
    private var capsuleToolbar: some View {
        HStack(spacing: 12) {
            CapsuleButton(title: "Details", isSelected: selectedTab == .details) {
                selectedTab = .details
            }
            CapsuleButton(title: "Visite 360°", isSelected: selectedTab == .tour) {
                selectedTab = .tour
            }
            CapsuleButton(title: "Photos", isSelected: selectedTab == .photos) {
                selectedTab = .photos
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var tabSelector: some View {
        EmptyView()
    }
    
    // MARK: - Tab Content
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case .details:
                detailsTab
            case .tour:
                placeholder(
                    icon: "eye.fill",
                    title: "Visite 360°",
                    message: "La visite 360° sera bientôt disponible."
                )
            case .photos:
                photosTab
            }
        }
    }
    
    private var detailsTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            tagsSection
            identityCards
            descriptionSection
            rentalInfo
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 6)
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Les 3 mots de la coloc")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(displayedTags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 14, weight: .bold))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(colors: [Color.purple, Color.pink], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(20)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private var displayedTags: [String] {
        if property.tags.isEmpty {
            return ["Artistique", "Foodie", "Festif"]
        }
        return Array(property.tags.prefix(3))
    }
    
    private var identityCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Carte d'identité du logement")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 12) {
                PropertyInfoCard(
                    title: property.calmLevel.isEmpty ? "Niveau de Calme" : property.calmLevel,
                    description: property.calmLevelDescription.isEmpty ? "Ça dépend du mood" : property.calmLevelDescription,
                    icon: "theatermasks.fill",
                    iconColors: [.yellow, .blue]
                )
                
                PropertyInfoCard(
                    title: property.lifestyle.isEmpty ? "Style de Vie" : property.lifestyle,
                    description: property.lifestyleDescription.isEmpty ? "Cuisine ensemble" : property.lifestyleDescription,
                    icon: "fork.knife",
                    iconColors: [.purple, .pink]
                )
                
                PropertyInfoCard(
                    title: property.homeEnergy.isEmpty ? "Énergie du Foyer" : property.homeEnergy,
                    description: property.homeEnergyDescription.isEmpty ? "Très actif" : property.homeEnergyDescription,
                    icon: "bolt.fill",
                    iconColors: [.orange, .red]
                )
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.system(size: 18, weight: .semibold))
            Text(property.description ?? "Aucune description disponible.")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)
        }
    }
    
    private var rentalInfo: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Loyer mensuel")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(Int(property.price))DT")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Disponible")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Text(availabilityLabel)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
    }
    
    private var photosTab: some View {
        VStack(spacing: 16) {
            Text("Photos du logement")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image("house")
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(20)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 6)
    }
    
    private var contactButton: some View {
        Button {
            // Empty action for now
        } label: {
            Text("Contacter les Colocataires")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
        }
    }
    
    private func placeholder(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(AppTheme.primary.opacity(0.5))
            Text(title)
                .font(.system(size: 18, weight: .semibold))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 6)
    }
    
    private var availabilityLabel: String {
        if let startDate = property.startDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: startDate)
        }
        return "Début novembre"
    }
}

private struct CapsuleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? AppTheme.onPrimary : AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? AppTheme.primary : Color.clear)
                .cornerRadius(20)
        }
    }
}

// MARK: - Property Info Card
struct PropertyInfoCard: View {
    let title: String
    let description: String
    let icon: String
    let iconColors: [Color]
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(
                        LinearGradient(colors: iconColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}