//
//  VisitCardView.swift
//  DarnaApp
//
//  Modern, Creative & Elegant Design
//

import SwiftUI

struct VisitCardView: View {
    let visit: Visit
    var subtitle: String?
    var accentColor: Color = AppTheme.primary
    
    var onEdit: (() -> Void)?
    var onCancel: (() -> Void)?
    var onDelete: (() -> Void)?
    var onValidate: (() -> Void)?
    var onReview: (() -> Void)?
    var onAccept: (() -> Void)?
    var onReject: (() -> Void)?
    var onSeeReview: (() -> Void)?
    
    @State private var isPressed = false
    @State private var showActions = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Card Content
            VStack(alignment: .leading, spacing: 0) {
                // Premium Header with Gradient
                premiumHeader
                
                // Card Body
                VStack(alignment: .leading, spacing: 16) {
                    // Subtitle Section
                    if let subtitle {
                        subtitleSection(subtitle)
                    }
                    
                    // Schedule Section with Icon
                    scheduleSection
                    
                    // Contact & Notes
                    if visit.displayContact != "Non renseigné" || (visit.notes != nil && !visit.notes!.isEmpty) {
                        Divider()
                            .background(Color.gray.opacity(0.2))
                    }
                    
                    if visit.displayContact != "Non renseigné" {
                        contactSection
                    }
                    
                    if let notes = visit.notes, !notes.isEmpty {
                        notesSection(notes)
                    }
                }
                .padding(20)
            }
            .background(
                ZStack {
                    // Glassmorphic background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                    
                    // Subtle gradient overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                visit.status.badgeColor.opacity(0.3),
                                visit.status.badgeColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            
            // Action Buttons
            if !availableActions.isEmpty {
                actionSection
                    .padding(.top, 12)
            }
        }
        .shadow(
            color: visit.status.badgeColor.opacity(0.15),
            radius: 20,
            x: 0,
            y: 10
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
    
    // MARK: - Premium Header
    private var premiumHeader: some View {
        HStack(spacing: 16) {
            // Status Indicator Circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                visit.status.badgeColor.opacity(0.8),
                                visit.status.badgeColor
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: visit.status.badgeColor.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: visit.status.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Title & Status
            VStack(alignment: .leading, spacing: 6) {
                Text(visit.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.1, blue: 0.2),
                                Color(red: 0.2, green: 0.2, blue: 0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineLimit(2)
                
                Text(visit.status.displayName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(visit.status.badgeColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(visit.status.badgeColor.opacity(0.15))
                    )
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    visit.status.badgeColor.opacity(0.08),
                    visit.status.badgeColor.opacity(0.03)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    // MARK: - Subtitle Section
    private func subtitleSection(_ subtitle: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Demandeur")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(subtitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Schedule Section
    private var scheduleSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.2), Color.red.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(visit.formattedDate)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text(visit.formattedTime)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.2), Color.teal.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "phone.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(visit.displayContact)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    // MARK: - Notes Section
    private func notesSection(_ notes: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "note.text")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(notes)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
    
    // MARK: - Action Section
    @ViewBuilder
    private var actionSection: some View {
        if availableActions.contains(.accept) {
            // Accept/Reject Buttons (Special Layout)
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        trigger(.accept)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                        Text("Accepter")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        trigger(.reject)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                        Text("Refuser")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red, lineWidth: 2)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.05))
                            )
                    )
                }
            }
        } else {
            // Standard Actions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(availableActions, id: \.self) { action in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                trigger(action)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: action.icon)
                                    .font(.system(size: 14, weight: .semibold))
                                Text(action.label)
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(action.backgroundColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(action.backgroundColor.opacity(0.12))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(action.backgroundColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    private var availableActions: [VisitCardAction] {
        var actions: [VisitCardAction] = []
        if onAccept != nil { actions.append(.accept) }
        if onEdit != nil { actions.append(.edit) }
        if onCancel != nil { actions.append(.cancel) }
        if onDelete != nil { actions.append(.delete) }
        if onValidate != nil { actions.append(.validate) }
        if onReview != nil { actions.append(.rate) }
        if onSeeReview != nil { actions.append(.seeReview) }
        return actions
    }
    
    private func trigger(_ action: VisitCardAction) {
        switch action {
        case .edit: onEdit?()
        case .cancel: onCancel?()
        case .delete: onDelete?()
        case .validate: onValidate?()
        case .rate: onReview?()
        case .accept: onAccept?()
        case .reject: onReject?()
        case .seeReview: onSeeReview?()
        }
    }
}

// MARK: - Visit Card Action
enum VisitCardAction: Hashable {
    case edit
    case cancel
    case delete
    case validate
    case rate
    case accept
    case reject
    case seeReview
    
    var label: String {
        switch self {
        case .edit: return "Modifier"
        case .cancel: return "Annuler"
        case .delete: return "Supprimer"
        case .validate: return "Effectuée"
        case .rate: return "Évaluer"
        case .accept: return "Accepter"
        case .reject: return "Refuser"
        case .seeReview: return "Voir l'avis"
        }
    }
    
    var icon: String {
        switch self {
        case .edit: return "pencil.circle.fill"
        case .cancel: return "xmark.circle.fill"
        case .delete: return "trash.circle.fill"
        case .validate: return "checkmark.seal.fill"
        case .rate: return "star.fill"
        case .accept: return "checkmark.circle.fill"
        case .reject: return "xmark.circle.fill"
        case .seeReview: return "star.bubble.fill"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .edit: return Color.blue
        case .cancel, .delete, .reject: return Color.red
        case .validate, .accept: return Color.green
        case .rate, .seeReview: return Color.orange
        }
    }
}





struct VisitCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                VisitCardView(
                    visit: Visit(
                        id: "1",
                        logementId: "l1",
                        userId: "u1",
                        dateVisite: ISO8601DateFormatter().string(from: Date()),
                        statusRaw: "pending",
                        notes: "Note de test",
                        contactPhone: "12345678",
                        clientUsername: "Test User",
                        logementTitle: "Bel Appartement",
                        validated: false,
                        reviewId: nil
                    ),
                    subtitle: "Client intéressé",
                    onAccept: {},
                    onReject: {}
                )
                .padding()
            }
        }
    }
}
