import Foundation

struct Visit: Identifiable, Codable, Equatable {
    let id: String
    let propertyId: String
    var propertyTitle: String
    let clientId: String
    var clientName: String
    var clientEmail: String
    let collectorId: String
    var collectorName: String
    var collectorEmail: String
    var visitDate: Date
    var status: VisitStatus
    var notes: String?
    var rating: Int?
    var review: String?
    var isReminderSent: Bool
    var createdAt: Date
    var updatedAt: Date
    
    enum VisitStatus: String, Codable {
        case pending = "pending"
        case accepted = "accepted"
        case rejected = "rejected"
        case rescheduled = "rescheduled"
        case completed = "completed"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .pending: return "En attente"
            case .accepted: return "Acceptée"
            case .rejected: return "Refusée"
            case .rescheduled: return "Replanifiée"
            case .completed: return "Terminée"
            case .cancelled: return "Annulée"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .accepted: return .green
            case .rejected: return .red
            case .rescheduled: return .blue
            case .completed: return .purple
            case .cancelled: return .gray
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case propertyId, propertyTitle
        case clientId, clientName, clientEmail
        case collectorId, collectorName, collectorEmail
        case visitDate, status, notes, rating, review, isReminderSent
        case createdAt, updatedAt
    }
    
    // Pour faciliter les tests et les previews
    static func mock() -> Visit {
        return Visit(
            id: UUID().uuidString,
            propertyId: "property123",
            propertyTitle: "Appartement T2",
            clientId: "client123",
            clientName: "Jean Dupont",
            clientEmail: "jean@example.com",
            collectorId: "collector123",
            collectorName: "Marie Martin",
            collectorEmail: "marie@example.com",
            visitDate: Date().addingTimeInterval(86400), // Demain
            status: .pending,
            notes: "Visite pour un appartement de 50m² avec balcon",
            rating: nil,
            review: nil,
            isReminderSent: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// Modèles pour les requêtes API
struct CreateVisitRequest: Codable {
    let propertyId: String
    let clientId: String
    let collectorId: String
    let visitDate: Date
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case propertyId, clientId, collectorId, visitDate, notes
    }
}

struct UpdateVisitRequest: Codable {
    let status: Visit.VisitStatus?
    let notes: String?
    let visitDate: Date?
    let rating: Int?
    let review: String?
    let isReminderSent: Bool?
    
    enum CodingKeys: String, CodingKey {
        case status, notes, visitDate, rating, review, isReminderSent
    }
}

// Extension pour les dates
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
}

// Extension pour le décodage des dates
extension JSONDecoder {
    static let iso8601: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }()
}

extension JSONEncoder {
    static let iso8601: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        return encoder
    }()
}
