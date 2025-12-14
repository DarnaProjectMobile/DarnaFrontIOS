//
//  HomePage.swift
//  DarnaApp
//

import SwiftUI

struct HomePage: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var properties: [Property] = []
    @State private var filteredProperties: [Property] = []
    @State private var navigationPath = NavigationPath()
    @State private var showAddPropertyForm = false
    @State private var editingProperty: Property?
    @State private var propertyPendingDeletion: Property?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    @State private var searchText: String = ""
    @State private var showFilterSheet = false
    @State private var minPrice: Double? = nil
    @State private var maxPrice: Double? = nil
    @State private var ownershipFilter: OwnershipFilter = .all
    @FocusState private var isSearchFocused: Bool
    @State private var showMap = false
    
    private enum OwnershipFilter {
        case all
        case mine
        case notMine
    }

    var currentUserRole: String {
        authManager.currentUser?.role ?? "guest"
    }
    
    var currentUserId: String? {
        authManager.currentUser?.id
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    searchAndFilterBar
                    quickFilterButtons
                    
                    if isLoading {
                        ProgressView("Chargement des annonces...")
                            .progressViewStyle(.circular)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredProperties.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Aucune annonce trouvÃ©e")
                                .font(.headline)
                            Text("Essayez de modifier votre recherche ou vos filtres.")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(filteredProperties) { property in
                                    NavigationLink(value: property) {
                                        PropertyCardView(
                                            property: property,
                                            canManage: canManage(property: property),
                                            onEdit: {
                                                editingProperty = property
                                            },
                                            onDelete: {
                                                propertyPendingDeletion = property
                                            }
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .contentShape(Rectangle())
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .refreshable {
                            await loadProperties()
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, currentUserRole == "collocator" ? 110 : 70)

                // Bottom overlay buttons
                ZStack(alignment: .bottom) {
                    // Map pill button (always visible, centered)
                    Button {
                        showMap = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Carte des annonces")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(AppTheme.primary)
                        .cornerRadius(999)
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                    }
                    .padding(.bottom, 24)
                    
                    // Floating Add Button (only for collocators, bottom trailing)
                    if currentUserRole == "collocator" {
                        HStack {
                            Spacer()
                            Button {
                                showAddPropertyForm = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppTheme.primary)
                                    .background(Circle().fill(Color.white)) // White background for better contrast
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
                            }
                            .padding(.trailing, 24)
                            .padding(.bottom, 24)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Accueil")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        NavigationLink(destination: NotificationView()) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(AppTheme.primary)
                                .font(.system(size: 20))
                        }
                        
                        NavigationLink(destination: MyReviewsView()) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 20))
                        }
                    }
                }
            }
            .task {
                await loadProperties()
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheetView(minPrice: $minPrice, maxPrice: $maxPrice, onApply: applyFilters)
                    .presentationDetents([.fraction(0.35)])
            }
            .sheet(isPresented: $showMap) {
                PropertyMapView(properties: filteredProperties)
            }
            .navigationDestination(for: Property.self) { property in
                PropertyDetailPage(property: property)
            }
            .sheet(isPresented: $showAddPropertyForm) {
                AddPropertyFormView { newProperty in
                    properties.append(newProperty)
                    applyFilters()
                }
            }
            .sheet(item: $editingProperty) { property in
                AddPropertyFormView(propertyToEdit: property) { updatedProperty in
                    if let index = properties.firstIndex(where: { $0.id == updatedProperty.id }) {
                        properties[index] = updatedProperty
                        applyFilters()
                    }
                }
            }
            .alert(
                "Supprimer lâ€™annonce ?",
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
                Text("Cette action supprimera dÃ©finitivement Â« \(property.title) Â».")
            }
        }
    }

    private func loadProperties() async {
        isLoading = true
        errorMessage = nil
        do {
            properties = try await PropertyService.shared.fetchProperties()
            applyFilters()
        } catch {
            print("❌ Error loading properties: \(error)")
            // Ignore cancellation errors
            if let urlError = error as? URLError, urlError.code == .cancelled {
                isLoading = false
                return
            }
            if error is CancellationError {
                isLoading = false
                return
            }
            
            errorMessage = "Erreur de chargement: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    private func canManage(property: Property) -> Bool {
        guard currentUserRole == "collocator",
              let currentUserId else { return false }
        return property.user == currentUserId
    }
    
    private func deleteProperty(_ property: Property) async {
        do {
            try await PropertyService.shared.deleteProperty(id: property.id)
            await MainActor.run {
                properties.removeAll { $0.id == property.id }
                applyFilters()
                propertyPendingDeletion = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = "Suppression impossible : \(error.localizedDescription)"
                propertyPendingDeletion = nil
            }
        }
    }
    
    private func applyFilters() {
        filteredProperties = properties.filter { property in
            let matchesSearch = searchText.isEmpty || property.title.lowercased().contains(searchText.lowercased())
            
            let matchesMinPrice: Bool
            if let minPrice = minPrice {
                matchesMinPrice = property.price >= minPrice
            } else {
                matchesMinPrice = true
            }
            
            let matchesMaxPrice: Bool
            if let maxPrice = maxPrice {
                matchesMaxPrice = property.price <= maxPrice
            } else {
                matchesMaxPrice = true
            }
            
            let matchesOwnership: Bool
            switch ownershipFilter {
            case .all:
                matchesOwnership = true
            case .mine:
                matchesOwnership = property.user == currentUserId
            case .notMine:
                matchesOwnership = property.user != currentUserId
            }
            
            return matchesSearch && matchesMinPrice && matchesMaxPrice && matchesOwnership
        }
    }
    
    private var searchAndFilterBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.textSecondary)
                TextField("Rechercher une annonce", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($isSearchFocused)
                    .onChange(of: searchText) { _ in
                        applyFilters()
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        applyFilters()
                        isSearchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppTheme.card)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            Button {
                showFilterSheet = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.onPrimary)
                    .frame(width: 48, height: 48)
                    .background(AppTheme.primary)
                    .cornerRadius(14)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var quickFilterButtons: some View {
        HStack(spacing: 12) {
            OwnershipFilterButton(
                title: "Mes annonces",
                isSelected: ownershipFilter == .mine,
                icon: "person.fill"
            ) {
                ownershipFilter = ownershipFilter == .mine ? .all : .mine
                applyFilters()
            }
            
            OwnershipFilterButton(
                title: "Non possédé par moi",
                isSelected: ownershipFilter == .notMine,
                icon: "person.2.fill"
            ) {
                ownershipFilter = ownershipFilter == .notMine ? .all : .notMine
                applyFilters()
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct OwnershipFilterButton: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? AppTheme.onPrimary : AppTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? AppTheme.primary : AppTheme.card)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

private struct FilterSheetView: View {
    @Binding var minPrice: Double?
    @Binding var maxPrice: Double?
    var onApply: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Filtrer par prix")
                    .font(.headline)
                Spacer()
                Button {
                    minPrice = nil
                    maxPrice = nil
                    onApply()
                } label: {
                    Text("RÃ©initialiser")
                        .font(.caption)
                        .foregroundColor(AppTheme.primary)
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                PriceField(title: "Prix minimum", value: Binding(
                    get: { minPrice.map { String(format: "%.0f", $0) } ?? "" },
                    set: { newValue in
                        if let doubleValue = Double(newValue) {
                            minPrice = doubleValue
                        } else {
                            minPrice = nil
                        }
                    }
                ))
                
                PriceField(title: "Prix maximum", value: Binding(
                    get: { maxPrice.map { String(format: "%.0f", $0) } ?? "" },
                    set: { newValue in
                        if let doubleValue = Double(newValue) {
                            maxPrice = doubleValue
                        } else {
                            maxPrice = nil
                        }
                    }
                ))
            }
            
            Button {
                onApply()
                dismiss()
            } label: {
                Text("Appliquer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.primary)
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(AppTheme.background)
    }
}

private struct PriceField: View {
    let title: String
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextField("0", text: $value)
                .keyboardType(.numberPad)
                .padding(12)
                .background(AppTheme.card)
                .cornerRadius(12)
        }
    }
}

// MARK: - NotificationView (Added directly to ensure visibility without Xcode project manipulation)
struct NotificationView: View {
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if notificationService.notifications.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Aucune notification")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Vous serez notifié des mises à jour importantes ici.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(notificationService.notifications) { notification in
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primary.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(AppTheme.primary)
                                        .font(.system(size: 18))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notification.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(notification.body)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    
                                    Text(formatDate(notification.date))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                if !notificationService.notifications.isEmpty {
                    Button("Effacer tout") {
                        notificationService.clearAll()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}
