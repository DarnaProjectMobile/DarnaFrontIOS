//
//  CollocatorDashboardView.swift
//  DarnaApp
//
//  Espace Colocataire amélioré avec design moderne

import SwiftUI

struct CollocatorDashboardView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var visitViewModel = VisitViewModel()
    @State private var properties: [Property] = []
    @State private var isLoadingProperties = false
    @State private var showAddPropertyForm = false
    @State private var editingProperty: Property?
    @State private var propertyPendingDeletion: Property?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Background
                AnimatedBackgroundGradient()
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // MARK: - Premium Header
                        premiumHeader
                            .padding(.top, 20)
                        
                        // MARK: - Statistics Cards
                        statisticsSection
                            .padding(.horizontal)
                        
                        // MARK: - Quick Actions Grid
                        quickActionsGrid
                            .padding(.horizontal)
                        
                        // MARK: - Recent Activity
                        if !visitViewModel.collocatorVisits.isEmpty {
                            recentActivitySection
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
            .sheet(isPresented: $showAddPropertyForm) {
                AddPropertyFormView { newProperty in
                    properties.append(newProperty)
                }
            }
            .sheet(item: $editingProperty) { property in
                AddPropertyFormView(propertyToEdit: property) { updatedProperty in
                    if let index = properties.firstIndex(where: { $0.id == updatedProperty.id }) {
                        properties[index] = updatedProperty
                    }
                }
            }
            .alert(
                "Supprimer l'annonce ?",
                isPresented: Binding(
                    get: { propertyPendingDeletion != nil },
                    set: { if !$0 { propertyPendingDeletion = nil } }
                ),
                presenting: propertyPendingDeletion
            ) { property in
                Button("Annuler", role: .cancel) {
                    propertyPendingDeletion = nil
                }
                Button("Supprimer", role: .destructive) {
                    Task { await deleteProperty(property) }
                }
            } message: { property in
                Text("Cette action supprimera définitivement « \(property.title) ».")
            }
        }
    }
    
    
    // MARK: - Premium Header
    private var premiumHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "0066FF"), Color(hex: "0052CC")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: Color(hex: "0066FF").opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: "house.and.flag.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text("Espace Colocataire")
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
            
            Text("Gérez vos logements et demandes de visite")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vos statistiques")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                CollocatorStatCard(
                    icon: "house.fill",
                    title: "Logements",
                    value: "\(properties.count)",
                    color: Color(hex: "0066FF")
                )
                
                CollocatorStatCard(
                    icon: "person.2.fill",
                    title: "Demandes",
                    value: "\(visitViewModel.collocatorVisits.filter { $0.status == .pending }.count)",
                    color: Color.orange
                )
                
                CollocatorStatCard(
                    icon: "checkmark.circle.fill",
                    title: "Acceptées",
                    value: "\(visitViewModel.collocatorVisits.filter { $0.status == .confirmed }.count)",
                    color: Color.green
                )
                
                CollocatorStatCard(
                    icon: "star.fill",
                    title: "Avis reçus",
                    value: "\(visitViewModel.enrichedReceivedReviews.count)",
                    color: Color.yellow
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
        )
    }
    
    // MARK: - Quick Actions Grid
    private var quickActionsGrid: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Actions rapides")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NavigationLink(destination: CollocatorVisitsView()) {
                    ModernQuickActionCard(
                        icon: "tray.full.fill",
                        title: "Demandes",
                        subtitle: "Gérer les visites",
                        color: Color(hex: "0066FF")
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: VisitManagementView(initialSection: .reviews)) {
                    ModernQuickActionCard(
                        icon: "star.bubble.fill",
                        title: "Avis",
                        subtitle: "Voir les retours",
                        color: Color.orange
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: HomePage()) {
                    ModernQuickActionCard(
                        icon: "house.circle.fill",
                        title: "Logements",
                        subtitle: "Gérer annonces",
                        color: Color.purple
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: ProfileView()) {
                    ModernQuickActionCard(
                        icon: "person.circle.fill",
                        title: "Profil",
                        subtitle: "Paramètres",
                        color: Color.blue
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Activité récente")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Dernières demandes de visite")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                NavigationLink(destination: CollocatorVisitsView()) {
                    HStack(spacing: 4) {
                        Text("Tout voir")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color(hex: "0066FF"))
                }
            }
            
            VStack(spacing: 12) {
                ForEach(Array(visitViewModel.collocatorVisits.prefix(3))) { visit in
                    CompactVisitCard(visit: visit)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
        )
    }
    
    // MARK: - Helper Functions
    private func deleteProperty(_ property: Property) async {
        do {
            try await PropertyService.shared.deleteProperty(id: property.id)
            await MainActor.run {
                properties.removeAll { $0.id == property.id }
                propertyPendingDeletion = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = "Suppression impossible : \(error.localizedDescription)"
                propertyPendingDeletion = nil
            }
        }
    }
    
    private func loadData() async {
        await visitViewModel.loadInitialData()
        await loadProperties()
    }
    
    private func loadProperties() async {
        isLoadingProperties = true
        defer { isLoadingProperties = false }
        
        do {
            properties = try await PropertyService.shared.fetchProperties()
            // Filter only user's properties
            if let userId = authManager.currentUser?.id {
                properties = properties.filter { $0.user == userId }
            }
        } catch {
            print("❌ Erreur chargement logements: \(error)")
        }
    }
}

// MARK: - Collocator Stat Card
struct CollocatorStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.08))
        )
    }
}

// MARK: - Modern Quick Action Card
struct ModernQuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Compact Visit Card
struct CompactVisitCard: View {
    let visit: Visit
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(visit.status.badgeColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: visit.status.icon)
                    .font(.system(size: 16))
                    .foregroundColor(visit.status.badgeColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(visit.clientUsername ?? "Client")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 10))
                    Text(visit.title)
                        .font(.system(size: 12))
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(visit.status.displayName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(visit.status.badgeColor)
                    )
                
                Text(visit.formattedDate)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.5))
        )
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

