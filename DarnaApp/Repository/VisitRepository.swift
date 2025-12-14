//
//  VisitRepository.swift
//  DarnaApp
//
//

import Foundation

protocol VisitRepositoryProtocol {
    func loadMyVisits() async throws -> [Visit]
    func loadCollocatorVisits() async throws -> [Visit]
    func createVisit(_ draft: VisitReservationDraft) async throws -> Visit
    func updateVisit(id: String, draft: VisitEditDraft) async throws -> Visit
    func deleteVisit(id: String) async throws
    func cancelVisit(id: String) async throws -> Visit
    func acceptVisit(id: String) async throws -> Visit
    func rejectVisit(id: String) async throws -> Visit
    func validateVisit(id: String) async throws -> Visit
    func submitReview(id: String, draft: VisitReviewDraft) async throws -> VisitReview
    func loadReviews(for id: String) async throws -> [VisitReview]
    func loadReceivedReviews() async throws -> [VisitReview]
}

final class VisitRepository: VisitRepositoryProtocol {
    private let api: VisitAPIServiceProtocol
    
    init(api: VisitAPIServiceProtocol = VisitAPIService.shared) {
        self.api = api
    }
    
    func loadMyVisits() async throws -> [Visit] {
        try await api.fetchMyVisits()
    }
    
    func loadCollocatorVisits() async throws -> [Visit] {
        try await api.fetchCollocatorVisits()
    }
    
    func createVisit(_ draft: VisitReservationDraft) async throws -> Visit {
        let payload = VisitCreationPayload(
            logementId: draft.logementId,
            dateVisite: VisitDateFormatter.shared.isoString(from: draft.date),
            notes: draft.notes.isEmpty ? nil : draft.notes,
            contactPhone: draft.contactPhone.isEmpty ? nil : draft.contactPhone
        )
        return try await api.createVisit(payload)
    }
    
    func updateVisit(id: String, draft: VisitEditDraft) async throws -> Visit {
        let payload = VisitUpdatePayload(
            logementId: draft.visit.logementId,
            dateVisite: VisitDateFormatter.shared.isoString(from: draft.newDate),
            notes: draft.notes.isEmpty ? nil : draft.notes,
            contactPhone: draft.contactPhone.isEmpty ? nil : draft.contactPhone
        )
        return try await api.updateVisit(id: id, payload: payload)
    }
    
    func deleteVisit(id: String) async throws {
        try await api.deleteVisit(id: id)
    }
    
    func cancelVisit(id: String) async throws -> Visit {
        try await api.cancelVisit(id: id)
    }
    
    func acceptVisit(id: String) async throws -> Visit {
        try await api.acceptVisit(id: id)
    }
    
    func rejectVisit(id: String) async throws -> Visit {
        try await api.rejectVisit(id: id)
    }
    
    func validateVisit(id: String) async throws -> Visit {
        try await api.validateVisit(id: id)
    }
    
    func submitReview(id: String, draft: VisitReviewDraft) async throws -> VisitReview {
        let payload = VisitReviewPayload(
            visiteId: id,
            collectorRating: draft.collector,
            cleanlinessRating: draft.cleanliness,
            locationRating: draft.location,
            conformityRating: draft.conformity,
            comment: draft.comment.isEmpty ? nil : draft.comment
        )
        return try await api.submitReview(id: id, payload: payload)
    }
    
    func loadReviews(for id: String) async throws -> [VisitReview] {
        try await api.fetchReviews(for: id)
    }
    
    func loadReceivedReviews() async throws -> [VisitReview] {
        try await api.fetchReceivedReviews()
    }
}

