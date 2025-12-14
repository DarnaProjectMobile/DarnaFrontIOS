import SwiftUI

struct VisitListView: View {
    @StateObject private var viewModel = VisitListViewModel()
    @State private var showingAddVisit = false
    let userType: UserType
    let userId: String
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Chargement des visites...")
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text("Erreur: \(error)")
                            .foregroundColor(.red)
                        Button("Réessayer") {
                            viewModel.fetchVisits(userId: userId, userType: userType)
                        }
                    }
                } else {
                    List {
                        ForEach(viewModel.visits) { visit in
                            NavigationLink(destination: VisitDetailView(visit: visit, viewModel: viewModel)) {
                                VisitRow(visit: visit)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let visit = viewModel.visits[index]
                                viewModel.deleteVisit(visit.id)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Mes Visites")
            .navigationBarItems(
                trailing: userType == .client ? 
                    Button(action: { showingAddVisit = true }) {
                        Image(systemName: "plus")
                    } : nil
            )
            .sheet(isPresented: $showingAddVisit) {
                AddVisitView(isPresented: $showingAddVisit, viewModel: viewModel, userId: userId)
            }
            .onAppear {
                viewModel.fetchVisits(userId: userId, userType: userType)
            }
        }
    }
}

struct VisitRow: View {
    let visit: Visit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Propriété: \(visit.propertyId.prefix(6))...")
                    .font(.headline)
                Spacer()
                statusBadge
            }
            
            Text("Date: \(formatDate(visit.visitDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let notes = visit.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var statusBadge: some View {
        Text(visit.status.rawValue.capitalized)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .foregroundColor(.white)
            .cornerRadius(8)
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
}

struct VisitListView_Previews: PreviewProvider {
    static var previews: some View {
        VisitListView(userType: .client, userId: "123")
    }
}
