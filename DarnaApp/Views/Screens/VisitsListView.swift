//
//  VisitsListView.swift
//  DarnaApp
//

import SwiftUI

struct VisitsListView: View {
    @ObservedObject var visitStore: VisitStore
    let userId: UUID
    let isOwner: Bool
    
    @State private var selectedStatus: VisitStatus? = nil
    @State private var showVisitDetail: VisitModel? = nil
    
    private var filteredVisits: [VisitModel] {
        let userVisits = visitStore.getVisitsForUser(userId: userId, isOwner: isOwner)
        if let status = selectedStatus {
            return userVisits.filter { $0.status == status }
        }
        return userVisits.filter { $0.isUpcoming || $0.status == .pending }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterPill(
                        title: "Toutes",
                        isSelected: selectedStatus == nil
                    ) {
                        selectedStatus = nil
                    }
                    
                    ForEach(VisitStatus.allCases) { status in
                        FilterPill(
                            title: status.displayName,
                            isSelected: selectedStatus == status
                        ) {
                            selectedStatus = status
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            
            Divider()
            
            // Visits List
            if filteredVisits.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.primary.opacity(0.5))
                    Text("Aucune visite")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Vous n'avez aucune visite \(selectedStatus?.displayName.lowercased() ?? "")")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredVisits) { visit in
                            VisitCardView(visit: visit, isOwner: isOwner) {
                                showVisitDetail = visit
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $showVisitDetail) { visit in
            VisitDetailView(visit: visit, visitStore: visitStore, isOwner: isOwner)
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? AppTheme.onPrimary : AppTheme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primary : AppTheme.primaryLight)
                .cornerRadius(20)
        }
    }
}

