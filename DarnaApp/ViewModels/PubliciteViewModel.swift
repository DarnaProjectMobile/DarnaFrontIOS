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
    @Published var filteredPublicites: [Publicite] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    // Recherche et filtres
    @Published var searchText: String = ""
    @Published var selectedType: PubliciteType? = nil
    @Published var selectedCategory: String? = nil
    @Published var sortOption: SortOption = .recent
    
    enum Category: String, CaseIterable {
        case tout = "Tout"
        case nourriture = "Nourriture"
        case tech = "Tech"
        case loisirs = "Loisirs"
        case vetement = "Vêtement"
        case sante = "Santé"
        case transport = "Transport"
    }
    
    enum SortOption: String, CaseIterable {
        case recent = "Plus récentes"
        case oldest = "Plus anciennes"
        case popular = "Par popularité"
    }
    
    private let service: PubliciteServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Vérifier si l'utilisateur est sponsor
    @Published private(set) var isSponsor: Bool = false
    
    // Marques partenaires (sponsors uniques)
    var partnerBrands: [(id: String, name: String, logo: String?)] {
        var seenIds = Set<String>()
        return publicites.compactMap { pub -> (id: String, name: String, logo: String?)? in
            guard let sponsorId = pub.sponsorId,
                  !sponsorId.isEmpty,
                  !seenIds.contains(sponsorId),
                  let sponsorName = pub.sponsorName else {
                return nil
            }
            seenIds.insert(sponsorId)
            return (id: sponsorId, name: sponsorName, logo: pub.sponsorLogo)
        }
    }
    
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
        
        // Recherche avec debounce
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .combineLatest($selectedType)
            .combineLatest($selectedCategory)
            .combineLatest($sortOption)
            .combineLatest($publicites)
            .map { [weak self] values, publicites in
                let (((searchText, type), category), sort) = values
                return self?.filterAndSort(publicites: publicites, searchText: searchText, type: type, category: category, sort: sort) ?? []
            }
            .assign(to: &$filteredPublicites)
    }
    
    // MARK: - Filter and Sort
    private func filterAndSort(publicites: [Publicite], searchText: String, type: PubliciteType?, category: String?, sort: SortOption) -> [Publicite] {
        var filtered = publicites
        
        // Filtrer par texte de recherche
        if !searchText.isEmpty {
            filtered = filtered.filter { pub in
                pub.titre.localizedCaseInsensitiveContains(searchText) ||
                pub.description.localizedCaseInsensitiveContains(searchText) ||
                (pub.sponsorName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Filtrer par type
        if let type = type {
            filtered = filtered.filter { pub in
                pub.publiciteType == type
            }
        }
        
        // Filtrer par catégorie
        if let category = category, category != "Tout" {
            filtered = filtered.filter { pub in
                guard let pubCategorie = pub.categorie, !pubCategorie.isEmpty else { return false }
                let normalizedCategory = category.trimmingCharacters(in: .whitespaces).lowercased()
                let normalizedPubCategorie = pubCategorie.trimmingCharacters(in: .whitespaces).lowercased()
                return normalizedPubCategorie == normalizedCategory ||
                       normalizedPubCategorie.contains(normalizedCategory) ||
                       normalizedCategory.contains(normalizedPubCategorie)
            }
        }
        
        // Trier
        switch sort {
        case .recent:
            filtered.sort { pub1, pub2 in
                let date1 = pub1.createdAtDate ?? Date.distantPast
                let date2 = pub2.createdAtDate ?? Date.distantPast
                return date1 > date2
            }
        case .oldest:
            filtered.sort { pub1, pub2 in
                let date1 = pub1.createdAtDate ?? Date.distantPast
                let date2 = pub2.createdAtDate ?? Date.distantPast
                return date1 < date2
            }
        case .popular:
            filtered.sort { pub1, pub2 in
                let date1 = pub1.createdAtDate ?? Date.distantPast
                let date2 = pub2.createdAtDate ?? Date.distantPast
                return date1 > date2
            }
        }
        
        return filtered
    }
    
    // MARK: - Load Publicites
    func loadPublicites() async {
        isLoading = true
        errorMessage = nil
        
        do {
            publicites = try await service.fetchPublicites()
            filteredPublicites = filterAndSort(publicites: publicites, searchText: searchText, type: selectedType, category: selectedCategory, sort: sortOption)
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
            filteredPublicites = filterAndSort(publicites: publicites, searchText: searchText, type: selectedType, category: selectedCategory, sort: sortOption)
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
            filteredPublicites = filterAndSort(publicites: publicites, searchText: searchText, type: selectedType, category: selectedCategory, sort: sortOption)
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
            filteredPublicites = filterAndSort(publicites: publicites, searchText: searchText, type: selectedType, category: selectedCategory, sort: sortOption)
            successMessage = "Publicité supprimée avec succès"
            showSuccess = true
            isLoading = false
            return true
        } catch let error as APIError {
            switch error {
            case .httpError(let statusCode):
                if statusCode == 500 {
                    errorMessage = "Erreur serveur (500): Le serveur a rencontré une erreur. Vérifiez que la publicité n'est pas liée à d'autres données."
                } else if statusCode == 404 {
                    errorMessage = "Publicité introuvable (404)"
                } else if statusCode == 401 {
                    errorMessage = "Non autorisé (401): Veuillez vous reconnecter"
                } else {
                    errorMessage = "Erreur HTTP \(statusCode)"
                }
            case .networkError(let underlyingError):
                errorMessage = "Erreur réseau: \(underlyingError.localizedDescription)"
            default:
                errorMessage = "Erreur lors de la suppression: \(error.localizedDescription)"
            }
            showError = true
            isLoading = false
            print("❌ Erreur lors de la suppression: \(error)")
            return false
        } catch {
            errorMessage = "Erreur lors de la suppression: \(error.localizedDescription)"
            showError = true
            isLoading = false
            print("❌ Erreur lors de la suppression: \(error)")
            return false
        }
    }
    
    // MARK: - Get Single Publicite
    func getPublicite(id: String) async -> Publicite? {
        isLoading = true
        errorMessage = nil
        
        do {
            let publicite = try await service.getPublicite(id: id)
            isLoading = false
            return publicite
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            print("❌ Erreur lors de la récupération: \(error)")
            return nil
        }
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadPublicites()
    }
    
    // MARK: - Permission Check
    /// Vérifie si l'utilisateur actuel peut éditer/supprimer cette publicité
    /// Un sponsor peut uniquement modifier ses propres publicités
    func canEdit(_ publicite: Publicite) -> Bool {
        guard let currentUser = AuthenticationManager.shared.currentUser else {
            return false
        }
        
        // Un admin peut tout éditer
        if currentUser.role?.lowercased() == "admin" {
            return true
        }
        
        // Un sponsor peut éditer uniquement ses propres publicités
        if currentUser.role?.lowercased() == "sponsor" {
            return publicite.sponsorId == currentUser.id
        }
        
        return false
    }
    
    /// Vérifie si l'utilisateur peut supprimer cette publicité
    func canDelete(_ publicite: Publicite) -> Bool {
        return canEdit(publicite)
    }
}
