//
//  PropertyBookingsView.swift
//  DarnaApp
//
//  Shows pending booking requests (attendingListBookings) with Accept/Reject buttons

import SwiftUI

struct PropertyBookingsView: View {
    let property: Property
    @State private var propertyWithBookings: PropertyWithBookings?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isProcessing = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Property Info
                propertyInfoCard
                
                if isLoading {
                    ProgressView("Chargement des demandes...")
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
                    if data.attendingListBookings.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.badge.clock")
                                .font(.system(size: 48))
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Aucune demande en attente")
                                .font(.headline)
                            Text("Vous n'avez pas de demandes de réservation en attente pour cette annonce.")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        pendingBookingsList(data.attendingListBookings)
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Demandes de réservation")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadBookings()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .overlay {
            if isProcessing {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Traitement en cours...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(Color(.systemGray5))
                    .cornerRadius(16)
                }
            }
        }
    }
    
    private var propertyInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
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
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                // Pending count badge
                if let data = propertyWithBookings, !data.attendingListBookings.isEmpty {
                    VStack {
                        Text("\(data.attendingListBookings.count)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("en attente")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
            }
            
            Divider()
            
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
    
    private func pendingBookingsList(_ bookings: [Booking]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.badge.questionmark")
                    .foregroundColor(.orange)
                Text("Demandes en attente (\(bookings.count))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            ForEach(bookings) { booking in
                PendingBookingCard(
                    booking: booking,
                    onAccept: { await acceptBooking(booking) },
                    onReject: { await rejectBooking(booking) }
                )
            }
        }
    }
    
    private func loadBookings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            propertyWithBookings = try await PropertyService.shared.fetchPropertyWithBookings(id: property.id)
        } catch {
            errorMessage = "Impossible de charger les demandes."
        }
        
        isLoading = false
    }
    
    private func acceptBooking(_ booking: Booking) async {
        isProcessing = true
        
        do {
            _ = try await PropertyService.shared.respondToBooking(
                annonceId: property.id,
                bookingId: booking.id,
                accept: true
            )
            
            await MainActor.run {
                alertTitle = "Réservation acceptée ✅"
                alertMessage = "La demande de \(booking.user?.username ?? "l'utilisateur") a été acceptée avec succès."
                showAlert = true
            }
            
            // Reload to update the list
            await loadBookings()
            
        } catch {
            await MainActor.run {
                alertTitle = "Erreur"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
        
        isProcessing = false
    }
    
    private func rejectBooking(_ booking: Booking) async {
        isProcessing = true
        
        do {
            _ = try await PropertyService.shared.respondToBooking(
                annonceId: property.id,
                bookingId: booking.id,
                accept: false
            )
            
            await MainActor.run {
                alertTitle = "Demande refusée"
                alertMessage = "La demande de \(booking.user?.username ?? "l'utilisateur") a été refusée."
                showAlert = true
            }
            
            // Reload to update the list
            await loadBookings()
            
        } catch {
            await MainActor.run {
                alertTitle = "Erreur"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
        
        isProcessing = false
    }
}

// MARK: - Pending Booking Card with Accept/Reject buttons

struct PendingBookingCard: View {
    let booking: Booking
    let onAccept: () async -> Void
    let onReject: () async -> Void
    
    @State private var showConfirmAccept = false
    @State private var showConfirmReject = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Status badge
            HStack {
                Label("En attente", systemImage: "clock.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(formatDate(booking.bookingStartDate))
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            if let user = booking.user {
                // User Info Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primaryLight)
                                .frame(width: 50, height: 50)
                            Image(systemName: "person.fill")
                                .font(.system(size: 22))
                                .foregroundColor(AppTheme.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.username ?? "Utilisateur")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            if let email = user.email {
                                Text(email)
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // User Details
                    VStack(alignment: .leading, spacing: 10) {
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
                Text("Souhaite emménager le:")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Text(formatDate(booking.bookingStartDate))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
            }
            
            // Accept / Reject Buttons
            HStack(spacing: 12) {
                Button {
                    showConfirmReject = true
                } label: {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Refuser")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button {
                    showConfirmAccept = true
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Accepter")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .confirmationDialog(
            "Accepter cette demande?",
            isPresented: $showConfirmAccept,
            titleVisibility: .visible
        ) {
            Button("Accepter", role: .none) {
                Task { await onAccept() }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette personne sera ajoutée comme colocataire confirmé.")
        }
        .confirmationDialog(
            "Refuser cette demande?",
            isPresented: $showConfirmReject,
            titleVisibility: .visible
        ) {
            Button("Refuser", role: .destructive) {
                Task { await onReject() }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette demande de réservation sera définitivement supprimée.")
        }
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
