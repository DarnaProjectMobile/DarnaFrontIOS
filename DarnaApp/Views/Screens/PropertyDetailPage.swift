//
//  PropertyDetailPage.swift
//  DarnaApp
//

import SwiftUI

struct PropertyDetailPage: View {
    @State private var property: Property
    
    @State private var selectedTab: DetailTab = .details
    @State private var rating = 0
    @State private var reviewText = ""
    @State private var showConfirmation = false
    @State private var showBookingPage = false
    
    init(property: Property) {
        _property = State(initialValue: property)
    }
    
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
                reviewSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Détails")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Avis publié", isPresented: $showConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Votre avis a été publié avec succès.")
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PropertyImageView(imageString: property.image)
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
            
            VStack(alignment: .leading, spacing: 8) {
                if let location = property.location, !location.isEmpty {
                    Label(location, systemImage: "location.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Label(colocatairesLabel, systemImage: "person.3.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
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
            
            if let images = property.images, !images.isEmpty {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(images, id: \.self) { imageString in
                            PropertyImageView(imageString: imageString)
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(16)
                        }
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                    Text("Aucune photo disponible")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 6)
    }
    
    private var contactButton: some View {
        Button {
            showBookingPage = true
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
        .sheet(isPresented: $showBookingPage) {
            BookPropertyPage(property: property) { updatedProperty in
                property = updatedProperty
            }
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
    
    private var colocatairesLabel: String {
        let actuel = property.nbrCollocateurActuel ?? 0
        let max = property.nbrCollocateurMax ?? 0
        return "\(actuel)/\(max) colocataires"
    }
    
    private var availabilityLabel: String {
        if let startDate = property.startDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.string(from: startDate)
        }
        return "Disponibilité non spécifiée"
    }
    
    // MARK: - Review Section
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Avis et notes")
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal, 20)
            
            // Average Rating
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: "star.fill")
                        .foregroundColor(star <= 4 ? .yellow : .gray.opacity(0.3))
                }
                Text("4.0")
                    .font(.system(size: 20, weight: .semibold))
            }
            .padding(.horizontal, 20)
            
            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(["Tous", "5★", "4★", "3★", "2★", "1★"], id: \.self) { f in
                        Text(f)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Preview review
            VStack(alignment: .leading, spacing: 8) {
                Text("⭐️⭐️⭐️⭐️⭐️  |  Amine B.")
                    .font(.system(size: 14, weight: .semibold))
                Text("Appartement très calme et bien situé. Propriétaire très accueillant !")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            // Navigate to all reviews
            NavigationLink(destination: ReviewsPage(property: property)) {
                Text("Voir tous les avis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
            }
            
            Divider().padding(.horizontal, 20)
            
            // Leave a review
            VStack(alignment: .leading, spacing: 12) {
                Text("Laissez un avis")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.horizontal, 20)
                
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 30))
                            .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.4))
                            .onTapGesture { rating = star }
                    }
                }
                .padding(.horizontal, 20)
                
                TextEditor(text: $reviewText)
                    .frame(height: 100)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                
                Button {
                    guard rating > 0, !reviewText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    showConfirmation = true
                    reviewText = ""
                    rating = 0
                } label: {
                    Text("Publier mon avis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.primary)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 30)
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