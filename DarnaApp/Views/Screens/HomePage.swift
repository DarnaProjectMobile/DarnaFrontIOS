//
//  HomePage.swift
//  DarnaApp
//

import SwiftUI

struct HomePage: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var properties: [Property] = []
    @State private var showAddPropertyForm = false
    @State private var editingProperty: Property?
    @State private var propertyPendingDeletion: Property?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var currentUserRole: String {
        authManager.currentUser?.role ?? "guest"
    }
    
    var currentUserId: String? {
        authManager.currentUser?.id
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppTheme.background.ignoresSafeArea()

                if isLoading {
                        ProgressView("Chargement des annonces...")
                        .progressViewStyle(.circular)
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(properties) { property in
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
                            }
                        }
                        .padding(.top, 20)
                    }
                }

                // ✅ Floating Add Button (only for collocators)
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
                "Supprimer l’annonce ?",
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

    private func loadProperties() async {
        do {
            properties = try await PropertyService.shared.fetchProperties()
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
                propertyPendingDeletion = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = "Suppression impossible : \(error.localizedDescription)"
                propertyPendingDeletion = nil
            }
        }
    }
}
