//
//  CollocatorManagementView.swift
//  DarnaApp
//
//  Vue simplifiée pour gérer les demandes et avis du colocataire

import SwiftUI

struct CollocatorManagementView: View {
    @StateObject private var visitViewModel = VisitViewModel()
    @State private var selectedTab: ManagementTab = .requests
    
    enum ManagementTab: String, CaseIterable {
        case requests = "Demandes en attente"
        case accepted = "Clients acceptés"
        
        var icon: String {
            switch self {
            case .requests: return "person.2.fill"
            case .accepted: return "checkmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .requests: return .orange
            case .accepted: return .green
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Tab Selector
                HStack(spacing: 0) {
                    ForEach(ManagementTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTab = tab
                            }
                        } label: {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 16))
                                    Text(tab.rawValue)
                                        .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                                }
                                .foregroundColor(selectedTab == tab ? tab.color : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                
                                Rectangle()
                                    .fill(selectedTab == tab ? tab.color : Color.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                }
                .background(Color(.systemBackground))
                
                Divider()
                
                // MARK: - Content
                TabView(selection: $selectedTab) {
                    requestsView
                        .tag(ManagementTab.requests)
                    
                    acceptedClientsView
                        .tag(ManagementTab.accepted)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Gestion des réservations")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await visitViewModel.loadInitialData()
            }
        }
    }
    
    // MARK: - Requests View
    private var requestsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                let pendingVisits = visitViewModel.collocatorVisits.filter { $0.status == .pending }
                
                if pendingVisits.isEmpty {
                    emptyStateView(
                        icon: "tray",
                        title: "Aucune demande en attente",
                        message: "Les nouvelles demandes de visite apparaîtront ici"
                    )
                } else {
                    ForEach(pendingVisits) { visit in
                        VisitRequestCard(
                            visit: visit,
                            onAccept: {
                                Task {
                                    await visitViewModel.acceptVisit(visit)
                                }
                            },
                            onReject: {
                                Task {
                                    await visitViewModel.rejectVisit(visit)
                                }
                            }
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Accepted Clients View
    private var acceptedClientsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                let acceptedVisits = visitViewModel.collocatorVisits.filter { $0.status == .confirmed }
                
                if acceptedVisits.isEmpty {
                    emptyStateView(
                        icon: "checkmark.circle",
                        title: "Aucun client accepté",
                        message: "Les clients acceptés apparaîtront ici"
                    )
                } else {
                    ForEach(acceptedVisits) { visit in
                        AcceptedClientCard(visit: visit)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Empty State
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.4))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

// MARK: - Visit Request Card
struct VisitRequestCard: View {
    let visit: Visit
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(visit.clientUsername ?? "Client")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(visit.logementTitle ?? "Logement")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
            }
            
            Divider()
            
            if let date = visit.dateVisite {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text(formatDate(date))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            if let notes = visit.notes, !notes.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "note.text")
                        .foregroundColor(.orange)
                    Text(notes)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            
            Divider()
            
            HStack(spacing: 12) {
                Button(action: onReject) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Refuser")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
                
                Button(action: onAccept) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Accepter")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "fr_FR")
        
        return displayFormatter.string(from: date)
    }
}

// MARK: - Accepted Client Card
struct AcceptedClientCard: View {
    let visit: Visit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(visit.clientUsername ?? "Client")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(visit.logementTitle ?? "Logement")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 24))
            }
            
            Divider()
            
            if let date = visit.dateVisite {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text(formatDate(date))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            if let phone = visit.contactPhone, !phone.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                    Text(phone)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "fr_FR")
        
        return displayFormatter.string(from: date)
    }
}
