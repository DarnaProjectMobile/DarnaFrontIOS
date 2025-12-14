//
//  PubliciteFormView.swift
//  DarnaApp
//

import SwiftUI
import PhotosUI

struct PubliciteFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PubliciteViewModel
    var editingPublicite: Publicite?
    
    // MARK: - Basic Fields
    @State private var titre = ""
    @State private var description = ""
    @State private var type = "Réduction"
    @State private var imageUrl = ""
    @State private var dateDebut = Date()
    @State private var dateFin = Date().addingTimeInterval(86400 * 14)
    @State private var hasChanges = false
    @State private var showDiscardAlert = false
    @FocusState private var focusedField: Field?
    
    // MARK: - Image Upload
    @State private var selectedImage: UIImage?
    @State private var imageBase64: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var savedImageFileName: String?
    
    // MARK: - Conditional Fields - Réduction
    @State private var pourcentageReduction: Double? = nil
    @State private var conditionsUtilisation = ""
    
    // MARK: - Conditional Fields - Promotion
    @State private var detailPromotion = ""
    
    // MARK: - Conditional Fields - Jeu
    @State private var nombreCases = 8
    @State private var recompenses: [RecompenseJeu] = []
    @State private var showAddRecompense = false
    @State private var newRecompenseText = ""
    @State private var newRecompensePourcentage: Double = 0
    @State private var newRecompenseProbabilite: Double = 10
    
    private let types = ["Réduction", "Promo", "Bon plan"]
    
    enum Field {
        case titre, description, pourcentage, conditions, detailPromo, recompense
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        
                        if hasChanges && editingPublicite != nil {
                            changeBanner
                        }
                        
                        formSections
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                    }
                }
                
                saveBar
            }
            .navigationTitle(editingPublicite == nil ? "Nouvelle publicité" : "Modifier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if hasChanges {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                            Text("Annuler")
                        }
                        .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .onAppear {
                if let pub = editingPublicite {
                    load(pub)
                    
                    // Charger l'image sauvegardée localement si elle existe
                    if let fileName = ImageStorageManager.shared.getFirstImageFileName(for: pub.id),
                       let image = ImageStorageManager.shared.loadImage(fileName: fileName) {
                        selectedImage = image
                        savedImageFileName = fileName
                        imageBase64 = ImageStorageManager.shared.imageToBase64(fileName: fileName) ?? ""
                    }
                } else {
                    // Initialiser avec une récompense par défaut pour le jeu
                    if type == "Bon plan" {
                        initializeDefaultRecompenses()
                    }
                }
            }
            .onChange(of: titre) { _ in checkChanges() }
            .onChange(of: description) { _ in checkChanges() }
            .onChange(of: type) { _ in
                checkChanges()
                if type == "Bon plan" && recompenses.isEmpty {
                    initializeDefaultRecompenses()
                }
            }
            .onChange(of: pourcentageReduction) { _ in checkChanges() }
            .onChange(of: conditionsUtilisation) { _ in checkChanges() }
            .onChange(of: detailPromotion) { _ in checkChanges() }
            .onChange(of: imageBase64) { _ in checkChanges() }
            .onChange(of: dateDebut) { _ in checkChanges() }
            .onChange(of: dateFin) { _ in checkChanges() }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let newItem = newItem {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            await MainActor.run {
                                selectedImage = uiImage
                                
                                // Sauvegarder l'image localement
                                let publiciteId = editingPublicite?.id ?? UUID().uuidString
                                if let fileName = ImageStorageManager.shared.saveImage(uiImage, publiciteId: publiciteId) {
                                    savedImageFileName = fileName
                                }
                                
                                // Convertir en base64 pour l'envoi au backend
                                imageBase64 = convertImageToBase64(uiImage)
                            }
                        }
                    }
                }
            }
            .alert("Modifications non enregistrées", isPresented: $showDiscardAlert) {
                Button("Continuer", role: .cancel) { }
                Button("Abandonner", role: .destructive) { dismiss() }
            } message: {
                Text("Vous allez quitter sans enregistrer.")
            }
            .alert("Erreur", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Une erreur est survenue.")
            }
            .alert("Succès", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text(viewModel.successMessage)
            }
            .sheet(isPresented: $showAddRecompense) {
                addRecompenseSheet
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight)
                    .frame(width: 80, height: 80)
                Image(systemName: editingPublicite == nil ? "plus.circle.fill" : "pencil.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.primary)
            }
            Text(editingPublicite == nil ? "Créez une nouvelle publicité" : "Modifiez votre publicité")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.top, 20)
    }
    
    private var changeBanner: some View {
        HStack {
            Image(systemName: "pencil.circle.fill")
                .foregroundColor(.orange)
            Text("Modifications non enregistrées")
                .font(.caption)
                .foregroundColor(.orange)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.12))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    // MARK: - Sections
    private var formSections: some View {
        VStack(spacing: 20) {
            formCard(title: "Informations", icon: "info.circle.fill") {
                VStack(spacing: 16) {
                    textField(
                        title: "Titre *",
                        text: $titre,
                        placeholder: "Ex: Réduction Spéciale Rentrée",
                        icon: "text.bubble.fill",
                        field: .titre
                    )
                    textEditor(
                        title: "Description *",
                        text: $description,
                        placeholder: "Décrivez votre publicité...",
                        icon: "text.alignleft"
                    )
                    typePicker
                }
            }
            
            // Champs conditionnels selon le type
            if type == "Réduction" {
                reductionFields
            } else if type == "Promo" {
                promotionFields
            } else if type == "Bon plan" {
                jeuFields
            }
            
            imageUploadSection
            
            formCard(title: "Durée de validité", icon: "calendar") {
                VStack(spacing: 16) {
                    datePicker(title: "Date de début *", date: $dateDebut, icon: "calendar.badge.plus")
                    datePicker(title: "Date de fin *", date: $dateFin, icon: "calendar.badge.minus")
                    
                    if dateDebut > dateFin {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("La date de fin doit être postérieure.")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            previewSection
        }
    }
    
    // MARK: - Réduction Fields
    private var reductionFields: some View {
        formCard(title: "Détails de la réduction", icon: "percent") {
            VStack(alignment: .leading, spacing: 16) {
                // Pourcentage de réduction
                VStack(alignment: .leading, spacing: 6) {
                    Text("Pourcentage de réduction (%) *")
                        .font(.subheadline).fontWeight(.medium)
                    HStack(spacing: 10) {
                        Image(systemName: "tag")
                            .foregroundColor(AppTheme.primary.opacity(0.6))
                        TextField(
                            "Ex: 25",
                            value: Binding(
                                get: { pourcentageReduction ?? 0 },
                                set: { pourcentageReduction = $0 > 0 ? $0 : nil }
                            ),
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .pourcentage)
                        .textFieldStyle(.roundedBorder)
                        Text("%")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                // Conditions d'utilisation
                VStack(alignment: .leading, spacing: 6) {
                    Text("Conditions d'utilisation")
                        .font(.subheadline).fontWeight(.medium)
                    TextEditor(text: $conditionsUtilisation)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .focused($focusedField, equals: .conditions)
                }
            }
        }
    }
    
    // MARK: - Promotion Fields
    private var promotionFields: some View {
        formCard(title: "Détails de la promotion", icon: "tag.fill") {
            VStack(alignment: .leading, spacing: 6) {
                Text("Détail de la promotion *")
                    .font(.subheadline).fontWeight(.medium)
                TextField(
                    "Ex: 1+1 gratuit",
                    text: $detailPromotion
                )
                .focused($focusedField, equals: .detailPromo)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .detailPromo ? AppTheme.primary : .clear, lineWidth: 2)
                )
            }
        }
    }
    
    // MARK: - Jeu Fields
    private var jeuFields: some View {
        formCard(title: "Configuration de la roulette", icon: "gamecontroller.fill") {
            VStack(alignment: .leading, spacing: 16) {
                // Nombre de cases
                VStack(alignment: .leading, spacing: 6) {
                    Text("Nombre de cases")
                        .font(.subheadline).fontWeight(.medium)
                    Stepper(value: $nombreCases, in: 4...16, step: 1) {
                        HStack {
                            Image(systemName: "number")
                                .foregroundColor(AppTheme.primary.opacity(0.6))
                            Text("\(nombreCases) cases")
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
                
                Divider()
                
                // Liste des récompenses
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Récompenses")
                            .font(.subheadline).fontWeight(.medium)
                        Spacer()
                        Button {
                            showAddRecompense = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Ajouter")
                            }
                            .font(.caption)
                            .foregroundColor(AppTheme.primary)
                        }
                    }
                    
                    if recompenses.isEmpty {
                        Text("Aucune récompense ajoutée")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .italic()
                    } else {
                        ForEach(recompenses.indices, id: \.self) { index in
                            recompenseRow(recompense: recompenses[index], index: index)
                        }
                    }
                }
            }
        }
    }
    
    private func recompenseRow(recompense: RecompenseJeu, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recompense.text)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    if recompense.pourcentage > 0 {
                        Text("-\(Int(recompense.pourcentage))%")
                            .font(.caption)
                            .foregroundColor(AppTheme.primary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(recompense.probabilite))%")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text("probabilité")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                }
                Button {
                    recompenses.remove(at: index)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Image Upload Section
    private var imageUploadSection: some View {
        formCard(title: "Image de la publicité", icon: "photo") {
            VStack(alignment: .leading, spacing: 12) {
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
                            Text(selectedImage == nil ? "Sélectionner une image *" : "Image sélectionnée")
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
        }
    }
    
    // MARK: - Add Recompense Sheet
    private var addRecompenseSheet: some View {
        NavigationStack {
            Form {
                Section("Nouvelle récompense") {
                    TextField("Ex: -10%, Rien gagné", text: $newRecompenseText)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pourcentage de réduction: \(Int(newRecompensePourcentage))%")
                        Slider(value: $newRecompensePourcentage, in: 0...100, step: 5)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Probabilité: \(Int(newRecompenseProbabilite))%")
                        Slider(value: $newRecompenseProbabilite, in: 0...100, step: 5)
                    }
                }
            }
            .navigationTitle("Ajouter une récompense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        showAddRecompense = false
                        resetNewRecompense()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        if !newRecompenseText.isEmpty {
                            recompenses.append(RecompenseJeu(
                                text: newRecompenseText,
                                pourcentage: newRecompensePourcentage,
                                probabilite: newRecompenseProbabilite
                            ))
                            resetNewRecompense()
                            showAddRecompense = false
                        }
                    }
                    .disabled(newRecompenseText.isEmpty)
                }
            }
        }
    }
    
    private func resetNewRecompense() {
        newRecompenseText = ""
        newRecompensePourcentage = 0
        newRecompenseProbabilite = 10
    }
    
    private func initializeDefaultRecompenses() {
        recompenses = [
            RecompenseJeu(text: "-10%", pourcentage: 10, probabilite: 30),
            RecompenseJeu(text: "-20%", pourcentage: 20, probabilite: 20),
            RecompenseJeu(text: "-50%", pourcentage: 50, probabilite: 10),
            RecompenseJeu(text: "Rien gagné", pourcentage: 0, probabilite: 40)
        ]
    }
    
    private func formCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary)
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
            }
            content()
        }
        .padding(20)
        .background(AppTheme.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func textField(title: String, text: Binding<String>, placeholder: String, icon: String, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline).fontWeight(.medium)
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary.opacity(0.6))
                TextField(placeholder, text: text)
                    .focused($focusedField, equals: field)
                    .textFieldStyle(.plain)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(focusedField == field ? AppTheme.primaryLight.opacity(0.5) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focusedField == field ? AppTheme.primary : .clear, lineWidth: 2)
            )
        }
    }
    
    private func textEditor(title: String, text: Binding<String>, placeholder: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline).fontWeight(.medium)
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary.opacity(0.6))
                ZStack(alignment: .topLeading) {
                    if text.wrappedValue.isEmpty {
                        Text(placeholder)
                            .foregroundColor(Color.gray.opacity(0.5))
                            .padding(.vertical, 8)
                    }
                    TextEditor(text: text)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
    
    private var typePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type *").font(.subheadline).fontWeight(.medium)
            Picker("Type", selection: $type) {
                ForEach(types, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func datePicker(title: String, date: Binding<Date>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline).fontWeight(.medium)
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary.opacity(0.6))
                DatePicker("", selection: date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
        }
    }
    
    private var previewSection: some View {
        formCard(title: "Aperçu", icon: "eye.fill") {
            if isValid {
                PubliciteCardView(
                    publicite: previewPublicite,
                    isSponsor: true,
                    onEdit: nil,
                    onDelete: nil
                )
            } else {
                VStack {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 30))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                    Text("Complétez les champs obligatoires pour voir l'aperçu.")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 16)
            }
        }
    }
    
    private var previewPublicite: Publicite {
        Publicite(
            id: editingPublicite?.id ?? UUID().uuidString,
            titre: titre.isEmpty ? "Titre" : titre,
            description: description.isEmpty ? "Description de l'offre…" : description,
            type: type,
            image: imageBase64.isEmpty ? (imageUrl.isEmpty ? nil : imageUrl) : imageBase64,
            imageUrl: imageBase64.isEmpty ? (imageUrl.isEmpty ? nil : imageUrl) : imageBase64,
            pourcentageReduction: pourcentageReduction,
            dateDebut: ISO8601DateFormatter().string(from: dateDebut),
            dateFin: ISO8601DateFormatter().string(from: dateFin),
            partenaireId: editingPublicite?.partenaireId
        )
    }
    
    // MARK: - Save bar
    private var saveBar: some View {
        VStack {
            Spacer()
            Button {
                Task { await save() }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(AppTheme.onPrimary)
                    } else {
                        Image(systemName: editingPublicite == nil ? "paperplane.fill" : "checkmark.circle.fill")
                    }
                    Text(editingPublicite == nil ? "Publier la publicité" : "Enregistrer")
                        .fontWeight(.semibold)
                }
                .foregroundColor(AppTheme.onPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isValid ? AppTheme.primary : Color.gray.opacity(0.3))
                )
            }
            .disabled(!isValid || viewModel.isLoading)
            .padding()
            .background(
                LinearGradient(
                    colors: [AppTheme.background.opacity(0.95), AppTheme.background],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
            )
        }
    }
    
    // MARK: - Helpers
    private var isValid: Bool {
        let hasTitle = !titre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasDescription = !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImage = !imageBase64.isEmpty || !imageUrl.isEmpty
        let validDates = dateDebut <= dateFin
        
        // Validation conditionnelle selon le type
        var typeValid = true
        if type == "Réduction" {
            typeValid = pourcentageReduction != nil && pourcentageReduction! > 0
        } else if type == "Promo" {
            typeValid = !detailPromotion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } else if type == "Bon plan" {
            typeValid = !recompenses.isEmpty
        }
        
        return hasTitle && hasDescription && hasImage && validDates && typeValid
    }
    
    private func load(_ publicite: Publicite) {
        titre = publicite.titre
        description = publicite.description
        type = publicite.type
        pourcentageReduction = publicite.pourcentageReduction
        imageUrl = publicite.imageUrl ?? ""
        
        // Charger les détails selon le type
        if let detailReduction = publicite.detailReduction {
            pourcentageReduction = detailReduction.pourcentage
            conditionsUtilisation = detailReduction.conditionsUtilisation ?? ""
        }
        
        if let detailPromo = publicite.detailPromotion {
            detailPromotion = detailPromo.offre ?? ""
        }
        
        if let detailJeu = publicite.detailJeu {
            if let reductions = detailJeu.reductions {
                recompenses = reductions.map { reduction in
                    RecompenseJeu(
                        text: reduction.conditions ?? "-\(Int(reduction.pourcentage))%",
                        pourcentage: reduction.pourcentage,
                        probabilite: 10 // Par défaut, à ajuster selon le backend
                    )
                }
            }
        }
        
        if let debut = publicite.dateDebutDate { dateDebut = debut }
        if let fin = publicite.dateFinDate { dateFin = fin }
        hasChanges = false
    }
    
    private func checkChanges() {
        guard let editingPublicite = editingPublicite else {
            hasChanges = !titre.isEmpty || !description.isEmpty || pourcentageReduction != nil || !imageBase64.isEmpty || !imageUrl.isEmpty
            return
        }
        
        let editingDateDebut = editingPublicite.dateDebutDate ?? Date()
        let editingDateFin = editingPublicite.dateFinDate ?? Date()
        
        hasChanges = titre != editingPublicite.titre ||
                     description != editingPublicite.description ||
                     type != editingPublicite.type ||
                     pourcentageReduction != editingPublicite.pourcentageReduction ||
                     imageBase64 != (editingPublicite.imageUrl ?? "") ||
                     dateDebut != editingDateDebut ||
                     dateFin != editingDateFin
    }
    
    private func save() async {
        let formatter = ISO8601DateFormatter()
        
        // Préparer l'image (priorité à base64 depuis l'image sauvegardée, sinon base64 direct, sinon URL)
        var finalImage = ""
        if let fileName = savedImageFileName,
           let base64 = ImageStorageManager.shared.imageToBase64(fileName: fileName) {
            finalImage = base64
        } else if !imageBase64.isEmpty {
            finalImage = imageBase64
        } else if !imageUrl.isEmpty {
            finalImage = imageUrl
        }
        
        // Mapper le type vers le format attendu par le backend (minuscules)
        let backendType: String
        switch type.lowercased() {
        case "réduction", "reduction":
            backendType = "reduction"
        case "promo", "promotion":
            backendType = "promotion"
        case "bon plan", "jeu", "game":
            backendType = "jeu"
        default:
            backendType = "promotion"
        }
        
        // Encoder les détails conditionnels en JSON selon le type
        var detailsJSON: String? = nil
        
        if type == "Réduction" {
            let detailReduction = DetailReduction(
                pourcentage: pourcentageReduction,
                conditionsUtilisation: conditionsUtilisation.isEmpty ? nil : conditionsUtilisation
            )
            if let jsonData = try? JSONEncoder().encode(detailReduction),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                detailsJSON = jsonString
            }
        } else if type == "Promo" {
            let detailPromo = DetailPromotion(
                offre: detailPromotion.isEmpty ? nil : detailPromotion,
                conditions: nil
            )
            if let jsonData = try? JSONEncoder().encode(detailPromo),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                detailsJSON = jsonString
            }
        } else if type == "Bon plan" {
            // Convertir les récompenses en ReductionJeu pour le backend
            let reductions = recompenses.map { recompense in
                ReductionJeu(
                    id: recompense.id.uuidString,
                    pourcentage: recompense.pourcentage,
                    conditions: recompense.text,
                    qrCode: nil
                )
            }
            let detailJeu = DetailJeu(
                description: description,
                gains: recompenses.map { $0.text },
                reductions: reductions,
                nombreCases: nombreCases,
                probabilites: recompenses.map { $0.probabilite }
            )
            if let jsonData = try? JSONEncoder().encode(detailJeu),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                detailsJSON = jsonString
            }
        }
        
        // Créer le DTO selon le format du backend
        let dto = PubliciteDTO(
            titre: titre.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            image: finalImage.isEmpty ? "" : finalImage,
            type: backendType,
            details: detailsJSON,
            categorie: nil
        )
        
        if let editingPublicite = editingPublicite {
            _ = await viewModel.updatePublicite(id: editingPublicite.id, dto: dto)
        } else {
            _ = await viewModel.createPublicite(dto)
        }
    }
    
    // MARK: - Convert Image to Base64
    private func convertImageToBase64(_ image: UIImage) -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            return ""
        }
        let base64String = imageData.base64EncodedString()
        return "data:image/jpeg;base64,\(base64String)"
    }
}
