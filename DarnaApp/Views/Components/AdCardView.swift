//
//  AdCardView.swift
//  DarnaApp
//

import SwiftUI

struct AdCardView: View {
    let ad: Ad
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image placeholder
            ZStack {
                AppTheme.primaryLight

                Image("baristas")
                    .resizable()
                    .scaledToFill()
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .cornerRadius(12)
            
            // Badges et bouton d'action
            HStack {
                HStack(spacing: 8) {
                    Text(ad.type.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.primary.opacity(0.15))
                        .foregroundColor(AppTheme.primary)
                        .clipShape(Capsule())
                    
                    if ad.isActive {
                        Text("Actif")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(.green)
                            .clipShape(Capsule())
                    } else {
                        Text("Expiré")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(.red)
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // Menu d'actions
                Menu {
                    if let onEdit = onEdit {
                        Button {
                            onEdit()
                        } label: {
                            Label("Modifier", systemImage: "pencil")
                        }
                    }
                    
                    Button(role: .destructive) {
                        onDelete?()
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(8)
                        .background(AppTheme.primaryLight)
                        .clipShape(Circle())
                }
            }
            
            // Title
            Text(ad.title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            // Brand
            Text(ad.brand)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            
            // Discount
            HStack {
                Text(ad.discountText)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
                
                Spacer()
                
                if let code = ad.promoCode, !code.isEmpty {
                    Text("Code: \(code)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(6)
                        .background(AppTheme.primaryLight)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            
            // Description
            Text(ad.description)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
            
            // Dates
            HStack {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(formatDate(ad.startDate)) → \(formatDate(ad.endDate))")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            // Bouton de modification visible
            if let onEdit = onEdit {
                Button {
                    onEdit()
                } label: {
                    HStack {
                        Image(systemName: "pencil.circle.fill")
                        Text("Modifier la Publicité")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(AppTheme.onPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.primary)
                    .cornerRadius(10)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(AppTheme.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
