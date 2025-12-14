//
//  VisitManagementView.swift
//  DarnaApp
//
//  Modern, Creative & Elegant Design
//

import SwiftUI

enum VisitDashboardSection: String, CaseIterable, Identifiable {
    case reserve = "Réserver"
    case myVisits = "Mes visites"
    case requests = "Demandes"
    case reviews = "Reviews"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .reserve: return "calendar.badge.plus"
        case .myVisits: return "list.bullet.clipboard"
        case .requests: return "person.2.fill"
        case .reviews: return "star.bubble.fill"
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .reserve: return [Color(red: 0.2, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.2, blue: 0.9)]
        case .myVisits: return [Color.orange, Color.red]
        case .requests: return [Color.purple, Color.pink]
        case .reviews: return [Color.yellow, Color.orange]
        }
    }
}

struct VisitManagementView: View {
    @StateObject private var viewModel = VisitViewModel()
    @ObservedObject private var authManager = AuthenticationManager.shared
    
    @State private var selectedSection: VisitDashboardSection
    @State private var myVisitFilter: VisitStatus?
    @State private var requestFilter: VisitStatus?
    
    @State private var editingVisit: Visit?
    @State private var reviewingVisit: Visit?
    @State private var selectedReview: EnrichedReview?
    @State private var animateGradient = false
    
    init(initialSection: VisitDashboardSection = .reserve) {
        _selectedSection = State(initialValue: initialSection)
    }
    
