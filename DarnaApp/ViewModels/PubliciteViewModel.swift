//
//  PubliciteViewModel.swift
//  DarnaApp
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PubliciteViewModel: ObservableObject {
    @Published var publicites: [Publicite] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    private let service: PubliciteServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Vérifier si l'utilisateur est sponsor
    @Published private(set) var isSponsor: Bool = false
    
    private func updateSponsorStatus() {
        isSponsor = AuthenticationManager.shared.currentUser?.role?.lowercased() == "sponsor"
    }
    
    init(service: PubliciteServiceProtocol = PubliciteService.shared) {
        self.service = service
        updateSponsorStatus()
        
        // S'abonner aux changements d'authentification
        NotificationCenter.default.publisher(for: .authenticationDidChange)
            .sink { [weak self] _ in
                self?.updateSponsorStatus()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Publicites
    func loadPublicites() async {
        isLoading = true
        errorMessage = nil
        
        do {
            publicites = try await service.fetchPublicites()
            print("✅ \(publicites.count) publicités chargées dans le ViewModel")
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Erreur lors du chargement: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Create Publicite
    func createPublicite(_ dto: PubliciteDTO) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let newPublicite = try await service.createPublicite(dto)
            publicites.insert(newPublicite, at: 0)
            successMessage = "Publicité créée avec succès"
            showSuccess = true
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            print("❌ Erreur lors de la création: \(error)")
            return false
        }
    }
    
    // MARK: - Update Publicite
    func updatePublicite(id: String, dto: PubliciteDTO) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedPublicite = try await service.updatePublicite(id: id, publicite: dto)
            if let index = publicites.firstIndex(where: { $0.id == id }) {
                publicites[index] = updatedPublicite
            }
            successMessage = "Publicité modifiée avec succès"
            showSuccess = true
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            print("❌ Erreur lors de la mise à jour: \(error)")
            return false
        }
    }
    
    // MARK: - Delete Publicite
    func deletePublicite(id: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.deletePublicite(id: id)
            publicites.removeAll { $0.id == id }
            successMessage = "Publicité supprimée avec succès"
            showSuccess = true
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            print("❌ Erreur lors de la suppression: \(error)")
            return false
        }
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadPublicites()
    }
}
