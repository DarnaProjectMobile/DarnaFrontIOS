//
// AddPropertyFormView.swift
// DarnaApp
//

import SwiftUI
import PhotosUI

struct AddPropertyFormView: View {
    @Environment(\.dismiss) var dismiss
    var propertyToEdit: Property? = nil
    var onPropertySaved: ((Property) -> Void)?

    @State private var title = ""
    @State private var location = ""
    @State private var price = ""
    @State private var selectedImage: UIImage?
    @State private var imageBase64: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
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

                    imagePickerSection

                    typePicker

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Disponibilité")
                            .font(.footnote)
                            .foregroundColor(.gray)

                        DatePicker("Date de début", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)

                        DatePicker("Date de fin", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }

                    // Explicitly use the label and binding to avoid error
                    MultilineTextField(text: $description, placeholder: "Description")
                        .frame(minHeight: 100)

                    TextField("Nombre maximum de colocataires", text: $nbrCollocateurMax)
                        .keyboardType(.numberPad)
                        .textFieldStyle(CustomTextFieldStyle())

                    TextField("Nombre actuel de colocataires", text: $nbrCollocateurActuel)
                        .keyboardType(.numberPad)
                        .textFieldStyle(CustomTextFieldStyle())

                    if let msg = errorMessage {
                        Text(msg)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // The Spacer() that caused the confusing error has been removed.
                }
                .padding(20)
            }
            .navigationTitle(propertyToEdit == nil ? "Nouvelle Annonce" : "Modifier l’annonce")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button(action: {
                            Task { await saveProperty() }
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.blue)
                        }
                    }
                }
            }
            .onAppear { loadExistingIfNeeded() }
        }
    }

    private func saveProperty() async {
        guard !title.isEmpty,
              !location.isEmpty,
              !price.isEmpty,
              !imageBase64.isEmpty,
              let priceValue = Double(price),
              let nbrMax = Int(nbrCollocateurMax),
              let nbrActuel = Int(nbrCollocateurActuel) else {
            errorMessage = "Merci de remplir tous les champs requis."
            return
        }

        guard startDate <= endDate else {
            errorMessage = "La date de fin doit être après la date de début."
            return
        }

        guard nbrActuel <= nbrMax else {
            errorMessage = "Le nombre actuel dépasse le maximum."
            return
        }

        let imagesArray = [imageBase64]

        isLoading = true
        errorMessage = nil

        do {
            if let propertyToEdit {

                let updated = try await PropertyService.shared.updateProperty(
                    id: propertyToEdit.id,
                    title: title,
                    description: description,
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
                    onPropertySaved?(updated)
                    dismiss()
                }

            } else {

                let created = try await PropertyService.shared.createProperty(
                    title: title,
                    description: description,
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
                    onPropertySaved?(created)
                    dismiss()
                }
            }

        } catch {
            await MainActor.run {
                errorMessage = "Erreur de sauvegarde: \(error.localizedDescription)"
            }
        }

        isLoading = false
    }
    
    private var typePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type de logement")
                .font(.footnote)
                .foregroundColor(.gray)

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
        // For editing, keep the existing image URL as base64 if it exists
        if let existingImageUrl = property.image, !existingImageUrl.isEmpty {
            imageBase64 = existingImageUrl
        }
        selectedType = property.type ?? "S"
        description = property.description ?? ""
        nbrCollocateurMax = String(property.nbrCollocateurMax ?? 4)
        nbrCollocateurActuel = String(property.nbrCollocateurActuel ?? 0)
        startDate = property.startDate ?? Date()
        endDate = property.endDate ?? Date()
    }
    
    // MARK: - Image Picker Section
    private var imagePickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Image")
                .font(.footnote)
                .foregroundColor(.gray)
            
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(12)
                            .clipped()
                    } else {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.primary)
                            .frame(width: 100, height: 100)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedImage == nil ? "Sélectionner une image" : "Image sélectionnée")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                        Text(selectedImage == nil ? "Appuyez pour choisir" : "Appuyez pour changer")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let newItem = newItem {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            selectedImage = uiImage
                            imageBase64 = convertImageToBase64(uiImage)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Convert Image to Base64
    private func convertImageToBase64(_ image: UIImage) -> String {
        // Compress image to reduce size (max 1MB)
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            return ""
        }
        
        // Convert to base64 string with data URI prefix
        let base64String = imageData.base64EncodedString()
        return "data:image/jpeg;base64,\(base64String)"
    }
}

// MARK: - Multiline Field

struct MultilineTextField: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {

            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }

            TextEditor(text: $text)
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}