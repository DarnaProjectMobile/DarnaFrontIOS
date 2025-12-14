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
    func fetchGlobalReviews() async throws -> [VisitReview]
}

final class VisitRepository: VisitRepositoryProtocol {

    // ... (existing code)
    
    func loadReceivedReviews() async throws -> [VisitReview] {
        try await api.fetchReceivedReviews()
    }
    
    func fetchGlobalReviews() async throws -> [VisitReview] {
        try await (api as? VisitAPIService)?.fetchAllPublicReviews() ?? []
    }
}

