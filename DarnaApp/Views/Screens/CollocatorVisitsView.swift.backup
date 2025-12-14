//
//  CollocatorVisitsView.swift
//  DarnaApp
//

import SwiftUI

struct CollocatorVisitsView: View {
    @StateObject private var viewModel = VisitViewModel()
    @State private var selectedStatusFilter: String? = nil
    @State private var rejectingVisitId: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - Status Filters
                    statusFiltersSection
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // MARK: - Content
                    contentSection
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadInitialData()
            }
            .alert("Refuser la demande", isPresented: Binding(
                get: { rejectingVisitId != nil },
                set: { if !$0 { rejectingVisitId = nil } }
            )) {
                Button("Annuler", role: .cancel) {
                    rejectingVisitId = nil
                }
                Button("Refuser", role: .destructive) {
                    if let id = rejectingVisitId {
                        Task {
                            await viewModel.rejectVisit(Visit(
                                id: id,
                                logementId: nil,
                                userId: nil,
                                dateVisite: nil,
                                statusRaw: nil,
                                notes: nil,
                                contactPhone: nil,
                                clientUsername: nil,
                                logementTitle: nil,
                                validated: nil,
                                reviewId: nil
                            ))
                            rejectingVisitId = nil
                        }
                    }
                }
            } message: {
                Text("Êtes-vous sûr de vouloir refuser cette demande de visite ?")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Demandes de visite")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "1A1A1A"))
                    
                    Text("\(filteredVisits.count) demande\(filteredVisits.count > 1 ? "s" : "")")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "757575"))
                }
                
                Spacer()
                
                Button {
                    Task {
                        await viewModel.refreshCollocatorVisits(force: true)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "0066FF").opacity(0.1))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "0066FF"))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white)
    }
    
    // MARK: - Status Filters Section
    private var statusFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatusFilterCard(
                    label: "Toutes",
                    count: allVisitsWithoutCancelled.count,
                    color: Color(hex: "0066FF"),
                    icon: "square.grid.2x2",
                    isSelected: selectedStatusFilter == nil,
                    onClick: { selectedStatusFilter = nil }
                )
                
                StatusFilterCard(
                    label: "En attente",
                    count: pendingCount,
                    color: Color(hex: "F59E0B"),
                    icon: "clock",
                    isSelected: selectedStatusFilter == "pending",
                    onClick: { 
                        selectedStatusFilter = selectedStatusFilter == "pending" ? nil : "pending"
                    }
                )
                
                StatusFilterCard(
                    label: "Acceptée",
                    count: confirmedCount,
                    color: Color(hex: "10B981"),
                    icon: "checkmark.circle",
                    isSelected: selectedStatusFilter == "confirmed",
                    onClick: {
                        selectedStatusFilter = selectedStatusFilter == "confirmed" ? nil : "confirmed"
                    }
                )
                
                StatusFilterCard(
                    label: "Refusée",
                    count: refusedCount,
                    color: Color(hex: "EF4444"),
                    icon: "xmark.circle",
                    isSelected: selectedStatusFilter == "refused",
                    onClick: {
                        selectedStatusFilter = selectedStatusFilter == "refused" ? nil : "refused"
                    }
                )
            }
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Content Section
    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoading && filteredVisits.isEmpty {
            ProgressView("Chargement...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if filteredVisits.isEmpty {
            emptyStateView
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredVisits) { visit in
                        VisitCardView(
                            visit: visit,
                            subtitle: visit.clientUsername,
                            onAccept: visit.status == .pending ? {
                                Task {
                                    await viewModel.acceptVisit(visit)
                                }
                            } : nil,
                            onReject: visit.status == .pending ? {
                                rejectingVisitId = visit.id
                            } : nil
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.4))
            
            Text(selectedStatusFilter != nil ? "Aucune demande \(statusLabel)" : "Aucune demande en cours")
                .font(.headline)
            
            Text(selectedStatusFilter != nil ? "Aucune visite ne correspond à ce filtre." : "Les réservations apparaîtront ici dès qu'un client sollicitera une visite.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Actualiser") {
                Task {
                    await viewModel.refreshCollocatorVisits(force: true)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    private var allVisitsWithoutCancelled: [Visit] {
        viewModel.collocatorVisits.filter { visit in
            visit.status != .cancelled
        }
    }
    
    private var filteredVisits: [Visit] {
        if let filter = selectedStatusFilter {
            return allVisitsWithoutCancelled.filter { visit in
                switch filter {
                case "pending":
                    return visit.status == .pending
                case "confirmed":
                    return visit.status == .confirmed
                case "refused":
                    return visit.status == .refused
                default:
                    return true
                }
            }
        }
        return allVisitsWithoutCancelled
    }
    
    private var pendingCount: Int {
        allVisitsWithoutCancelled.filter { $0.status == .pending }.count
    }
    
    private var confirmedCount: Int {
        allVisitsWithoutCancelled.filter { $0.status == .confirmed }.count
    }
    
    private var refusedCount: Int {
        allVisitsWithoutCancelled.filter { $0.status == .refused }.count
    }
    
    private var statusLabel: String {
        switch selectedStatusFilter {
        case "pending": return "en attente"
        case "confirmed": return "acceptée"
        case "refused": return "refusée"
        default: return ""
        }
    }
}

// MARK: - Status Filter Card
struct StatusFilterCard: View {
    let label: String
    let count: Int
    let color: Color
    let icon: String
    let isSelected: Bool
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 13, weight: isSelected ? .bold : .regular))
                        .foregroundColor(color)
                    
                    Text("\(count)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(isSelected ? 0.2 : 0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: isSelected ? 2 : 1)
                    .opacity(isSelected ? 1 : 0.5)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
