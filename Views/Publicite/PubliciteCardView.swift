//
//  PubliciteCardView.swift
//  DarnaApp
//

import SwiftUI

struct PubliciteCardView: View {
    let publicite: Publicite
    var isSponsor: Bool = false
    var onAdd: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            mediaSection
            badgeSection
            mainContent
            dateSection
            sponsorActions
        }
        .padding(16)
        .background(AppTheme.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private var mediaSection: some View {
        ZStack {
            if let imageUrl = publicite.imageUrl,
               !imageUrl.isEmpty,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder
                    case .empty:
                        ProgressView()
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .clipped()
        .cornerRadius(12)
    }
    
    private var badgeSection: some View {
        HStack {
            HStack(spacing: 8) {
                Text(publicite.type)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.primary.opacity(0.15))
                    .foregroundColor(AppTheme.primary)
                    .clipShape(Capsule())
                
                Text(publicite.isActive ? "Actif" : "Expiré")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((publicite.isActive ? Color.green : .red).opacity(0.15))
                    .foregroundColor(publicite.isActive ? .green : .red)
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            if isSponsor {
                Menu {
                    if let onAdd = onAdd {
                        Button(action: onAdd) {
                            Label("Ajouter", systemImage: "plus")
                        }
                    }
                    if let onEdit = onEdit {
                        Button(action: onEdit) {
                            Label("Modifier", systemImage: "pencil")
                        }
                    }
                    if let onDelete = onDelete {
                        Button(role: .destructive, action: onDelete) {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(8)
                        .background(AppTheme.primaryLight)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(publicite.titre)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(publicite.discountText)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primary)
            
            Text(publicite.description)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
        }
    }
    
    private var dateSection: some View {
        Group {
            if let debut = publicite.dateDebutDate, let fin = publicite.dateFinDate {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                    Text("\(formatDate(debut)) → \(formatDate(fin))")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
    
    private var sponsorActions: some View {
        Group {
            if isSponsor {
                HStack(spacing: 8) {
                    if let onAdd = onAdd {
                        sponsorButton(title: "Nouvelle pub", systemImage: "plus", action: onAdd)
                    }
                    if let onEdit = onEdit {
                        sponsorButton(title: "Modifier", systemImage: "pencil", action: onEdit)
                    }
                    if let onDelete = onDelete {
                        sponsorButton(
                            title: "Supprimer",
                            systemImage: "trash.fill",
                            action: onDelete,
                            foreground: .red,
                            background: Color.red.opacity(0.12)
                        )
                    }
                }
            }
        }
    }
    
    private func sponsorButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void,
        foreground: Color = AppTheme.primary,
        background: Color = AppTheme.primary.opacity(0.1)
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(background)
                .foregroundColor(foreground)
                .clipShape(Capsule())
        }
    }
    
    private var placeholder: some View {
        ZStack {
            AppTheme.primaryLight
            Image(systemName: "photo.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.primary.opacity(0.5))
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

