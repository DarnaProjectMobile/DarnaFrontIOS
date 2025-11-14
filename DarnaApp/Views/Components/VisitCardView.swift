//
//  VisitCardView.swift
//  DarnaApp
//

import SwiftUI

struct VisitCardView: View {
    let visit: VisitModel
    let isOwner: Bool
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(visit.propertyTitle)
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(isOwner ? visit.tenantName : visit.ownerName)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: visit.status)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(AppTheme.primary)
                    Text(formatDate(visit.scheduledDate))
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "clock")
                        .foregroundColor(AppTheme.primary)
                    Text(formatTime(visit.scheduledDate))
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                if let notes = visit.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }
                
                if visit.status == .rescheduled, let altDate = visit.proposedAlternativeDate {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.orange)
                        Text("Nouvelle date proposée: \(formatDate(altDate))")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(AppTheme.card)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

struct StatusBadge: View {
    let status: VisitStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.15))
            .foregroundColor(statusColor)
            .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .accepted: return .blue
        case .rejected: return .red
        case .rescheduled: return .yellow
        case .completed: return .green
        case .cancelled: return .gray
        }
    }
}

