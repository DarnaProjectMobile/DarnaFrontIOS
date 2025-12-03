//
//  VisitViewModel.swift
//  DarnaApp
//
//

import Foundation
import Combine

@MainActor
struct EnrichedReview: Identifiable {
    let id = UUID()
    let review: VisitReview
    let visit: Visit
}

@MainActor
final class VisitViewModel: ObservableObject {
    // MARK: - Published State
    @Published private(set) var myVisits: [Visit] = []
    @Published private(set) var collocatorVisits: [Visit] = []
    @Published private(set) var reviews: [VisitReview] = []
    @Published private(set) var receivedReviews: [VisitReview] = [] // Gardé pour compatibilité si besoin, mais on va privilégier enriched
    @Published private(set) var givenReviews: [VisitReview] = []
    
    @Published private(set) var enrichedReceivedReviews: [EnrichedReview] = []
    @Published private(set) var enrichedGivenReviews: [EnrichedReview] = []
    
    @Published var reservationDraft = VisitReservationDraft()
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // MARK: - Dependencies
    private let repository: VisitRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: VisitRepositoryProtocol = VisitRepository()) {
        self.repository = repository
        observeAuthChanges()
    }
    
    // MARK: - Data Loading
    
    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.refreshMyVisits() }
            group.addTask { await self.refreshCollocatorVisits() }
        }
    }
    
    func refreshMyVisits(force: Bool = false) async {
        guard !isLoading || force else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            myVisits = try await repository.loadMyVisits()
            
            // Enrichir avec les vrais titres de logement
            await fetchRealPropertyTitles()
            
            // Charger les avis donnés
            await loadGivenReviews()
            
            print("✅ \(myVisits.count) visites chargées.")
            for visit in myVisits {
                print("   - Visite \(visit.id): Logement='\(visit.logementTitle ?? "NIL")'")
            }
        } catch {
            handle(error)
        }
    }
    
    // Récupérer les vrais titres des logements
    private func fetchRealPropertyTitles() async {
        print("🔄 Récupération des titres réels des logements...")
        
        // 1. Identifier les IDs uniques à récupérer
        let uniqueLogementIds = Set(myVisits.compactMap { $0.logementId })
        
        guard !uniqueLogementIds.isEmpty else { return }
        
        // 2. Récupérer les titres en parallèle
        var titles: [String: String] = [:]
        
        await withTaskGroup(of: (String, String?).self) { group in
            for id in uniqueLogementIds {
                group.addTask {
                    do {
                        let property = try await PropertyService.shared.fetchProperty(id: id)
                        return (id, property.title)
                    } catch {
                        print("⚠️ Impossible de récupérer le logement \(id): \(error)")
                        return (id, nil)
                    }
                }
            }
            
            for await (id, title) in group {
                if let title = title {
                    titles[id] = title
                }
            }
        }
        
        // 3. Mettre à jour myVisits en une seule fois
        var updatedVisits = myVisits
        for i in 0..<updatedVisits.count {
            if let logementId = updatedVisits[i].logementId, let title = titles[logementId] {
                updatedVisits[i].logementTitle = title
            }
        }
        self.myVisits = updatedVisits
        
        print("✅ Titres des logements mis à jour.")
    }
    
    func refreshCollocatorVisits(force: Bool = false) async {
        guard !isLoading || force else { return }
        isLoading = true
        defer { isLoading = false }
        
        print("🔄 Refreshing Collocator Visits...")
        
        do {
            collocatorVisits = try await repository.loadCollocatorVisits()
            print("✅ \(collocatorVisits.count) visites collocator chargées depuis le repository.")
            // Une fois les visites chargées, on charge les avis correspondants
            await loadReceivedReviews()
        } catch {
            print("❌ Erreur refreshCollocatorVisits: \(error)")
            handle(error, silentOnForbidden: true)
        }
    }
    
    // MARK: - Reviews
    
    func submitReview(draft: VisitReviewDraft) async {
        guard !draft.visit.id.isEmpty else {
            errorMessage = "Identifiant de visite manquant."
            return
        }
        isSubmitting = true
        defer { isSubmitting = false }
        
        print("🚀 Envoi avis pour visite \(draft.visit.id)...")
        
        do {
            _ = try await repository.submitReview(id: draft.visit.id, draft: draft)
            print("✅ Avis enregistré dans MongoDB !")
            successMessage = "Merci pour votre avis !"
            await refreshMyVisits(force: true)
        } catch {
            print("❌ Erreur avis: \(error)")
            handle(error)
        }
    }
    
    func loadReviews(for visit: Visit) async {
        guard !visit.id.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            reviews = try await repository.loadReviews(for: visit.id)
        } catch {
            handle(error)
        }
    }
    
    func loadReceivedReviews() async {
        print("🔍 DEBUG: Début loadReceivedReviews")
        
        // 1. Essayer l'endpoint global
        print("📥 Tentative 1: Chargement global via /reviews/me/feedbacks...")
        var allReviews: [VisitReview] = []
        
        do {
            allReviews = try await repository.loadReceivedReviews()
            print("✅ API Global a retourné \(allReviews.count) avis")
        } catch {
            print("⚠️ API Global a échoué: \(error)")
        }
        
        // 2. Si vide, passer en mode "Secours" : charger un par un
        if allReviews.isEmpty {
            let visitsWithReviews = collocatorVisits.filter { $0.reviewId != nil }
            if !visitsWithReviews.isEmpty {
                print("⚠️ Fallback: Chargement individuel pour \(visitsWithReviews.count) visites avec avis...")
                
                await withTaskGroup(of: [VisitReview]?.self) { group in
                    for visit in visitsWithReviews {
                        group.addTask {
                            try? await self.repository.loadReviews(for: visit.id)
                        }
                    }
                    
                    for await reviews in group {
                        if let reviews = reviews {
                            allReviews.append(contentsOf: reviews)
                        }
                    }
                }
                print("✅ Mode Secours a récupéré \(allReviews.count) avis")
            }
        }
        
        // 3. Enrichir et afficher
        let finalReviews = allReviews
        var enriched: [EnrichedReview] = []
        
        for review in finalReviews {
            if let matchingVisit = collocatorVisits.first(where: { $0.id == review.visiteId }) {
                enriched.append(EnrichedReview(review: review, visit: matchingVisit))
            }
        }
        
        await MainActor.run {
            self.receivedReviews = finalReviews
            self.enrichedReceivedReviews = enriched
            print("✅ TOTAL FINAL: \(enriched.count) avis enrichis chargés.")
        }
    }

    func loadGivenReviews() async {
        // Filtrer mes visites qui ont un avis
        let visitsWithReviews = myVisits.filter { $0.reviewId != nil }
        
        guard !visitsWithReviews.isEmpty else {
            givenReviews = []
            enrichedGivenReviews = []
            return
        }
        
        print("📤 Chargement des avis donnés pour \(visitsWithReviews.count) visites...")
        
        var enriched: [EnrichedReview] = []
        var rawReviews: [VisitReview] = []
        
        await withTaskGroup(of: (Visit, [VisitReview]?)?.self) { group in
            for visit in visitsWithReviews {
                group.addTask {
                    let reviews = try? await self.repository.loadReviews(for: visit.id)
                    return (visit, reviews)
                }
            }
            
            for await result in group {
                if let (visit, reviews) = result, let reviews = reviews {
                    rawReviews.append(contentsOf: reviews)
                    for review in reviews {
                        enriched.append(EnrichedReview(review: review, visit: visit))
                    }
                }
            }
        }
        
        await MainActor.run {
            self.givenReviews = rawReviews
            self.enrichedGivenReviews = enriched
            print("✅ \(enriched.count) avis donnés enrichis chargés.")
        }
    }
    
    // MARK: - Reservation
    
    /// Vérifie si le client a déjà une visite active (pending ou confirmed)
    func hasActiveVisit() -> Bool {
        return myVisits.contains { visit in
            visit.status == .pending || visit.status == .confirmed
        }
    }
    
    /// Retourne la visite active si elle existe
    func getActiveVisit() -> Visit? {
        return myVisits.first { visit in
            visit.status == .pending || visit.status == .confirmed
        }
    }
    
    func submitReservation() async {
        guard !reservationDraft.logementId.isEmpty else {
            errorMessage = "Veuillez sélectionner un logement."
            return
        }
        
        // Vérification authentification
        let token = AuthenticationManager.shared.authToken
        if token == nil {
            print("❌ Erreur: Pas de token d'authentification")
            errorMessage = "Vous devez être connecté pour réserver."
            return
        }
        
        // ✅ NOUVELLE VÉRIFICATION : Empêcher plusieurs réservations actives
        if hasActiveVisit() {
            if let activeVisit = getActiveVisit() {
                let statusText = activeVisit.status.displayName
                errorMessage = "Vous avez déjà une visite \(statusText.lowercased()) pour \"\(activeVisit.title)\". Veuillez d'abord annuler ou terminer cette visite avant d'en réserver une nouvelle."
            } else {
                errorMessage = "Vous avez déjà une visite en cours. Veuillez d'abord la terminer avant d'en réserver une nouvelle."
            }
            print("⚠️ Tentative de réservation bloquée : visite active existante")
            return
        }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        print("🚀 Envoi de la réservation au backend...")
        print("   - Logement ID: \(reservationDraft.logementId)")
        print("   - Date: \(reservationDraft.date)")
        print("   - URL Backend: \(ServerConfig.baseURL)")
        
        do {
            let visit = try await repository.createVisit(reservationDraft)
            print("✅ Réservation réussie ! ID: \(visit.id)")
            successMessage = "Visite réservée avec succès."
            await refreshMyVisits(force: true)
            reservationDraft.reset()
        } catch {
            print("❌ Erreur lors de la réservation: \(error)")
            if let networkError = error as? NetworkError {
                print("   - Type erreur réseau: \(networkError)")
            }
            handle(error)
        }
    }
    
    // MARK: - Update / Cancel
    
    func updateVisit(with draft: VisitEditDraft) async {
        guard !draft.visit.id.isEmpty else {
            errorMessage = "Identifiant de visite manquant."
            return
        }
        isSubmitting = true
        defer { isSubmitting = false }
        
        print("🚀 Modification visite \(draft.visit.id)...")
        
        do {
            _ = try await repository.updateVisit(id: draft.visit.id, draft: draft)
            print("✅ Modification enregistrée dans MongoDB !")
            successMessage = "Visite modifiée."
            await refreshMyVisits(force: true)
        } catch {
            print("❌ Erreur modification: \(error)")
            handle(error)
        }
    }
    
    func deleteVisit(_ visit: Visit) async {
        guard !visit.id.isEmpty else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        
        print("🚀 Suppression visite \(visit.id)...")
        
        do {
            try await repository.deleteVisit(id: visit.id)
            print("✅ Suppression confirmée dans MongoDB !")
            successMessage = "Visite supprimée."
            await refreshMyVisits(force: true)
        } catch {
            print("❌ Erreur suppression: \(error)")
            handle(error)
        }
    }
    
    func cancelVisit(_ visit: Visit) async {
        guard !visit.id.isEmpty else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        
        print("🚀 Annulation visite \(visit.id)...")
        
        do {
            _ = try await repository.cancelVisit(id: visit.id)
            print("✅ Annulation enregistrée dans MongoDB !")
            successMessage = "Visite annulée."
            await refreshMyVisits(force: true)
        } catch {
            print("❌ Erreur annulation: \(error)")
            handle(error)
        }
    }
    
    // MARK: - Collocator Actions
    
    func acceptVisit(_ visit: Visit) async {
        guard !visit.id.isEmpty else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        
        print("🚀 Acceptation visite \(visit.id)...")
        
        do {
            _ = try await repository.acceptVisit(id: visit.id)
            print("✅ Acceptation enregistrée dans MongoDB !")
            successMessage = "Visite acceptée."
            await refreshCollocatorVisits(force: true)
        } catch {
            print("❌ Erreur acceptation: \(error)")
            handle(error)
        }
    }
    
    func rejectVisit(_ visit: Visit) async {
        guard !visit.id.isEmpty else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        
        print("🚀 Refus visite \(visit.id)...")
        
        do {
            _ = try await repository.rejectVisit(id: visit.id)
            print("✅ Refus enregistré dans MongoDB !")
            successMessage = "Visite refusée."
            await refreshCollocatorVisits(force: true)
        } catch {
            print("❌ Erreur refus: \(error)")
            handle(error)
        }
    }
    
    func validateVisit(_ visit: Visit) async {
        guard !visit.id.isEmpty else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        
        print("🚀 Validation visite \(visit.id)...")
        
        do {
            _ = try await repository.validateVisit(id: visit.id)
            print("✅ Validation enregistrée dans MongoDB !")
            successMessage = "Visite marquée comme effectuée."
            await refreshMyVisits(force: true)
        } catch {
            print("❌ Erreur validation: \(error)")
            handle(error)
        }
    }
    
    // MARK: - Helpers
    
    func clearFeedback() {
        errorMessage = nil
        successMessage = nil
    }
    
    private func observeAuthChanges() {
        NotificationCenter.default.publisher(for: .authenticationDidChange)
            .sink { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.loadInitialData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func handle(_ error: Error, silentOnForbidden: Bool = false) {
        if case NetworkError.serverError(let message) = error,
           silentOnForbidden,
           message.lowercased().contains("403") {
            return
        }
        if let networkError = error as? NetworkError {
            if case .unauthorized = networkError {
                NotificationCenter.default.post(name: .shouldDismissMainApp, object: nil)
                return
            }
            errorMessage = networkError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
