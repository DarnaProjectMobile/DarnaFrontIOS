//
//  VisitEditSheet.swift
//  DarnaApp
//
//

import SwiftUI

struct VisitEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: VisitViewModel
    private let visit: Visit
    
    @State private var draft: VisitEditDraft
    
    init(viewModel: VisitViewModel, visit: Visit) {
        self.viewModel = viewModel
        self.visit = visit
        _draft = State(initialValue: VisitEditDraft(visit: visit))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Logement") {
                    Text(visit.title)
                    if let contact = visit.contactPhone, !contact.isEmpty {
                        Text(contact)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Date et heure") {
                    DatePicker("Date", selection: $draft.newDate, displayedComponents: .date)
                    DatePicker("Heure", selection: $draft.newDate, displayedComponents: .hourAndMinute)
                }
                
                Section("Informations complémentaires") {
                    TextField("Téléphone", text: $draft.contactPhone)
                    TextField("Notes", text: $draft.notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Modifier la visite")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        Task {
                            await viewModel.updateVisit(with: draft)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

