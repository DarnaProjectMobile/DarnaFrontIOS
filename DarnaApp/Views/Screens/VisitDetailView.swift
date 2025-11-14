//
//  VisitDetailView.swift
//  DarnaApp
//

import SwiftUI

struct VisitDetailView: View {
    @Environment(\.dismiss) var dismiss
    let visit: VisitModel
    @ObservedObject var visitStore: VisitStore
    let isOwner: Bool
    
    @State private var showReschedule = false
    @State private var proposedDate = Date()
    @State private var proposedHour = 9
    @State private var proposedMinute = 0
    
    private let hours = Array(8...20)
    private let minutes = [0, 15, 30, 45]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Property Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bien")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        Text(visit.propertyTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.primaryLight)
                    .cornerRadius(12)
                    
                    // Contact Info
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: isOwner ? "person.fill" : "person.badge.key.fill")
                                .foregroundColor(AppTheme.primary)
                            Text(isOwner ? "Locataire" : "Propriétaire")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        Text(isOwner ? visit.tenantName : visit.ownerName)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text(isOwner ? visit.tenantEmail : visit.ownerEmail)
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // Date & Time
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(AppTheme.primary)
                            Text("Date et heure")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        Text(formatFullDate(visit.scheduledDate))
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // Status
                    HStack {
                        Text("Statut:")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        StatusBadge(status: visit.status)
                    }
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // Notes
                    if let notes = visit.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text(notes)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.card)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    
                    // Actions for Owner
                    if isOwner && visit.status == .pending {
                        VStack(spacing: 12) {
                            Button {
                                acceptVisit()
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Accepter")
                                }
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            
                            Button {
                                showReschedule = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Proposer un autre créneau")
                                }
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                            }
                            
                            Button {
                                rejectVisit()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Refuser")
                                }
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Actions for Tenant
                    if !isOwner {
                        if visit.status == .rescheduled, let altDate = visit.proposedAlternativeDate {
                            VStack(spacing: 12) {
                                Text("Nouvelle date proposée: \(formatFullDate(altDate))")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(12)
                                
                                HStack(spacing: 12) {
                                    Button {
                                        acceptReschedule()
                                    } label: {
                                        Text("Accepter")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.green)
                                            .cornerRadius(12)
                                    }
                                    
                                    Button {
                                        rejectReschedule()
                                    } label: {
                                        Text("Refuser")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.red)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        
                        if visit.status == .accepted || visit.status == .pending {
                            Button {
                                cancelVisit()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Annuler la visite")
                                }
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Détails de la visite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showReschedule) {
                RescheduleView(
                    visit: visit,
                    visitStore: visitStore,
                    proposedDate: $proposedDate,
                    proposedHour: $proposedHour,
                    proposedMinute: $proposedMinute,
                    hours: hours,
                    minutes: minutes
                )
            }
        }
    }
    
    private func acceptVisit() {
        var updatedVisit = visit
        updatedVisit.status = .accepted
        visitStore.update(updatedVisit)
        dismiss()
    }
    
    private func rejectVisit() {
        var updatedVisit = visit
        updatedVisit.status = .rejected
        visitStore.update(updatedVisit)
        dismiss()
    }
    
    private func acceptReschedule() {
        guard let altDate = visit.proposedAlternativeDate else { return }
        var updatedVisit = visit
        updatedVisit.scheduledDate = altDate
        updatedVisit.status = .accepted
        updatedVisit.proposedAlternativeDate = nil
        visitStore.update(updatedVisit)
        dismiss()
    }
    
    private func rejectReschedule() {
        var updatedVisit = visit
        updatedVisit.status = .rejected
        updatedVisit.proposedAlternativeDate = nil
        visitStore.update(updatedVisit)
        dismiss()
    }
    
    private func cancelVisit() {
        var updatedVisit = visit
        updatedVisit.status = .cancelled
        visitStore.update(updatedVisit)
        dismiss()
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
}

struct RescheduleView: View {
    @Environment(\.dismiss) var dismiss
    let visit: VisitModel
    @ObservedObject var visitStore: VisitStore
    @Binding var proposedDate: Date
    @Binding var proposedHour: Int
    @Binding var proposedMinute: Int
    let hours: [Int]
    let minutes: [Int]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Nouvelle date et heure") {
                    DatePicker("Date", selection: $proposedDate, displayedComponents: .date)
                    
                    HStack {
                        Text("Heure")
                        Spacer()
                        Picker("Heure", selection: $proposedHour) {
                            ForEach(hours, id: \.self) { hour in
                                Text("\(hour)h").tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Picker("Minute", selection: $proposedMinute) {
                            ForEach(minutes, id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            }
            .navigationTitle("Proposer un créneau")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Proposer") {
                        proposeReschedule()
                    }
                }
            }
        }
    }
    
    private func proposeReschedule() {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: proposedDate)
        dateComponents.hour = proposedHour
        dateComponents.minute = proposedMinute
        
        guard let newDate = calendar.date(from: dateComponents) else { return }
        
        var updatedVisit = visit
        updatedVisit.status = .rescheduled
        updatedVisit.proposedAlternativeDate = newDate
        visitStore.update(updatedVisit)
        dismiss()
    }
}

