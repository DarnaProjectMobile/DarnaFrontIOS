//
//  BookPropertyPage.swift
//  DarnaApp
//

import SwiftUI

struct BookPropertyPage: View {
    let property: Property
    var onBookingSuccess: ((Property) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    
    @State private var bookingStartDate = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Property Info Card
                    propertyInfoCard
                    
                    // Booking Form
                    bookingForm
                    
                    // Book Button
                    bookButton
                }
                .padding(20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Réserver")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Réservation réussie", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Votre réservation a été effectuée avec succès.")
            }
            .alert("Erreur", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
                
                Spacer()
                
                if let startDate = property.startDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(formatDate(startDate))
                            .font(.caption)
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var bookingForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date de début de réservation")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            DatePicker(
                "Date de début",
                selection: $bookingStartDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .accentColor(AppTheme.primary)
            
            if let endDate = property.endDate {
                Text("Disponible jusqu'au \(formatDate(endDate))")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.top, -8)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var bookButton: some View {
        Button {
            Task {
                await bookProperty()
            }
        } label: {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Confirmer la réservation")
                    .font(.system(size: 18, weight: .semibold))
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
        )
        .cornerRadius(16)
        .disabled(isLoading)
    }
    
    private func bookProperty() async {
        // Validate date before sending
        if let startDate = property.startDate, let endDate = property.endDate {
            let calendar = Calendar.current
            let bookingComponents = calendar.dateComponents([.year, .month, .day], from: bookingStartDate)
            let startComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
            let endComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
            
            if let bookingDate = calendar.date(from: bookingComponents),
               let start = calendar.date(from: startComponents),
               let end = calendar.date(from: endComponents) {
                if bookingDate < start || bookingDate >= end {
                    await MainActor.run {
                        errorMessage = "La date de réservation doit être entre \(formatDate(startDate)) et \(formatDate(endDate))"
                        isLoading = false
                    }
                    return
                }
            }
        }
        
        // Check if property is fully booked
        let actuel = property.nbrCollocateurActuel ?? 0
        let max = property.nbrCollocateurMax ?? 0
        if actuel >= max {
            await MainActor.run {
                errorMessage = "Cette annonce est complète. Aucune place disponible."
                isLoading = false
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedProperty = try await PropertyService.shared.bookProperty(
                id: property.id,
                bookingStartDate: bookingStartDate
            )
            
            await MainActor.run {
                isLoading = false
                // Notify parent view of the updated property
                onBookingSuccess?(updatedProperty)
                showSuccessAlert = true
            }
        } catch let networkError as NetworkError {
            await MainActor.run {
                isLoading = false
                errorMessage = networkError.localizedDescription
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Une erreur est survenue: \(error.localizedDescription)"
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

