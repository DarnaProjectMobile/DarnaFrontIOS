//
//  PropertyDetailPage.swift
//  DarnaApp
//

import SwiftUI

struct PropertyDetailPage: View {
    let property: Property
    @State private var selectedTab = 0
    
    // Review fields
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var showConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: - Header Image
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 250)
                    .overlay(
                        Image(systemName: "house.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.7))
                    )
                    
                    if property.has360Tour {
                        Button {
                            // 360° tour action
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "eye.fill")
                                Text("Visite 360°")
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppTheme.primary)
                            .cornerRadius(8)
                        }
                        .padding(12)
                    }
                }
                
                // MARK: - Title and Location
                VStack(alignment: .leading, spacing: 8) {
                    Text(property.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: 12) {
                        Label(property.location ?? "Localisation non précisée", systemImage: "mappin.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textSecondary)
                        Label("\(property.flatmatesCount) colocataires", systemImage: "person.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding(20)
                
                // MARK: - Tabs
                HStack(spacing: 0) {
                    TabButton(title: "Passeport", icon: "person.text.rectangle.fill", isSelected: selectedTab == 0) { selectedTab = 0 }
                    TabButton(title: "Visite 360°", icon: "eye.fill", isSelected: selectedTab == 1) { selectedTab = 1 }
                    TabButton(title: "Photos", icon: "camera.fill", isSelected: selectedTab == 2) { selectedTab = 2 }
                    TabButton(title: "Quartier", icon: "map.fill", isSelected: selectedTab == 3) { selectedTab = 3 }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                Divider().padding(.horizontal, 20)
                
                // MARK: - Tab Content
                VStack(alignment: .leading, spacing: 24) {
                    switch selectedTab {
                    case 0: passportContent
                    case 1: placeholder(icon: "eye.fill", title: "Visite 360°", message: "La visite 360° sera disponible prochainement.")
                    case 2: placeholder(icon: "camera.fill", title: "Photos", message: "Les photos seront disponibles prochainement.")
                    default: placeholder(icon: "map.fill", title: "Quartier", message: "Les informations sur le quartier seront disponibles prochainement.")
                    }
                }
                .padding(20)
                
                // MARK: - Review Section
                reviewSection
            }
        }
        .navigationTitle("Détails")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Share action
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(AppTheme.primary)
                }
            }
        }
        .alert("Merci pour votre avis !", isPresented: $showConfirmation) {
            Button("OK", role: .cancel) {}
        }
    }
    
    // MARK: - Passport Content
    private var passportContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Les 3 mots
            VStack(alignment: .leading, spacing: 12) {
                Text("Les 3 Mots de la Coloc")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(property.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(20)
                        }
                    }
                }
            }
            
            // Carte du logement
            VStack(alignment: .leading, spacing: 16) {
                Text("Carte d'identité du Logement")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                VStack(spacing: 16) {
                    PropertyInfoCard(title: property.calmLevel,
                                     description: property.calmLevelDescription,
                                     icon: "theatermasks.fill",
                                     iconColors: [.yellow, .blue])
                    PropertyInfoCard(title: property.lifestyle,
                                     description: property.lifestyleDescription,
                                     icon: "frying.pan.fill",
                                     iconColors: [.purple, .yellow])
                    PropertyInfoCard(title: property.homeEnergy,
                                     description: property.homeEnergyDescription,
                                     icon: "rocket.fill",
                                     iconColors: [.red, .orange])
                }
            }
            
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("Description")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Text(property.description ?? "Aucune description disponible")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            // Rental Details
            HStack {
                VStack(alignment: .leading) {
                    Text("Loyer mensuel")
                        .foregroundColor(AppTheme.textSecondary)
                    HStack {
                        Image(systemName: "eurosign.circle.fill")
                        Text("\(Int(property.price))€")
                            .font(.system(size: 22, weight: .bold))
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Disponibilité")
                        .foregroundColor(AppTheme.textSecondary)
                    HStack {
                        Image(systemName: "calendar")
                        Text(property.availability.isEmpty ? "Non spécifiée" : property.availability)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            Button {
                // navigate to chat later
            } label: {
                Text("Contacter les Colocataires")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Placeholder Tab
    private func placeholder(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primary.opacity(0.5))
            Text(title).font(.system(size: 20, weight: .semibold))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
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

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? AppTheme.primaryLight : Color.clear)
            .cornerRadius(12)
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
