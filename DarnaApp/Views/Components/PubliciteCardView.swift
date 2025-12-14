//
//  PubliciteCardView.swift
//  DarnaApp
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
                    .buttonStyle(BorderlessButtonStyle())
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
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    
                    if let onEdit = onEdit {
                        Button {
                            onEdit()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Modifier")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.18))
                            .cornerRadius(10)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    
                    if let onDelete = onDelete {
                        Button {
                            onDelete()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Supprimer")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.18))
                            .cornerRadius(10)
                        }
                        .buttonStyle(BorderlessButtonStyle())
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

// MARK: - RouletteView Component
/// Vue principale de la roue de la fortune
struct RouletteView: View {
    let config: RouletteConfig
    @Binding var rotation: Double
    @Binding var isSpinning: Bool
    var hasPlayedGame: Bool = false
    let onSpin: () -> Void
    
    private let wheelSize: CGFloat = 280
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                // Indicateur en haut (flèche pointant vers le bas)
                VStack {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 30))
                        .foregroundColor(AppTheme.primary)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    Spacer()
                }
                .zIndex(10)
                
                // La roue elle-même
                ZStack {
                    // Ombre de la roue
                    Circle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: wheelSize + 10, height: wheelSize + 10)
                        .blur(radius: 10)
                        .offset(y: 5)
                    
                    // Roue avec segments
                    ZStack {
                        ForEach(0..<config.options.count, id: \.self) { index in
                            let anglePerSegment = 360.0 / Double(config.options.count)
                            let startAngle = anglePerSegment * Double(index) - 90
                            let endAngle = startAngle + anglePerSegment
                            
                            RouletteSegmentView(
                                text: config.options[index],
                                color: config.segmentColors[index],
                                startAngle: startAngle,
                                endAngle: endAngle,
                                radius: wheelSize / 2
                            )
                        }
                    }
                    .frame(width: wheelSize, height: wheelSize)
                    .rotationEffect(Angle(degrees: rotation))
                    .animation(
                        isSpinning ? .easeOut(duration: RouletteEngine.spinDuration) : .default,
                        value: rotation
                    )
                    
                    // Centre de la roue
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.gray.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(AppTheme.primary, lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .frame(width: wheelSize, height: wheelSize)
            }
            .padding(.top, 20)
            
            // Bouton de lancement (caché si déjà joué)
            if !hasPlayedGame {
                Button(action: {
                    if !isSpinning {
                        onSpin()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: isSpinning ? "hourglass" : "play.fill")
                            .font(.system(size: 20))
                        Text(isSpinning ? "En cours..." : "Tourner la roue")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: isSpinning ? [Color.gray, Color.gray.opacity(0.8)] : [AppTheme.primary, AppTheme.primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: AppTheme.primary.opacity(isSpinning ? 0 : 0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isSpinning)
                .padding(.horizontal, 30)
            }
        }
    }
}
