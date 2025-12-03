//
//  Visit.swift
//  DarnaApp
//
//

import Foundation
import SwiftUI

// MARK: - Visit Status

enum VisitStatus: String, Codable, CaseIterable, Identifiable {
    case pending
    case confirmed
    case refused
    case cancelled
    case completed
    case validated
    case unknown
    
    init(from backendValue: String?) {
        guard let value = backendValue?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else {
            self = .unknown
            return
        }
        
        switch value {
        case "pending", "en attente":
            self = .pending
        case "confirmed", "acceptée", "accepted":
            self = .confirmed
        case "refused", "refusée", "rejected":
            self = .refused
        case "cancelled", "canceled", "annulée":
            self = .cancelled
        case "completed", "terminée":
            self = .completed
        case "validated", "validate":
            self = .validated
        default:
            self = .unknown
        }
    }
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .pending: return "En attente"
        case .confirmed: return "Acceptée"
        case .refused: return "Refusée"
        case .cancelled: return "Annulée"
        case .completed: return "Terminée"
        case .validated: return "Validée"
        case .unknown: return "Inconnue"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .confirmed: return "checkmark.circle.fill"
        case .refused: return "xmark.circle.fill"
        case .cancelled: return "slash.circle.fill"
        case .completed: return "checkmark.seal.fill"
        case .validated: return "checkmark.seal.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .pending: return Color.orange
        case .confirmed: return Color.green
        case .refused: return Color.red
        case .cancelled: return Color.gray
        case .completed: return Color.blue
        case .validated: return Color.purple
        case .unknown: return Color.gray.opacity(0.7)
        }
    }
    
    static var dashboardFilters: [VisitStatus] {
        [.pending, .confirmed, .refused, .completed]
    }
}

// MARK: - Visit Model

struct Visit: Identifiable, Codable, Equatable {
    let id: String
    let logementId: String?
    let userId: String?
    let dateVisite: String?
    let statusRaw: String?
    let notes: String?
    let contactPhone: String?
    let clientUsername: String?
    var logementTitle: String?
    let validated: Bool?
    let reviewId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case logementId
        case userId
        case dateVisite
        case statusRaw = "status"
        case notes
        case contactPhone
        case clientUsername
        case logementTitle
        case validated
        case reviewId
    }
    
    var status: VisitStatus {
        VisitStatus(from: statusRaw)
    }
    
    var visitDate: Date? {
        VisitDateFormatter.shared.date(from: dateVisite)
    }
    
    var formattedDate: String {
        guard let date = visitDate else { return "Date à confirmer" }
        return VisitDateFormatter.shared.displayDateFormatter.string(from: date)
    }
    
    var formattedTime: String {
        guard let date = visitDate else { return "Heure à confirmer" }
        return VisitDateFormatter.shared.displayTimeFormatter.string(from: date)
    }
    
    var canEdit: Bool {
        status == .pending
    }
    
    var canDelete: Bool {
        status == .pending
    }
    
    var canCancel: Bool {
        status == .confirmed || status == .pending
    }
    
    var canValidate: Bool {
        status == .confirmed && validated != true
    }
    
    var canRate: Bool {
        // Peut évaluer si:
        // 1. La visite est validée (validated == true) OU le statut est completed
        // 2. Il n'y a pas encore d'évaluation (reviewId == nil)
        (validated == true || status == .completed || status == .validated) && reviewId == nil
    }
    
    var title: String {
        logementTitle ?? "Logement"
    }
    
    var displayContact: String {
        contactPhone ?? "Non renseigné"
    }
}

// MARK: - Visit Review

struct VisitReview: Identifiable, Codable, Equatable {
    let id: String
    let visiteId: String?
    let userId: String?
    let logementId: String?
    let collectorId: String?
    let rating: Float?
    let collectorRating: Float?
    let cleanlinessRating: Float?
    let locationRating: Float?
    let conformityRating: Float?
    let comment: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case visiteId
        case userId
        case logementId
        case collectorId
        case rating
        case collectorRating
        case cleanlinessRating
        case locationRating
        case conformityRating
        case comment
        case createdAt
    }
}

// MARK: - Requests

struct VisitCreationPayload: Encodable {
    let logementId: String
    let dateVisite: String
    let notes: String?
    let contactPhone: String?
}

struct VisitUpdatePayload: Encodable {
    let logementId: String?
    let dateVisite: String?
    let notes: String?
    let contactPhone: String?
}

struct VisitStatusPayload: Encodable {
    let status: String
}

struct VisitReviewPayload: Encodable {
    let visiteId: String?
    let collectorRating: Int
    let cleanlinessRating: Int
    let locationRating: Int
    let conformityRating: Int
    let comment: String?
}

// MARK: - Drafts

struct VisitReservationDraft: Identifiable {
    let id = UUID()
    var logementId: String = ""
    var logementTitle: String = ""
    var date: Date = Date()
    var notes: String = ""
    var contactPhone: String = ""
    
    mutating func reset() {
        logementId = ""
        logementTitle = ""
        date = Date()
        notes = ""
        contactPhone = ""
    }
}

struct VisitEditDraft {
    var visit: Visit
    var newDate: Date
    var notes: String
    var contactPhone: String
    
    init(visit: Visit) {
        self.visit = visit
        self.newDate = visit.visitDate ?? Date()
        self.notes = visit.notes ?? ""
        self.contactPhone = visit.contactPhone ?? ""
    }
}

struct VisitReviewDraft {
    var visit: Visit
    var collector: Int = 4
    var cleanliness: Int = 4
    var location: Int = 4
    var conformity: Int = 4
    var comment: String = ""
}

// MARK: - Date Helpers

final class VisitDateFormatter {
    static let shared = VisitDateFormatter()
    
    private let isoFormatter: ISO8601DateFormatter
    let displayDateFormatter: DateFormatter
    let displayTimeFormatter: DateFormatter
    
    private init() {
        isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        displayDateFormatter = DateFormatter()
        displayDateFormatter.dateStyle = .full
        displayDateFormatter.timeStyle = .none
        displayDateFormatter.locale = Locale(identifier: "fr_FR")
        
        displayTimeFormatter = DateFormatter()
        displayTimeFormatter.dateStyle = .none
        displayTimeFormatter.timeStyle = .short
        displayTimeFormatter.locale = Locale(identifier: "fr_FR")
    }
    
    func isoString(from date: Date) -> String {
        isoFormatter.string(from: date)
    }
    
    func date(from string: String?) -> Date? {
        guard let string else { return nil }
        if let date = isoFormatter.date(from: string) {
            return date
        }
        
        // Try without fractional seconds
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        fallback.timeZone = TimeZone(secondsFromGMT: 0)
        return fallback.date(from: string)
    }
}

