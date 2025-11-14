//
//  Visit.swift
//  DarnaApp
//

import Foundation
import CoreData

enum VisitStatus: String, CaseIterable, Identifiable, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
    case rescheduled = "rescheduled"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .pending: return "En attente"
        case .accepted: return "Acceptée"
        case .rejected: return "Refusée"
        case .rescheduled: return "Reportée"
        case .completed: return "Terminée"
        case .cancelled: return "Annulée"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .accepted: return "blue"
        case .rejected: return "red"
        case .rescheduled: return "yellow"
        case .completed: return "green"
        case .cancelled: return "gray"
        }
    }
}

struct VisitModel: Identifiable, Codable, Equatable {
    var id: UUID
    var propertyId: UUID
    var propertyTitle: String
    var tenantId: UUID
    var tenantName: String
    var tenantEmail: String
    var ownerId: UUID
    var ownerName: String
    var ownerEmail: String
    var scheduledDate: Date
    var status: VisitStatus
    var proposedAlternativeDate: Date?
    var notes: String?
    var rating: Int?
    var review: String?
    var createdAt: Date
    var reminderSent: Bool
    
    init(
        id: UUID = UUID(),
        propertyId: UUID,
        propertyTitle: String,
        tenantId: UUID,
        tenantName: String,
        tenantEmail: String,
        ownerId: UUID,
        ownerName: String,
        ownerEmail: String,
        scheduledDate: Date,
        status: VisitStatus = .pending,
        proposedAlternativeDate: Date? = nil,
        notes: String? = nil,
        rating: Int? = nil,
        review: String? = nil,
        createdAt: Date = Date(),
        reminderSent: Bool = false
    ) {
        self.id = id
        self.propertyId = propertyId
        self.propertyTitle = propertyTitle
        self.tenantId = tenantId
        self.tenantName = tenantName
        self.tenantEmail = tenantEmail
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.ownerEmail = ownerEmail
        self.scheduledDate = scheduledDate
        self.status = status
        self.proposedAlternativeDate = proposedAlternativeDate
        self.notes = notes
        self.rating = rating
        self.review = review
        self.createdAt = createdAt
        self.reminderSent = reminderSent
    }
    
    var isPast: Bool {
        scheduledDate < Date()
    }
    
    var isUpcoming: Bool {
        scheduledDate > Date() && (status == .accepted || status == .pending)
    }
    
    var canBeEvaluated: Bool {
        status == .completed && rating == nil
    }
}

// MARK: - Core Data Extension
extension VisitModel {
    init?(from managedObject: NSManagedObject) {
        guard let id = managedObject.value(forKey: "id") as? UUID,
              let propertyId = managedObject.value(forKey: "propertyId") as? UUID,
              let propertyTitle = managedObject.value(forKey: "propertyTitle") as? String,
              let tenantId = managedObject.value(forKey: "tenantId") as? UUID,
              let tenantName = managedObject.value(forKey: "tenantName") as? String,
              let tenantEmail = managedObject.value(forKey: "tenantEmail") as? String,
              let ownerId = managedObject.value(forKey: "ownerId") as? UUID,
              let ownerName = managedObject.value(forKey: "ownerName") as? String,
              let ownerEmail = managedObject.value(forKey: "ownerEmail") as? String,
              let scheduledDate = managedObject.value(forKey: "scheduledDate") as? Date,
              let statusString = managedObject.value(forKey: "status") as? String,
              let status = VisitStatus(rawValue: statusString),
              let createdAt = managedObject.value(forKey: "createdAt") as? Date else {
            return nil
        }
        
        self.id = id
        self.propertyId = propertyId
        self.propertyTitle = propertyTitle
        self.tenantId = tenantId
        self.tenantName = tenantName
        self.tenantEmail = tenantEmail
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.ownerEmail = ownerEmail
        self.scheduledDate = scheduledDate
        self.status = status
        self.proposedAlternativeDate = managedObject.value(forKey: "proposedAlternativeDate") as? Date
        self.notes = managedObject.value(forKey: "notes") as? String
        self.rating = managedObject.value(forKey: "rating") as? Int
        self.review = managedObject.value(forKey: "review") as? String
        self.createdAt = createdAt
        self.reminderSent = managedObject.value(forKey: "reminderSent") as? Bool ?? false
    }
    
    func toManagedObject(context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: "Visit", in: context)!
        let managedObject = NSManagedObject(entity: entity, insertInto: context)
        
        managedObject.setValue(id, forKey: "id")
        managedObject.setValue(propertyId, forKey: "propertyId")
        managedObject.setValue(propertyTitle, forKey: "propertyTitle")
        managedObject.setValue(tenantId, forKey: "tenantId")
        managedObject.setValue(tenantName, forKey: "tenantName")
        managedObject.setValue(tenantEmail, forKey: "tenantEmail")
        managedObject.setValue(ownerId, forKey: "ownerId")
        managedObject.setValue(ownerName, forKey: "ownerName")
        managedObject.setValue(ownerEmail, forKey: "ownerEmail")
        managedObject.setValue(scheduledDate, forKey: "scheduledDate")
        managedObject.setValue(status.rawValue, forKey: "status")
        managedObject.setValue(proposedAlternativeDate, forKey: "proposedAlternativeDate")
        managedObject.setValue(notes, forKey: "notes")
        managedObject.setValue(rating, forKey: "rating")
        managedObject.setValue(review, forKey: "review")
        managedObject.setValue(createdAt, forKey: "createdAt")
        managedObject.setValue(reminderSent, forKey: "reminderSent")
        
        return managedObject
    }
}

