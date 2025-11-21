//
//  AddPropertyFormView.swift
//  DarnaApp
//

import SwiftUI

struct AddPropertyFormView: View {
    @Environment(\.dismiss) var dismiss
    var propertyToEdit: Property? = nil
    var onPropertySaved: ((Property) -> Void)?

    @State private var title = ""
    @State private var location = ""
    @State private var price = ""
    @State private var imageUrl = ""
    @State private var selectedType = "S"
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @State private var description = ""
    @State private var nbrCollocateurMax = "4"
    @State private var nbrCollocateurActuel = "0"
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var didLoadExisting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    TextField("Titre de l’annonce", text: $title)
                        .textFieldStyle(CustomTextFieldStyle())

                    TextField("Localisation", text: $location)
                        .textFieldStyle(CustomTextFieldStyle())

                    TextField("Prix (DT)", text: $price)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(CustomTextFieldStyle())

                    TextField("Lien vers l'image", text: $imageUrl)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(CustomTextFieldStyle())

                    typePicker

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Disponibilité")
                            .font(.footnote)
                            .foregroundColor(AppTheme.textSecondary)

                        DatePicker("Date de début", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)

                        DatePicker("Date de fin", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }

                    TextField("Description", text: $description, axis: .vertical)
                        .textFieldStyle(CustomTextFieldStyle())
                        .lineLimit(3)
                    
                    TextField("Nombre maximum de colocataires", text: $nbrCollocateurMax)
                        .keyboardType(.numberPad)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    TextField("Nombre actuel de colocataires", text: $nbrCollocateurActuel)
                        .keyboardType(.numberPad)
                        .textFieldStyle(CustomTextFieldStyle())

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button(action: {
                        Task { await saveProperty() }
                    }, label: {
                        buttonLabel
                    })
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.primary)
                    .cornerRadius(12)
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .navigationTitle(propertyToEdit == nil ? "Nouvelle Annonce" : "Modifier l’annonce")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadExistingIfNeeded() }
        }
    }

    private func saveProperty() async {
        guard !title.isEmpty,
              !location.isEmpty,
              !price.isEmpty,
              !imageUrl.isEmpty,
              let priceValue = Double(price),
              let nbrMax = Int(nbrCollocateurMax),
              let nbrActuel = Int(nbrCollocateurActuel) else {
            errorMessage = "Merci de remplir tous les champs requis avec des valeurs valides."
            return
        }

        guard startDate <= endDate else {
            errorMessage = "La date de fin doit être postérieure à la date de début."
            return
        }
        
        guard nbrActuel <= nbrMax else {
            errorMessage = "Le nombre actuel de colocataires ne peut pas dépasser le maximum."
            return
        }

        // Convert single image URL to array (backend expects array)
        let imagesArray = imageUrl.isEmpty ? [] : [imageUrl]

        isLoading = true
        do {
            if let propertyToEdit {
                let updated = try await PropertyService.shared.updateProperty(
                    id: propertyToEdit.id,
                    title: title,
                    description: description.isEmpty ? nil : description,
                    price: priceValue,
                    location: location,
                    type: selectedType,
                    startDate: startDate,
                    endDate: endDate,
                    images: imagesArray.isEmpty ? nil : imagesArray,
                    nbrCollocateurMax: nbrMax,
                    nbrCollocateurActuel: nbrActuel
                )

                await MainActor.run {
                    onPropertySaved?(updated)
                    dismiss()
                }
            } else {
                let property = try await PropertyService.shared.createProperty(
                    title: title,
                    description: description.isEmpty ? "Aucune description" : description,
                    price: priceValue,
                    location: location,
                    type: selectedType,
                    startDate: startDate,
                    endDate: endDate,
                    images: imagesArray,
                    nbrCollocateurMax: nbrMax,
                    nbrCollocateurActuel: nbrActuel
                )

                await MainActor.run {
                    onPropertySaved?(property)
                    dismiss()
                }
            }
        } catch {
            await MainActor.run {
                if let networkError = error as? NetworkError {
                    errorMessage = networkError.localizedDescription
                } else {
                    errorMessage = "Erreur lors de l'enregistrement : \(error.localizedDescription)"
                }
            }
        }

        isLoading = false
    }

    @ViewBuilder
    private var buttonLabel: some View {
        if isLoading {
            ProgressView()
                .tint(.white)
        } else {
            Text(propertyToEdit == nil ? "Enregistrer" : "Mettre à jour")
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
    
    private var typePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type de logement")
                .font(.footnote)
                .foregroundColor(AppTheme.textSecondary)

            Picker("Type de logement", selection: $selectedType) {
                ForEach(["S", "S+1", "S+2", "S+3", "S+4", "Chambre"], id: \.self) { value in
                    Text(value).tag(value)
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    private func loadExistingIfNeeded() {
        guard !didLoadExisting, let property = propertyToEdit else { return }
        didLoadExisting = true
        
        title = property.title
        location = property.location ?? ""
        price = String(format: "%.0f", property.price)
        imageUrl = property.image ?? ""
        selectedType = property.type ?? selectedType
        description = property.description ?? ""
        nbrCollocateurMax = String(property.nbrCollocateurMax ?? 4)
        nbrCollocateurActuel = String(property.nbrCollocateurActuel ?? 0)
        startDate = property.startDate ?? Date()
        endDate = property.endDate ?? startDate.addingTimeInterval(60 * 60 * 24 * 30)
    }
}
