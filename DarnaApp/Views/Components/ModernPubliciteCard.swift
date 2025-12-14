//
//  ModernPubliciteCard.swift
//  DarnaApp
//
//  Carte de publicité moderne avec image, infos et boutons d'action
//

import SwiftUI

struct ModernPubliciteCard: View {
    let publicite: Publicite
    let canEdit: Bool
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image avec overlay des boutons
            ZStack(alignment: .topTrailing) {
                // Image de la publicité
                if let imageUrl = publicite.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                        case .failure, .empty:
                            placeholderImage
                        @unknown default:
                            placeholderImage
                        }
                    }
                } else {
                    placeholderImage
                }
                
                // Boutons d'action (seulement si l'utilisateur peut éditer)
                if canEdit {
                    HStack(spacing: 8) {
                        // Bouton éditer
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.blue.opacity(0.9))
                                .clipShape(Circle())
                        }
                        
                        // Bouton supprimer
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.red.opacity(0.9))
                                .clipShape(Circle())
                        }
                    }
                    .padding(12)
                }
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            
            // Informations de la publicité
            VStack(alignment: .leading, spacing: 8) {
                // Nom de la marque
                if let sponsorName = publicite.sponsorName {
                    Text(sponsorName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                // Titre de l'offre
                Text(publicite.titre)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                // Date d'expiration
                if let dateExpiration = publicite.dateExpirationDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text("Expire le \(formatDate(dateExpiration))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                } else if let dateFin = publicite.dateFinDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text("Expire le \(formatDate(dateFin))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "photo.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
        }
        .frame(height: 200)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

#Preview {
    ModernPubliciteCard(
        publicite: Publicite(
            id: "1",
            titre: "2 Pizzas Achetées = 1 Offerte",
            description: "Profitez de notre offre exceptionnelle",
            type: "promotion",
            imageUrl: nil,
            sponsorName: "Pizza Express",
            dateExpiration: "2025-12-31"
        ),
        canEdit: true
    )
    .padding()
}
