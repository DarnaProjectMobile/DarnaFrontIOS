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
    
    // Fusion de tous les avis (Donnés + Reçus) pour l'affichage global
    @Published var allEnrichedReviews: [EnrichedReview] = []
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
        NotificationService.shared.requestAuthorization()
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
            print("✅ \(myVisits.count) visites chargées.")
            
            // Générer des notifications basées sur l'état des visites
            NotificationService.shared.generateNotifications(from: myVisits)
            
            // Notification: Planifier les rappels pour les visites confirmées
            for visit in myVisits where visit.status == .confirmed {
                NotificationService.shared.scheduleVisitReminders(for: visit)
            }
            
            await fetchRealPropertyTitles()
            
        } catch {
            // On masque le 403 car un collocateur peut ne pas avoir accès à cet endpoint client
            handle(error, silentOnForbidden: true)
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
        
        print("🔄 Refreshing Collocator Visits & Reviews...")
        
        // 1. Charger les visites
        do {
            collocatorVisits = try await repository.loadCollocatorVisits()
            print("✅ \(collocatorVisits.count) visites collocator chargées.")
        } catch {
            print("❌ Erreur chargement visites: \(error)")
            // On masque le 403 pour ne pas bloquer l'UI et tenter de charger les avis ensuite
            handle(error, silentOnForbidden: true)
        }
        
        // 2. Charger les avis (Indépendamment du succès des visites)
        await loadReceivedReviews()
    }
    
    // MARK: - Reviews & Global
    
    func combineAllReviews() {
        var combined = enrichedGivenReviews
        
        for received in enrichedReceivedReviews {
            if !combined.contains(where: { $0.review.id == received.review.id }) {
                combined.append(received)
            }
        }
        
        combined.sort { ($0.review.createdAt ?? "") > ($1.review.createdAt ?? "") }
        self.allEnrichedReviews = combined
    }
    
    func loadGlobalReviews() async {
        isLoading = true
        do {
            print("🌍 Chargement de tous les avis publics...")
            // Bypass Protocol Issue: Calling API Service directly
            let publicReviews = try await VisitAPIService.shared.fetchAllPublicReviews()
            
            var enriched: [EnrichedReview] = []
            for review in publicReviews {
                let placeholderVisit = Visit(
                    id: review.visiteId ?? UUID().uuidString,
                    logementId: review.logementId ?? "unknown",
                    userId: review.userId,
                    dateVisite: review.createdAt,
                    statusRaw: "completed",
                    notes: nil,
                    contactPhone: nil,
                    clientUsername: nil,
                    logementTitle: "Visite évaluée",
                    validated: true,
                    reviewId: review.id
                )
                enriched.append(EnrichedReview(review: review, visit: placeholderVisit))
            }
            
            await MainActor.run {
                self.allEnrichedReviews = enriched
                print("✅ \(enriched.count) avis publics chargés.")
            }
            
        } catch {
            print("❌ Erreur chargement avis publics: \(error)")
            await MainActor.run {
                self.allEnrichedReviews = []
            }
        }
        isLoading = false
    }
    
    func submiReview(draft: VisitReviewDraft) async {
         // Typo fix: calling submitReview
         await submitReview(draft: draft)
    }

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
        
        print("📥 Tentative 1: Chargement global via /reviews/me/feedbacks...")
        var allReviews: [VisitReview] = []
        
        do {
            allReviews = try await repository.loadReceivedReviews()
            print("✅ API Global a retourné \(allReviews.count) avis")
        } catch {
            print("❌ ECHEC CHARGEMENT AVIS (/reviews/me/feedbacks): \(error)")
            if let localized = error as? NetworkError {
                 print("   -> Detail NetworkError: \(localized.errorDescription ?? "Inconnu")")
            }
        }
        
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
        
        let finalReviews = allReviews
        var enriched: [EnrichedReview] = []
        
        for review in finalReviews {
            if let matchingVisit = collocatorVisits.first(where: { $0.id == review.visiteId }) {
                enriched.append(EnrichedReview(review: review, visit: matchingVisit))
            } else {
                let placeholderVisit = Visit(
                    id: review.visiteId ?? UUID().uuidString,
                    logementId: review.logementId,
                    userId: review.userId,
                    dateVisite: review.createdAt,
                    statusRaw: "completed",
                    notes: "Visite récupérée depuis l'avis",
                    contactPhone: nil,
                    clientUsername: "Client",
                    logementTitle: "Logement visité",
                    validated: true,
                    reviewId: review.id
                )
                enriched.append(EnrichedReview(review: review, visit: placeholderVisit))
            }
        }
        
        await MainActor.run {
            self.receivedReviews = finalReviews
            self.enrichedReceivedReviews = enriched
            print("✅ TOTAL FINAL: \(enriched.count) avis enrichis chargés.")
        }
    }

    func loadGivenReviews() async {
        let candidateVisits = myVisits.filter { 
            $0.status == .completed || $0.status == .validated || $0.reviewId != nil 
        }
        
        guard !candidateVisits.isEmpty else {
            givenReviews = []
            enrichedGivenReviews = []
            print("ℹ️ Aucune visite terminée candidate aux avis.")
            return
        }
        
        print("📤 Chargement des avis donnés pour \(candidateVisits.count) visites candidates...")
        
        var enriched: [EnrichedReview] = []
        var rawReviews: [VisitReview] = []
        
        await withTaskGroup(of: (Visit, [VisitReview]?)?.self) { group in
            for visit in candidateVisits {
                group.addTask {
                    do {
                        let reviews = try await self.repository.loadReviews(for: visit.id)
                        return (visit, reviews)
                    } catch {
                        return nil 
                    }
                }
            }
            
            for await result in group {
                if let (visit, reviews) = result, let reviews = reviews, !reviews.isEmpty {
                    rawReviews.append(contentsOf: reviews)
                    for review in reviews {
                        enriched.append(EnrichedReview(review: review, visit: visit))
                    }
                }
            }
        }
        
        enriched.sort { ($0.review.createdAt ?? "") > ($1.review.createdAt ?? "") }
        
        await MainActor.run {
            self.givenReviews = rawReviews
            self.enrichedGivenReviews = enriched
            print("✅ \(enriched.count) avis donnés enrichis trouvés.")
        }
    }
    
    // MARK: - Reservation
    
    func submitReservation() async {
        guard !reservationDraft.logementId.isEmpty else {
            errorMessage = "Logement non spécifié."
            return
        }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            print("🚀 Envoi réservation pour logement: \(reservationDraft.logementTitle)")
            let visit = try await repository.createVisit(reservationDraft)
            
            print("✅ Réservation réussie ! ID: \(visit.id)")
            successMessage = "Visite réservée avec succès."
            NotificationService.shared.sendInstantNotification(title: "Demande envoyée", body: "Votre demande pour '\(visit.title)' a été transmise au propriétaire.")
            
            await refreshMyVisits(force: true)
            reservationDraft.reset()
        } catch {
            print("❌ Erreur réservation: \(error)")
            handle(error)
        }
    }
    
    // MARK: - Actions
    
    func cancelVisit(_ visit: Visit) async {
        guard visit.canCancel else { return }
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            _ = try await repository.cancelVisit(id: visit.id)
            successMessage = "Visite annulée."
            NotificationService.shared.cancelNotification(for: visit.id)
            await refreshMyVisits(force: true)
        } catch {
            handle(error)
        }
    }
    
    func acceptVisit(_ visit: Visit) async {
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            _ = try await repository.acceptVisit(id: visit.id)
            print("✅ Acceptation enregistrée dans MongoDB !")
            successMessage = "Visite acceptée."
            NotificationService.shared.sendInstantNotification(title: "Visite acceptée", body: "Vous avez accepté la visite. Des rappels seront envoyés.")
            await refreshCollocatorVisits(force: true)
        } catch {
            print("❌ Erreur acceptation: \(error)")
            handle(error)
        }
    }
    
    func rejectVisit(_ visit: Visit) async {
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            _ = try await repository.rejectVisit(id: visit.id)
             print("✅ Refus enregistré dans MongoDB !")
            successMessage = "Visite refusée."
            NotificationService.shared.sendInstantNotification(title: "Visite refusée", body: "La demande de visite a été refusée.")
            await refreshCollocatorVisits(force: true)
        } catch {
             print("❌ Erreur refus: \(error)")
            handle(error)
        }
    }
    
    func validateVisit(_ visit: Visit) async {
        guard visit.canValidate else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            _ = try await repository.validateVisit(id: visit.id)
            successMessage = "Visite validée."
            await refreshMyVisits(force: true)
        } catch {
            handle(error)
        }
    }
    
    func deleteVisit(_ visit: Visit) async {
        guard visit.canDelete else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            try await repository.deleteVisit(id: visit.id)
            successMessage = "Visite supprimée."
            await refreshMyVisits(force: true)
        } catch {
            handle(error)
        }
    }
    
    func updateVisit(with draft: VisitEditDraft) async {
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            // Note: VisitEditDraft contains the original visit object which has the ID
            _ = try await repository.updateVisit(id: draft.visit.id, draft: draft)
            successMessage = "Visite mise à jour."
            await refreshMyVisits(force: true)
        } catch {
            handle(error)
        }
    }
    
    // MARK: - Validation Helpers
    
    // Vérifie pour un logement spécifique
    func hasActiveVisit(_ logementId: String) -> Bool {
        myVisits.contains { visit in
            visit.logementId == logementId && 
            visit.status != .cancelled && 
            visit.status != .refused
        }
    }
    
    // Vérifie s'il y a N'IMPORTE QUELLE visite active
    func hasActiveVisit() -> Bool {
        myVisits.contains { visit in
            visit.status != .cancelled && 
            visit.status != .refused
        }
    }
    
    // Récupère une visite active pour un logement spécifique
    func getActiveVisit(_ logementId: String) -> Visit? {
        myVisits.first { visit in
            visit.logementId == logementId &&
            visit.status != .cancelled &&
            visit.status != .refused
        }
    }
    
    // Récupère la première visite active trouvée
    func getActiveVisit() -> Visit? {
        myVisits.first { visit in
            visit.status != .cancelled && 
            visit.status != .refused
        }
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    // Alias pour compatibilité si la vue appelle clearFeedback
    func clearFeedback() {
        clearMessages()
    }

    // MARK: - Helpers
    
    private func handle(_ error: Error, silentOnForbidden: Bool = false) {
        if let networkError = error as? NetworkError {
            if silentOnForbidden && networkError == .forbidden {
                 // Ne rien faire, c'est attendu si le rôle ne correspond pas
                 return
            }
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Auth Observation
    
    private func observeAuthChanges() {
        AuthenticationManager.shared.$currentUser
            .sink { [weak self] user in
                Task {
                    if user != nil {
                        await self?.loadInitialData()
                    } else {
                        await MainActor.run {
                            self?.myVisits = []
                            self?.collocatorVisits = []
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}
