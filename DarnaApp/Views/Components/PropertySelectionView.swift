import SwiftUI

struct PropertySelectionView: View {
    @Binding var selectedProperty: Property?
    let properties: [Property]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sélectionnez un bien")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Menu {
                ForEach(properties) { property in
                    Button(action: {
                        selectedProperty = property
                    }) {
                        Text(property.title)
                        if let location = property.location {
                            Text(location)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedProperty?.title ?? "Sélectionner un bien")
                        .foregroundColor(selectedProperty == nil ? .gray : AppTheme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppTheme.primary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            if let property = selectedProperty, let location = property.location {
                Text(location)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.horizontal)
            }
        }
    }
}

struct PropertySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PropertySelectionView(
            selectedProperty: .constant(nil),
            properties: [
                Property(id: "1", title: "Appartement Moderne", description: "Bel appartement", price: 1000, user: "1", ownerName: "John Doe", image: "", type: "Appartement", location: "Paris", startDate: nil, endDate: nil, createdAt: nil, updatedAt: nil),
                Property(id: "2", title: "Maison avec Jardin", description: "Maison spacieuse", price: 1500, user: "2", ownerName: "Jane Smith", image: "", type: "Maison", location: "Lyon", startDate: nil, endDate: nil, createdAt: nil, updatedAt: nil)
            ]
        )
        .padding()
    }
}
