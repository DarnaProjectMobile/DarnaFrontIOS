
//
//  PubliciteCardView.swift
//  DarnaApp
//
//  Modern, Creative & Elegant Design
//

import SwiftUI

struct PubliciteCardView: View {
    let publicite: Publicite
    var isSponsor: Bool = false
    var onAdd: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Image Header
            ZStack(alignment: .topTrailing) {
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
                            ZStack {
                                imagePlaceholder
                                ProgressView()
                                    .tint(.white)
                            }
                        @unknown default:
                            imagePlaceholder
                        }
                    }
                } else {
                    imagePlaceholder
                }
                
                // Overlay Gradient
                LinearGradient(
                    colors: [.black.opacity(0.4), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
                
                // Status Badge
                statusBadge
                    .padding(12)
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .clipped()
            
            // MARK: - Content
            VStack(alignment: .leading, spacing: 16) {
                // Title & Discount
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(publicite.type.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(publicite.titre)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if let pourcentage = publicite.pourcentageReduction {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            VStack(spacing: 0) {
                                Text("-\(Int(pourcentage))%")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text("OFF")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                }
                
                // Description
                Text(publicite.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                    .background(Color.gray.opacity(0.1))
                
                // Footer: Dates & Actions
                HStack {
                    // Dates
                    if let debut = publicite.dateDebutDate, let fin = publicite.dateFinDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("\(formatDate(debut)) - \(formatDate(fin))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Sponsor Actions
                    if isSponsor {
                        Menu {
                            if let onAdd = onAdd {
                                Button(action: onAdd) {
                                    Label("Nouvelle pub", systemImage: "plus")
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
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                        }
                    }
                }
            }
            .padding(20)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var imagePlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    private var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(publicite.isActive ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .shadow(color: (publicite.isActive ? Color.green : Color.red).opacity(0.5), radius: 4)
            
            Text(publicite.isActive ? "ACTIF" : "EXPIRÉ")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .tracking(0.5)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}
