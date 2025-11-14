//
//  VisitHistoryView.swift
//  DarnaApp
//

import SwiftUI

struct VisitHistoryView: View {
    @ObservedObject var visitStore: VisitStore
    let userId: UUID
    let isOwner: Bool
    
    @State private var showEvaluation: VisitModel? = nil
    
    private var pastVisits: [VisitModel] {
        visitStore.getPastVisits(userId: userId, isOwner: isOwner)
    }
    
    private var groupedVisits: [String: [VisitModel]] {
        Dictionary(grouping: pastVisits) { visit in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.string(from: visit.scheduledDate)
        }
    }
    
    var body: some View {
        ScrollView {
            if pastVisits.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.primary.opacity(0.5))
                    Text("Aucun historique")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Vos visites passées apparaîtront ici")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(Array(groupedVisits.keys.sorted(by: >)), id: \.self) { month in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(month)
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal)
                            
                            ForEach(groupedVisits[month] ?? []) { visit in
                                VisitHistoryCardView(visit: visit, isOwner: isOwner) {
                                    if visit.canBeEvaluated {
                                        showEvaluation = visit
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .sheet(item: $showEvaluation) { visit in
            VisitEvaluationView(visit: visit, visitStore: visitStore)
        }
    }
}

struct VisitHistoryCardView: View {
    let visit: VisitModel
    let isOwner: Bool
    let onEvaluate: () -> Void
    
    var body: some View {
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
                    .foregroundColor(AppTheme.textSecondary)
                Text(formatDate(visit.scheduledDate))
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                if visit.canBeEvaluated {
                    Button {
                        onEvaluate()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                            Text("Évaluer")
                        }
                        .font(.caption)
                        .foregroundColor(AppTheme.primary)
                    }
                } else if let rating = visit.rating {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                }
            }
            
            if let notes = visit.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(8)
                    .background(AppTheme.primaryLight)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

