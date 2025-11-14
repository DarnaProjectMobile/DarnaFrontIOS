//
//  VisitReservationView.swift
//  DarnaApp
//

import SwiftUI

struct VisitReservationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var visitStore: VisitStore
    
    let userId: UUID
    let isOwner: Bool
    
    @State private var propertyTitle = ""
    @State private var selectedDate = Date()
    @State private var selectedHour = 9
    @State private var selectedMinute = 0
    @State private var notes = ""
    @State private var ownerName = "Propriétaire"
    @State private var ownerEmail = "owner@example.com"
    @State private var ownerId = UUID()
    @State private var propertyId = UUID()
    
    private let hours = Array(8...20)
    private let minutes = [0, 15, 30, 45]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations du bien") {
                    TextField("Titre du bien", text: $propertyTitle)
                }
                
                Section("Propriétaire") {
                    TextField("Nom du propriétaire", text: $ownerName)
                    TextField("Email du propriétaire", text: $ownerEmail)
                }
                
                Section("Date et heure de visite") {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                    
                    HStack {
                        Text("Heure")
                        Spacer()
                        Picker("Heure", selection: $selectedHour) {
                            ForEach(hours, id: \.self) { hour in
                                Text("\(hour)h").tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Picker("Minute", selection: $selectedMinute) {
                            ForEach(minutes, id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Notes (optionnel)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Réserver une visite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Réserver") {
                        reserveVisit()
                    }
                    .disabled(propertyTitle.isEmpty || ownerName.isEmpty || ownerEmail.isEmpty)
                }
            }
        }
    }
    
    private func reserveVisit() {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        dateComponents.hour = selectedHour
        dateComponents.minute = selectedMinute
        
        guard let scheduledDate = calendar.date(from: dateComponents) else { return }
        
        let visit = VisitModel(
            propertyId: propertyId,
            propertyTitle: propertyTitle,
            tenantId: userId,
            tenantName: "Locataire", // En production, récupérer depuis l'auth
            tenantEmail: "tenant@example.com", // En production, récupérer depuis l'auth
            ownerId: ownerId,
            ownerName: ownerName,
            ownerEmail: ownerEmail,
            scheduledDate: scheduledDate,
            status: .pending,
            notes: notes.isEmpty ? nil : notes
        )
        
        visitStore.add(visit)
        dismiss()
    }
}

