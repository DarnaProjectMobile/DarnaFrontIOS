import SwiftUI

struct AddVisitView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: VisitListViewModel
    let userId: String
    
    @State private var selectedDate = Date()
    @State private var notes = ""
    @State private var propertyId = ""
    @State private var collectorId = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Détails de la visite")) {
                    DatePicker("Date et heure", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("ID de la propriété", text: $propertyId)
                        .autocapitalization(.none)
                    
                    TextField("ID du collecteur", text: $collectorId)
                        .autocapitalization(.none)
                    
                    TextField("Notes (optionnel)", text: $notes)
                        .frame(height: 80, alignment: .topLeading)
                        .multilineTextAlignment(.leading)
                }
            }
            .navigationTitle("Nouvelle visite")
            .navigationBarItems(
                leading: Button("Annuler") {
                    isPresented = false
                },
                trailing: Button("Ajouter") {
                    addVisit()
                }
                .disabled(propertyId.isEmpty || collectorId.isEmpty)
            )
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Erreur"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func addVisit() {
        let newVisit = CreateVisitRequest(
            propertyId: propertyId,
            clientId: userId,
            collectorId: collectorId,
            visitDate: selectedDate,
            notes: notes.isEmpty ? nil : notes
        )
        
        viewModel.createVisit(newVisit) { success in
            if success {
                isPresented = false
            } else {
                errorMessage = viewModel.errorMessage ?? "Erreur inconnue"
                showError = true
            }
        }
    }
}

struct AddVisitView_Previews: PreviewProvider {
    static var previews: some View {
        AddVisitView(
            isPresented: .constant(true),
            viewModel: VisitListViewModel(),
            userId: "123"
        )
    }
}
