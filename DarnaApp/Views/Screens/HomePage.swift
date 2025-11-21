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
    @FocusState private var isSearchFocused: Bool

    var currentUserRole: String {
        authManager.currentUser?.role ?? "guest"
    }
    
    var currentUserId: String? {
        authManager.currentUser?.id
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottomTrailing) {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    searchAndFilterBar
                    
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
                                    .padding(.horizontal, 16)
                                    .onTapGesture {
                                        navigationPath.append(property)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, currentUserRole == "collocator" ? 100 : 24)

                // âœ… Floating Add Button (only for collocators)
                if currentUserRole == "collocator" {
                    Button {
                        showAddPropertyForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.primary)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Accueil")
            .task {
                await loadProperties()
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheetView(minPrice: $minPrice, maxPrice: $maxPrice, onApply: applyFilters)
                    .presentationDetents([.fraction(0.35)])
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
        do {
            properties = try await PropertyService.shared.fetchProperties()
            applyFilters()
        } catch {
            errorMessage = "Impossible de charger les annonces."
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
            
            return matchesSearch && matchesMinPrice && matchesMaxPrice
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