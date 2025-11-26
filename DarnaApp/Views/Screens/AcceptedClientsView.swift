//
//  AcceptedClientsView.swift
//  DarnaApp
//
//  Shows the list of user's properties to select and view confirmed bookings

import SwiftUI

// MARK: - Property Selection View (Step 1)

struct AcceptedClientsView: View {
    @State private var properties: [Property] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            if isLoading {
                ProgressView("Chargement de vos annonces...")
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
                        Task { await loadProperties() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if properties.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.textSecondary)
                    Text("Aucune annonce")
                        .font(.headline)
                    Text("Vous n'avez pas encore créé d'annonces.")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sélectionnez une annonce")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // Properties list
                        LazyVStack(spacing: 12) {
                            ForEach(properties) { property in
                                NavigationLink(destination: ConfirmedBookingsListView(property: property)) {
                                    PropertySelectionCard(property: property)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Clients acceptés")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadProperties()
        }
    }
    
    private func loadProperties() async {
        isLoading = true
        errorMessage = nil
        
        do {
            properties = try await PropertyService.shared.fetchUserProperties()
        } catch {
            errorMessage = "Impossible de charger vos annonces."
        }
        
        isLoading = false
    }
}

// MARK: - Property Selection Card

struct PropertySelectionCard: View {
    let property: Property
    
    var body: some View {
        HStack(spacing: 16) {
            // Property image thumbnail
            PropertyImageView(imageString: property.image)
                .frame(width: 80, height: 80)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(property.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                if let location = property.location, !location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(location)
                            .lineLimit(1)
                    }
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
                }
                
                HStack {
                    // Colocataires count
                    HStack(spacing: 4) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 10))
                        Text("\(property.nbrCollocateurActuel ?? 0)/\(property.nbrCollocateurMax ?? 0)")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.primaryLight)
                    .cornerRadius(6)
                    
                    Spacer()
                    
                    Text("\(Int(property.price)) DT")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                }
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.textSecondary)
                .font(.system(size: 14))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Confirmed Bookings List View (Step 2)

struct ConfirmedBookingsListView: View {
    let property: Property
    @State private var propertyWithBookings: PropertyWithBookings?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Property Info Header
                propertyInfoHeader
                
                if isLoading {
                    ProgressView("Chargement des clients...")
                        .padding()
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Réessayer") {
                            Task { await loadBookings() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if let data = propertyWithBookings {
                    if data.bookings.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .font(.system(size: 48))
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Aucun client confirmé")
                                .font(.headline)
                            Text("Vous n'avez pas encore de clients confirmés pour cette annonce.")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        confirmedBookingsList(data.bookings)
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Clients confirmés")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadBookings()
        }
    }
    
    private var propertyInfoHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                PropertyImageView(imageString: property.image)
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    if let location = property.location, !location.isEmpty {
                        Text(location)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            
            Divider()
            
            // Stats
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Colocataires")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                    Text("\(property.nbrCollocateurActuel ?? 0)/\(property.nbrCollocateurMax ?? 0)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Loyer")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                    Text("\(Int(property.price)) DT/mois")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func confirmedBookingsList(_ bookings: [Booking]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Clients confirmés (\(bookings.count))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            ForEach(bookings) { booking in
                ConfirmedBookingCard(booking: booking)
            }
        }
    }
    
    private func loadBookings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            propertyWithBookings = try await PropertyService.shared.fetchPropertyWithBookings(id: property.id)
        } catch {
            errorMessage = "Impossible de charger les clients."
        }
        
        isLoading = false
    }
}

// MARK: - Confirmed Booking Card

struct ConfirmedBookingCard: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Status badge
            HStack {
                Label("Confirmé", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(8)
                
                Spacer()
                
                Text("Depuis le \(formatDate(booking.bookingStartDate))")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            if let user = booking.user {
                // User Info Section
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 60, height: 60)
                        Image(systemName: "person.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.username ?? "Utilisateur")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        if let email = user.email {
                            HStack(spacing: 4) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 10))
                                Text(email)
                            }
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        if let phone = user.phone {
                            HStack(spacing: 4) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 10))
                                Text(phone)
                            }
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Additional user details
                if user.gender != nil || user.dateDeNaissance != nil {
                    Divider()
                    
                    HStack(spacing: 20) {
                        if let gender = user.gender {
                            HStack(spacing: 6) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(gender)
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        }
                        
                        if let dateOfBirth = user.dateOfBirth {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(formatDate(dateOfBirth))
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        } else if let dateString = user.dateDeNaissance {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(dateString)
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        }
                    }
                }
                
                // Contact buttons
                HStack(spacing: 12) {
                    if let phone = user.phone {
                        Button {
                            if let url = URL(string: "tel://\(phone)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Appeler")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppTheme.primaryLight)
                            .cornerRadius(10)
                        }
                    }
                    
                    if let email = user.email {
                        Button {
                            if let url = URL(string: "mailto:\(email)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Email")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppTheme.primary)
                            .cornerRadius(10)
                        }
                    }
                }
            } else {
                Text("Informations utilisateur non disponibles")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

