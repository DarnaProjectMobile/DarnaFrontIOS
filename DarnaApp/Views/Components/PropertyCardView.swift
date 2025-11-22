//
//  PropertyCardView.swift
//  DarnaApp
//

import SwiftUI

struct PropertyCardView: View {
    let property: Property
    var canManage: Bool = false
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    @StateObject private var favoritesManager = FavoritesManager.shared
    @State private var isFavorite = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image section
            ZStack {
                AppTheme.primaryLight
                PropertyImageView(imageString: property.image)
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(12)
            
            // Title and price
            VStack(alignment: .leading, spacing: 4) {
                Text(property.title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
                Text(formattedPrice)
                    .font(.headline)
                    .foregroundColor(AppTheme.primary)
            }
            
            // Description
            if let description = property.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(3)
            }
            
            // Start date (date début)
            if let startDate = property.startDate {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text("Disponible début \(formatDate(startDate))")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            // Owner + actions row
            footerRow
        }
        .padding(16)
        .background(AppTheme.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .onAppear {
            isFavorite = favoritesManager.isFavorite(propertyId: property.id)
        }
        .onChange(of: favoritesManager.favoritePropertyIds) { _ in
            isFavorite = favoritesManager.isFavorite(propertyId: property.id)
        }
    }
    
    // MARK: - Helpers
    
    private var formattedPrice: String {
        // Example: "650 DT/mois"
        let priceString = String(format: "%.0f", property.price)
        return "\(priceString) DT/mois"
    }
    
    private var ownerLabel: String {
        property.ownerName ?? property.user ?? "Non spécifié"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private var footerRow: some View {
        HStack(spacing: 12) {
            Button {
                favoritesManager.toggleFavorite(propertyId: property.id)
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.subheadline)
                    .foregroundColor(isFavorite ? .red : AppTheme.textSecondary)
                    .padding(8)
                    .background(AppTheme.primaryLight.opacity(0.5))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Text("Propriétaire: \(ownerLabel)")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(1)
            
            Spacer()
            
            if canManage {
                HStack(spacing: 8) {
                    Button {
                        onEdit?()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .padding(6)
                            .background(AppTheme.primary.opacity(0.12))
                            .foregroundColor(AppTheme.primary)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Button(role: .destructive) {
                        onDelete?()
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .padding(6)
                            .background(Color.red.opacity(0.12))
                            .foregroundColor(.red)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

