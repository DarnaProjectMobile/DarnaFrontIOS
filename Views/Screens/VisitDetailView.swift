import SwiftUI

struct VisitDetailView: View {
    @State private var visit: Visit
    @ObservedObject var viewModel: VisitListViewModel
    @State private var isEditing = false
    @State private var showDeleteAlert = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(visit: Visit, viewModel: VisitListViewModel) {
        _visit = State(initialValue: visit)
        self.viewModel = viewModel
    }
    
    var body: some View {
        Form {
            Section(header: Text("Détails de la visite")) {
                HStack {
                    Text("Statut:")
                    Spacer()
                    if isEditing {
                        Picker("Statut", selection: $visit.status) {
                            ForEach(Visit.VisitStatus.allCases, id: \.self) { status in
                                Text(status.rawValue.capitalized).tag(status)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    } else {
                        Text(visit.status.rawValue.capitalized)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                if isEditing {
                    DatePicker("Date et heure", selection: $visit.visitDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                } else {
                    HStack {
                        Text("Date et heure:")
                        Spacer()
                        Text(formatDate(visit.visitDate))
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("ID Propriété:")
                    Spacer()
                    Text(visit.propertyId.prefix(8) + "...")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("ID Client:")
                    Spacer()
                    Text(visit.clientId.prefix(8) + "...")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("ID Collecteur:")
                    Spacer()
                    Text(visit.collectorId.prefix(8) + "...")
                        .foregroundColor(.secondary)
                }
                
                if let notes = visit.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes:")
                            .font(.headline)
                        if isEditing {
                            TextEditor(text: Binding(
                                get: { notes },
                                set: { visit.notes = $0 }
                            ))
                            .frame(minHeight: 100)
                        } else {
                            Text(notes)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        }
                    }
                } else if isEditing {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes (optionnel):")
                            .font(.headline)
                        TextEditor(text: Binding(
                            get: { "" },
                            set: { visit.notes = $0.isEmpty ? nil : $0 }
                        ))
                        .frame(minHeight: 100)
                    }
                }
            }
            
            if !isEditing {
                Section {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Supprimer la visite")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationTitle("Détails de la visite")
        .navigationBarItems(
            trailing: Button(isEditing ? "Enregistrer" : "Modifier") {
                if isEditing {
                    saveChanges()
                }
                isEditing.toggle()
            }
        )
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Erreur"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Supprimer la visite"),
                message: Text("Êtes-vous sûr de vouloir supprimer cette visite ? Cette action est irréversible."),
                primaryButton: .destructive(Text("Supprimer")) {
                    viewModel.deleteVisit(visit.id)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var statusColor: Color {
        switch visit.status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
    
    private func saveChanges() {
        let updateData = UpdateVisitRequest(
            status: visit.status,
            notes: visit.notes,
            visitDate: visit.visitDate
        )
        
        viewModel.updateVisit(visit.id, with: updateData) { success in
            if !success {
                errorMessage = viewModel.errorMessage ?? "Erreur lors de la mise à jour"
                showError = true
            }
        }
    }
}

struct VisitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let visit = Visit(
            id: "1",
            propertyId: "prop123",
            clientId: "client123",
            collectorId: "collector123",
            visitDate: Date(),
            status: .pending,
            notes: "Visite pour évaluation",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return NavigationView {
            VisitDetailView(visit: visit, viewModel: VisitListViewModel())
        }
    }
}
