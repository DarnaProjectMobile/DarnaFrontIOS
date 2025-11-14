//
//  VisitStore.swift
//  DarnaApp
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class VisitStore: ObservableObject {
    @Published var visits: [VisitModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        loadVisits()
    }
    
    func loadVisits() {
        isLoading = true
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Visit")
        
        do {
            let results = try viewContext.fetch(request) as? [NSManagedObject] ?? []
            visits = results.compactMap { VisitModel(from: $0) }
            visits.sort { $0.scheduledDate > $1.scheduledDate }
        } catch {
            errorMessage = "Erreur lors du chargement: \(error.localizedDescription)"
            print("Erreur: \(error)")
        }
        
        isLoading = false
    }
    
    func add(_ visit: VisitModel) {
        let managedObject = visit.toManagedObject(context: viewContext)
        
        do {
            try viewContext.save()
            visits.insert(visit, at: 0)
            visits.sort { $0.scheduledDate > $1.scheduledDate }
            
            // Envoyer notification au propriétaire
            sendNotificationToOwner(for: visit)
        } catch {
            errorMessage = "Erreur lors de l'ajout: \(error.localizedDescription)"
            print("Erreur: \(error)")
        }
    }
    
    func update(_ visit: VisitModel) {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Visit")
        request.predicate = NSPredicate(format: "id == %@", visit.id as CVarArg)
        
        do {
            let results = try viewContext.fetch(request) as? [NSManagedObject]
            if let managedObject = results?.first {
                managedObject.setValue(visit.propertyId, forKey: "propertyId")
                managedObject.setValue(visit.propertyTitle, forKey: "propertyTitle")
                managedObject.setValue(visit.tenantId, forKey: "tenantId")
                managedObject.setValue(visit.tenantName, forKey: "tenantName")
                managedObject.setValue(visit.tenantEmail, forKey: "tenantEmail")
                managedObject.setValue(visit.ownerId, forKey: "ownerId")
                managedObject.setValue(visit.ownerName, forKey: "ownerName")
                managedObject.setValue(visit.ownerEmail, forKey: "ownerEmail")
                managedObject.setValue(visit.scheduledDate, forKey: "scheduledDate")
                managedObject.setValue(visit.status.rawValue, forKey: "status")
                managedObject.setValue(visit.proposedAlternativeDate, forKey: "proposedAlternativeDate")
                managedObject.setValue(visit.notes, forKey: "notes")
                managedObject.setValue(visit.rating, forKey: "rating")
                managedObject.setValue(visit.review, forKey: "review")
                managedObject.setValue(visit.reminderSent, forKey: "reminderSent")
                
                try viewContext.save()
                
                if let index = visits.firstIndex(where: { $0.id == visit.id }) {
                    visits[index] = visit
                }
                visits.sort { $0.scheduledDate > $1.scheduledDate }
                
                // Envoyer notification si changement de statut
                if visit.status == .accepted || visit.status == .rejected || visit.status == .rescheduled {
                    sendNotificationToTenant(for: visit)
                }
            }
        } catch {
            errorMessage = "Erreur lors de la mise à jour: \(error.localizedDescription)"
            print("Erreur: \(error)")
        }
    }
    
    func delete(_ visit: VisitModel) {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Visit")
        request.predicate = NSPredicate(format: "id == %@", visit.id as CVarArg)
        
        do {
            let results = try viewContext.fetch(request) as? [NSManagedObject]
            if let managedObject = results?.first {
                viewContext.delete(managedObject)
                try viewContext.save()
                visits.removeAll { $0.id == visit.id }
            }
        } catch {
            errorMessage = "Erreur lors de la suppression: \(error.localizedDescription)"
            print("Erreur: \(error)")
        }
    }
    
    func getVisitsForUser(userId: UUID, isOwner: Bool) -> [VisitModel] {
        if isOwner {
            return visits.filter { $0.ownerId == userId }
        } else {
            return visits.filter { $0.tenantId == userId }
        }
    }
    
    func getUpcomingVisits(userId: UUID, isOwner: Bool) -> [VisitModel] {
        return getVisitsForUser(userId: userId, isOwner: isOwner)
            .filter { $0.isUpcoming }
    }
    
    func getPastVisits(userId: UUID, isOwner: Bool) -> [VisitModel] {
        return getVisitsForUser(userId: userId, isOwner: isOwner)
            .filter { $0.isPast || $0.status == .completed }
    }
    
    func getVisitsForDate(_ date: Date, userId: UUID, isOwner: Bool) -> [VisitModel] {
        let calendar = Calendar.current
        return getVisitsForUser(userId: userId, isOwner: isOwner)
            .filter { calendar.isDate($0.scheduledDate, inSameDayAs: date) }
    }
    
    // MARK: - Notifications
    private func sendNotificationToOwner(for visit: VisitModel) {
        NotificationService.shared.sendVisitRequestNotification(to: visit.ownerEmail, visit: visit)
    }
    
    private func sendNotificationToTenant(for visit: VisitModel) {
        NotificationService.shared.sendVisitStatusNotification(to: visit.tenantEmail, visit: visit)
    }
    
    func scheduleReminders() {
        let upcomingVisits = visits.filter { $0.isUpcoming && !$0.reminderSent }
        
        for visit in upcomingVisits {
            NotificationService.shared.scheduleVisitReminder(for: visit, hoursBefore: 24)
            var updatedVisit = visit
            updatedVisit.reminderSent = true
            update(updatedVisit)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

