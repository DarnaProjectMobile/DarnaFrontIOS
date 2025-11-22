//
//  PropertyBookingsView.swift
//  DarnaApp
//

import SwiftUI

struct PropertyBookingsView: View {
    let property: Property
    @State private var propertyWithBookings: PropertyWithBookings?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Property Info
                propertyInfoCard
                
                if isLoading {
                    ProgressView("Chargement des réservations...")
                        .padding()
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else if let data = propertyWithBookings {
                    if data.bookings.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.largeTitle)
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Aucune réservation")
                                .font(.headline)
                            Text("Personne n'a encore réservé cette annonce.")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        bookingsList(data.bookings)
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Réservations")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadBookings()
        }
    }
    
    private var propertyInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(property.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            if let location = property.location, !location.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(location)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            HStack {
                Text("\(Int(property.price)) DT/mois")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
                
                Spacer()
                
                Text("\(property.nbrCollocateurActuel ?? 0)/\(property.nbrCollocateurMax ?? 0) colocataires")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func bookingsList(_ bookings: [Booking]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Réservations (\(bookings.count))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            ForEach(bookings) { booking in
                BookingCard(booking: booking)
            }
        }
    }
    
    private func loadBookings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            propertyWithBookings = try await PropertyService.shared.fetchPropertyWithBookings(id: property.id)
        } catch {
            errorMessage = "Impossible de charger les réservations."
        }
        
        isLoading = false
    }
}

struct BookingCard: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let user = booking.user {
                // User Info Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.primary)
                        
                        Text(user.username ?? "Utilisateur")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Divider()
                    
                    // User Details
                    VStack(alignment: .leading, spacing: 10) {
                        if let email = user.email {
                            InfoRow(icon: "envelope.fill", label: "Email", value: email)
                        }
                        
                        if let phone = user.phone {
                            InfoRow(icon: "phone.fill", label: "Téléphone", value: phone)
                        }
                        
                        if let gender = user.gender {
                            InfoRow(icon: "person.fill", label: "Genre", value: gender)
                        }
                        
                        if let dateOfBirth = user.dateOfBirth {
                            InfoRow(icon: "calendar", label: "Date de naissance", value: formatDate(dateOfBirth))
                        } else if let dateString = user.dateDeNaissance {
                            InfoRow(icon: "calendar", label: "Date de naissance", value: dateString)
                        }
                    }
                }
            } else {
                Text("Utilisateur non disponible")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Divider()
            
            // Booking Date
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(AppTheme.primary)
                Text("Date de réservation:")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Text(formatDate(booking.bookingStartDate))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 20)
            
            Text(label + ":")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
        }
    }
}

