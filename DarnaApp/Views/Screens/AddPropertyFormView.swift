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
    @FocusState private var focusedField: Field?

    enum Field {
        case title, price, description, nbrMax, nbrActuel
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Section
                        headerSection
                        
                        // Basic Information Section
                        formSection(title: "Informations de base", icon: "info.circle.fill") {
                            customTextField(
                                title: "Titre de l'annonce",
                                text: $title,
                                icon: "text.bubble.fill",
                                placeholder: "Ex: Villa S+3 à Ariana",
                                field: .title
                            )
                            
                            // Map-based location picker
                            InlineMapLocationPicker(location: $location)
                            
                            customTextField(
                                title: "Prix mensuel",
                                text: $price,
                                icon: "dollarsign.circle.fill",
                                placeholder: "0",
                                field: .price
                            )
                            .keyboardType(.decimalPad)
                        }
                        
                        // Image Section
                        formSection(title: "Photo", icon: "photo.fill") {
                            imagePickerSection
                        }
                        
                        // Property Details Section
                        formSection(title: "Détails du logement", icon: "house.fill") {
                            typePicker
                            
                            customTextEditor(
                                title: "Description",
                                text: $description,
                                icon: "text.alignleft",
                                placeholder: "Décrivez votre logement, ses avantages, le quartier..."
                            )
                        }
                        
                        // Availability Section
                        formSection(title: "Disponibilité", icon: "calendar") {
                            availabilitySection
                        }
                        
                        // Collocators Section
                        formSection(title: "Colocataires", icon: "person.2.fill") {
                            HStack(spacing: 16) {
                                customTextField(
                                    title: "Maximum",
                                    text: $nbrCollocateurMax,
                                    icon: "person.3.fill",
                                    placeholder: "4",
                                    field: .nbrMax
                                )
                                .keyboardType(.numberPad)
                                
                                customTextField(
                                    title: "Actuel",
                                    text: $nbrCollocateurActuel,
                                    icon: "person.fill",
                                    placeholder: "0",
                                    field: .nbrActuel
                                )
                                .keyboardType(.numberPad)
                            }
                        }
                        
                        // Error Message
                        if let msg = errorMessage {
                            errorBanner(message: msg)
                        }
                        
                        // Save Button
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(propertyToEdit == nil ? "Nouvelle Annonce" : "Modifier l'annonce")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.textSecondary)
                            .font(.system(size: 24))
                    }
                }
            }
            .onAppear { loadExistingIfNeeded() }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: propertyToEdit == nil ? "plus.circle.fill" : "pencil.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.primary)
            
            Text(propertyToEdit == nil ? "Créer une nouvelle annonce" : "Modifier l'annonce")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Remplissez les informations ci-dessous")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Form Section Wrapper
    private func formSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            content()
        }
        .padding(20)
        .background(AppTheme.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Custom Text Field
    private func customTextField(
        title: String,
        text: Binding<String>,
        icon: String,
        placeholder: String,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textPrimary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary.opacity(0.7))
                    .frame(width: 20)
                
                TextField(placeholder, text: text)
                    .focused($focusedField, equals: field)
                    .textFieldStyle(.plain)
                    .font(.body)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(focusedField == field ? AppTheme.primaryLight.opacity(0.5) : Color.gray.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focusedField == field ? AppTheme.primary : Color.clear, lineWidth: 2)
            )
        }
    }
    
    // MARK: - Custom Text Editor
    private func customTextEditor(
        title: String,
        text: Binding<String>,
        icon: String,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary.opacity(0.7))
                    .font(.system(size: 16))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: text)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Availability Section
    private var availabilitySection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(AppTheme.primary.opacity(0.7))
                    .font(.system(size: 16))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Date de début")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.08))
            )
            
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .foregroundColor(AppTheme.primary.opacity(0.7))
                    .font(.system(size: 16))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Date de fin")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.08))
            )
        }
    }
    
    // MARK: - Error Banner
    private func errorBanner(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: {
            focusedField = nil
            Task { await saveProperty() }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: propertyToEdit == nil ? "checkmark.circle.fill" : "arrow.clockwise.circle.fill")
                        .font(.system(size: 18))
                }
                
                Text(isLoading ? "Enregistrement..." : (propertyToEdit == nil ? "Publier l'annonce" : "Enregistrer les modifications"))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isLoading ? AppTheme.primary.opacity(0.7) : AppTheme.primary)
            )
            .foregroundColor(.white)
        }
        .disabled(isLoading)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    private func saveProperty() async {
        guard !title.isEmpty,
              !location.isEmpty,
              !price.isEmpty,
              let selectedImage = selectedImage,
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

        let imagesArray = [selectedImage]

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
                    images: [imageBase64],
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
   
    // MARK: - Type Picker
    private var typePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "house.lodge.fill")
                    .foregroundColor(AppTheme.primary.opacity(0.7))
                    .font(.system(size: 16))
                Text("Type de logement")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Menu {
                ForEach(["S", "S+1", "S+2", "S+3", "S+4", "Chambre"], id: \.self) { value in
                    Button(action: { selectedType = value }) {
                        HStack {
                            Text(value)
                            if selectedType == value {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedType)
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppTheme.textSecondary)
                        .font(.system(size: 12))
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
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
            HStack(spacing: 10) {
                Image(systemName: "photo.fill")
                    .foregroundColor(AppTheme.primary.opacity(0.7))
                    .font(.system(size: 16))
                Text("Photo principale")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Group {
                    if let selectedImage = selectedImage {
                        ZStack(alignment: .bottomTrailing) {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .cornerRadius(16)
                                .clipped()
                            
                            // Edit overlay
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                        .padding(12)
                                }
                                Spacer()
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(AppTheme.primary)
                            
                            VStack(spacing: 4) {
                                Text("Ajouter une photo")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("Appuyez pour sélectionner")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                        .foregroundColor(AppTheme.primary.opacity(0.3))
                                )
                        )
                    }
                }
            }
            .buttonStyle(.plain)
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
