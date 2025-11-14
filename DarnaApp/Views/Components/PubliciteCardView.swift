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
            
            // MARK: - Image
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
                        case .failure(_):
                            imagePlaceholder
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        @unknown default:
                            imagePlaceholder
                        }
                    }
                } else {
                    imagePlaceholder
                }
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .cornerRadius(12)
            
            // MARK: - Badges et actions
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
                    
                    if publicite.isActive {
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
                
                // Menu contextuel (optionnel)
                if isSponsor {
                    Menu {
                        if let onAdd = onAdd {
                            Button {
                                onAdd()
                            } label: {
                                Label("Ajouter une publicité", systemImage: "plus")
                            }
                        }
                        
                        if let onEdit = onEdit {
                            Button {
                                onEdit()
                            } label: {
                                Label("Modifier", systemImage: "pencil")
                            }
                        }
                        
                        if let onDelete = onDelete {
                            Button(role: .destructive) {
                                onDelete()
                            } label: {
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
            
            // MARK: - Contenu principal
            Text(publicite.titre)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            if let pourcentage = publicite.pourcentageReduction {
                Text("\(Int(pourcentage))% de réduction")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
            } else {
                Text(publicite.type)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
            }
            
            Text(publicite.description)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
            
            // MARK: - Dates
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
            
            // MARK: - Boutons sponsor (ajout / modification / suppression)
            if isSponsor {
                HStack(spacing: 8) {
                    if let onAdd = onAdd {
                        Button {
                            onAdd()
                        } label: {
                            Label("Nouvelle pub", systemImage: "plus")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.primary.opacity(0.1))
                                .foregroundColor(AppTheme.primary)
                                .clipShape(Capsule())
                        }
                    }
                    
                    if let onEdit = onEdit {
                        Button {
                            onEdit()
                        } label: {
                            Label("Modifier", systemImage: "pencil")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.primary.opacity(0.1))
                                .foregroundColor(AppTheme.primary)
                                .clipShape(Capsule())
                        }
                    }
                    
                    if let onDelete = onDelete {
                        Button {
                            onDelete()
                        } label: {
                            Label("Supprimer", systemImage: "trash.fill")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.12))
                                .foregroundColor(.red)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(AppTheme.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Image Placeholder
    private var imagePlaceholder: some View {
        ZStack {
            AppTheme.primaryLight
            Image(systemName: "photo.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.primary.opacity(0.5))
        }
    }
    
    // MARK: - Date formatter
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