    // Sections dynamiques selon le rôle
    private var availableSections: [VisitDashboardSection] {
        if let role = authManager.currentUser?.role?.lowercased(), 
           (role == "colocataire" || role == "collocator") {
            return [.reviews]
        }
        return [.reserve, .myVisits]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Background
                AnimatedBackgroundGradient()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Premium Header
                        premiumHeader
                            .padding(.top, 20)
                        
                        // Modern Segmented Control
                        modernSegmentedControl
                            .padding(.horizontal)
                        
                        // Content
                        content
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadInitialData()
        }
        .onAppear {
            // Sélectionner automatiquement la première section disponible
            if !availableSections.contains(selectedSection) {
                selectedSection = availableSections.first ?? .reserve
            }
        }
        .alert("Erreur", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearFeedback() } }
        )) {
            Button("OK", role: .cancel) { viewModel.clearFeedback() }
        } message: {
            Text(viewModel.errorMessage ?? "Une erreur est survenue")
        }
        .alert("Succès", isPresented: Binding(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.clearFeedback() } }
        )) {
            Button("OK", role: .cancel) { viewModel.clearFeedback() }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .sheet(item: $editingVisit) { visit in
            VisitEditSheet(viewModel: viewModel, visit: visit)
        }
        .sheet(item: $reviewingVisit) { visit in
            VisitReviewSheet(viewModel: viewModel, visit: visit)
        }
        .sheet(item: $selectedReview) { enriched in
            NavigationStack {
                ScrollView {
                    ReviewCard(enriched: enriched, isReceivedReview: true)
                        .padding()
                }
                .navigationTitle("Avis du client")
                .navigationBarTitleDisplayMode(.inline)
                .presentationDetents([.medium])
            }
        }
    }
    
    // MARK: - Premium Header
    private var premiumHeader: some View {
        VStack(spacing: 16) {
            // Icon with Gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: selectedSection.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: selectedSection.gradient[0].opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: selectedSection.icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: selectedSection)
            
            // Title
            Text("Gestion des visites")
                .font(.system(size: 32, weight: .bold))
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
            
            // Subtitle
            if let role = authManager.currentUser?.role?.lowercased(), 
               (role == "colocataire" || role == "collocator") {
                Text("Gérez vos demandes de visites et consultez vos avis")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Réservez et suivez vos visites de logements")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Modern Segmented Control
    private var modernSegmentedControl: some View {
        HStack(spacing: 12) {
            ForEach(availableSections) { section in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedSection = section
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: section.icon)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(section.rawValue)
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(selectedSection == section ? .white : .primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            if selectedSection == section {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: section.gradient,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: section.gradient[0].opacity(0.4), radius: 15, x: 0, y: 8)
                            } else {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.5))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Content
    @ViewBuilder
    private var content: some View {
        switch selectedSection {
        case .reserve:
            VisitReservationView(viewModel: viewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        case .myVisits:
            visitList(
                visits: viewModel.myVisits,
                filter: $myVisitFilter,
                emptyMessage: "Réservez votre première visite pour la voir apparaître ici."
            )
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        case .requests:
            visitRequests(
                visits: viewModel.collocatorVisits,
                filter: $requestFilter
            )
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        case .reviews:
            ReviewsListView(
                reviews: viewModel.enrichedReceivedReviews,
                isLoading: viewModel.isLoading,
                isReceivedReview: true
            )
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
    }
    
    // MARK: - Visit List
    private func visitList(
        visits: [Visit],
        filter: Binding<VisitStatus?>,
        emptyMessage: String
    ) -> some View {
        VStack(spacing: 16) {
            // ✨ Statistics Summary Card
            if !visits.isEmpty {
                VisitStatisticsCard(visits: visits)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
            
            modernFilterChips(selection: filter)
            
            if viewModel.isLoading && visits.isEmpty {
                LoadingView()
                    .padding(.top, 60)
            } else if filtered(visits, with: filter.wrappedValue).isEmpty {
                modernEmptyState(message: emptyMessage, icon: "calendar.badge.plus")
                    .padding(.top, 60)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(filtered(visits, with: filter.wrappedValue)) { visit in
                        SafeVisitCard(
                            visit: visit,
                            subtitle: visit.clientUsername ?? "Ma réservation",
                            onEdit: visit.canEdit ? { editingVisit = visit } : nil,
                            onCancel: visit.canCancel ? { Task { await viewModel.cancelVisit(visit) } } : nil,
                            onDelete: visit.canDelete ? { Task { await viewModel.deleteVisit(visit) } } : nil,
                            onValidate: visit.canValidate ? { Task { await viewModel.validateVisit(visit) } } : nil,
                            onReview: visit.canRate ? { reviewingVisit = visit } : nil,
                            onSeeReview: visit.reviewId != nil ? {
                                Task {
                                    // Tenter de trouver l'avis dans ceux déjà chargés
                                    if let existingEnriched = viewModel.enrichedGivenReviews.first(where: { $0.visit.id == visit.id }) {
                                        selectedReview = existingEnriched
                                    } else {
                                        // Sinon charger dynamiquement
                                        await viewModel.loadReviews(for: visit)
                                        if let loadedReview = viewModel.reviews.first {
                                            selectedReview = EnrichedReview(review: loadedReview, visit: visit)
                                        }
                                    }
                                }
                            } : nil
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
            }
        }
    }
    
    // MARK: - Visit Requests
    private func visitRequests(
        visits: [Visit],
        filter: Binding<VisitStatus?>
    ) -> some View {
        VStack(spacing: 16) {
            modernFilterChips(selection: filter)
            
            if viewModel.isLoading && visits.isEmpty {
                LoadingView()
                    .padding(.top, 60)
            } else if filtered(visits, with: filter.wrappedValue).isEmpty {
                modernEmptyState(message: "Aucune demande reçue pour l'instant.", icon: "person.2.slash")
                    .padding(.top, 60)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(filtered(visits, with: filter.wrappedValue)) { visit in
                        SafeVisitCard(
                            visit: visit,
                            subtitle: visit.clientUsername ?? "Client",
                            // accentColor ignoré car SafeVisitCard ne l'a pas
                            onAccept: visit.status == .pending ? { Task { await viewModel.acceptVisit(visit) } } : nil,
                            onReject: visit.status == .pending ? { Task { await viewModel.rejectVisit(visit) } } : nil,
                            onSeeReview: visit.reviewId != nil ? {
                                Task {
                                    // Charger l'avis si nécessaire ou le trouver dans enrichedReceivedReviews
                                    if let existingEnriched = viewModel.enrichedReceivedReviews.first(where: { $0.visit.id == visit.id }) {
                                        selectedReview = existingEnriched
                                    } else {
                                        // Charger dynamiquement
                                        await viewModel.loadReviews(for: visit)
                                        if let loadedReview = viewModel.reviews.first {
                                            selectedReview = EnrichedReview(review: loadedReview, visit: visit)
                                        }
                                    }
                                }
                            } : nil
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
            }
        }
    }
    
    // MARK: - Modern Filter Chips
    private func modernFilterChips(selection: Binding<VisitStatus?>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // "Toutes" chip
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection.wrappedValue = nil
                    }
                } label: {
                    Text("Toutes")
                        .modernChipStyle(
                            isSelected: selection.wrappedValue == nil,
                            color: .blue
                        )
                }
                
                // Status chips
                ForEach(VisitStatus.dashboardFilters) { status in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selection.wrappedValue = selection.wrappedValue == status ? nil : status
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: status.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(status.displayName)
                        }
                        .modernChipStyle(
                            isSelected: selection.wrappedValue == status,
                            color: status.badgeColor
                        )
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Helper Functions
    private func filtered(_ visits: [Visit], with filter: VisitStatus?) -> [Visit] {
        guard let filter else { return visits }
        return visits.filter { $0.status == filter }
    }
    
    // MARK: - Modern Empty State
    private func modernEmptyState(message: String, icon: String) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.gray, .gray.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
        )
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
            }
            
            Text("Chargement...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - View Extensions
private extension View {
    func modernChipStyle(isSelected: Bool, color: Color) -> some View {
        self
            .font(.system(size: 13, weight: .bold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            )
            .foregroundColor(isSelected ? .white : .primary)
            .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

// MARK: - Visit Statistics Card
struct VisitStatisticsCard: View {
    let visits: [Visit]
    
    private var statistics: VisitStatistics {
        VisitStatistics(visits: visits)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Résumé de vos visites")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(visits.count) visite\(visits.count > 1 ? "s" : "") au total")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Statistics Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatisticItemView(
                    title: "En attente",
                    count: statistics.pendingCount,
                    icon: "clock.fill",
                    color: .orange
                )
                
                StatisticItemView(
                    title: "Acceptées",
                    count: statistics.confirmedCount,
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatisticItemView(
                    title: "Terminées",
                    count: statistics.completedCount,
                    icon: "checkmark.seal.fill",
                    color: .blue
                )
                
                StatisticItemView(
                    title: "Annulées",
                    count: statistics.cancelledCount + statistics.refusedCount,
                    icon: "xmark.circle.fill",
                    color: .red
                )
            }
            
            // Active Visit Indicator
            if statistics.hasActiveVisit {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    
                    Text("Vous avez une visite active")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .blue.opacity(0.1), radius: 15, x: 0, y: 8)
        )
    }
}

// MARK: - Statistic Item View
struct StatisticItemView: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text("\(count)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.08))
        )
    }
}

// MARK: - Visit Statistics Model
struct VisitStatistics {
    let pendingCount: Int
    let confirmedCount: Int
    let completedCount: Int
    let cancelledCount: Int
    let refusedCount: Int
    let hasActiveVisit: Bool
    
    init(visits: [Visit]) {
        pendingCount = visits.filter { $0.status == .pending }.count
        confirmedCount = visits.filter { $0.status == .confirmed }.count
        completedCount = visits.filter { $0.status == .completed || $0.status == .validated }.count
        cancelledCount = visits.filter { $0.status == .cancelled }.count
        refusedCount = visits.filter { $0.status == .refused }.count
        hasActiveVisit = visits.contains { $0.status == .pending || $0.status == .confirmed }
    }
}

// MARK: - Safe Visit Card (Anti-Crash Version)
struct SafeVisitCard: View {
    let visit: Visit
    let subtitle: String
    
    // Actions Client
    var onEdit: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onValidate: (() -> Void)? = nil
    var onReview: (() -> Void)? = nil
    
    // Actions Collocateur
    var onAccept: (() -> Void)? = nil
    var onReject: (() -> Void)? = nil
    var onSeeReview: (() -> Void)? = nil
    
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(visit.logementTitle ?? "Logement sans titre")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                SafeStatusBadge(status: visit.status)
            }
            
            Divider()
            
            // Info Row
            HStack(spacing: 20) {
                // Date
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                    Text(formatDate(visit.dateVisite))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            // Phone (if available)
            if let phone = visit.contactPhone, !phone.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                    Text(phone)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            // Notes (if available)
            if let notes = visit.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Actions Row
            if hasActions {
                Divider()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Client Actions
                        if let onEdit = onEdit {
                            ActionButton(icon: "pencil", label: "Modifier", color: .blue, action: onEdit)
                        }
                        
                        if let onCancel = onCancel {
                            ActionButton(icon: "xmark.circle", label: "Annuler", color: .orange, action: onCancel)
                        }
                        
                        if let onDelete = onDelete {
                            ActionButton(icon: "trash", label: "Supprimer", color: .red, action: onDelete)
                        }
                        
                        if let onValidate = onValidate {
                            ActionButton(icon: "checkmark.seal.fill", label: "Confirmer visite", color: .purple, action: onValidate)
                        }
                        
                        if let onReview = onReview {
                            ActionButton(icon: "star.fill", label: "Noter", color: .yellow, action: onReview)
                        }
                        
                        // Collocator Actions
                        if let onAccept = onAccept {
                            ActionButton(icon: "checkmark", label: "Accepter", color: .green, action: onAccept)
                        }
                        
                        if let onReject = onReject {
                            ActionButton(icon: "xmark", label: "Refuser", color: .red, action: onReject)
                        }
                        
                        if let onSeeReview = onSeeReview {
                            ActionButton(icon: "eye.fill", label: "Voir avis", color: .blue, action: onSeeReview)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var hasActions: Bool {
        onEdit != nil || onCancel != nil || onDelete != nil || onValidate != nil || onReview != nil ||
        onAccept != nil || onReject != nil || onSeeReview != nil
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "Date inconnue" }
        // Simple formatter, can be improved
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            let display = DateFormatter()
            display.dateStyle = .medium
            display.timeStyle = .short
            display.locale = Locale(identifier: "fr_FR")
            return display.string(from: date)
        }
        return dateString
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label)
            }
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(20)
        }
    }
}

struct SafeStatusBadge: View {
    let status: VisitStatus
    
    var body: some View {
        Text(statusLabel)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .clipShape(Capsule())
    }
    
    var statusLabel: String {
        switch status {
        case .pending: return "En attente"
        case .confirmed: return "Acceptée"
        case .refused: return "Refusée"
        case .cancelled: return "Annulée"
        case .completed: return "Terminée"
        case .validated: return "Validée"
        case .unknown: return "Inconnu"
        }
    }
    
    var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .green
        case .refused: return .red
        case .cancelled: return .gray
        case .completed: return .blue
        case .validated: return .purple
        case .unknown: return .gray
        }
    }
}
