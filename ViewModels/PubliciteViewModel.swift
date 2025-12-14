//
//  PubliciteViewModel.swift
//  DarnaApp
//

import Foundation
import Combine

@MainActor
final class PubliciteViewModel: ObservableObject {
    @Published var publicites: [Publicite] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage = ""
    @Published private(set) var isSponsor = false
    
    private let service: PubliciteServiceProtocol
    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()
    private let sponsorRoles: Set<UserType> = [.admin]
    
    init(
        service: PubliciteServiceProtocol = PubliciteService.shared,
        authManager: AuthManager = .shared
    ) {
        self.service = service
        self.authManager = authManager
        updateSponsorStatus()
        
        authManager.$currentUser
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateSponsorStatus()
            }
            .store(in: &cancellables)
    }
    
    private func updateSponsorStatus() {
        guard let role = authManager.currentUser?.role else {
            isSponsor = false
            return
        }
        isSponsor = sponsorRoles.contains(role)
    }
    
    // MARK: - Load
    func loadPublicites() async {
        await performRequest {
            publicites = try await service.fetchPublicites()
        }
    }
    
    // MARK: - Create
    func createPublicite(_ dto: PubliciteDTO) async -> Bool {
        return await performRequest {
            let created = try await service.createPublicite(dto)
            publicites.insert(created, at: 0)
            successMessage = "Publicité créée avec succès"
            showSuccess = true
        }
    }
    
    // MARK: - Update
    func updatePublicite(id: String, dto: PubliciteDTO) async -> Bool {
        return await performRequest {
            let updated = try await service.updatePublicite(id: id, publicite: dto)
            if let index = publicites.firstIndex(where: { $0.id == id }) {
                publicites[index] = updated
            }
            successMessage = "Publicité mise à jour"
            showSuccess = true
        }
    }
    
    // MARK: - Delete
    func deletePublicite(id: String) async -> Bool {
        return await performRequest {
            try await service.deletePublicite(id: id)
            publicites.removeAll { $0.id == id }
            successMessage = "Publicité supprimée"
            showSuccess = true
        }
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadPublicites()
    }
    
    // MARK: - Helpers
    @discardableResult
    private func performRequest(operation: () async throws -> Void) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await operation()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            return false
        }
    }
}

