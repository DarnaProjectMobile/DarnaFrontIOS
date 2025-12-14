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
    
    // Core fields
    @State private var titre = ""
    @State private var description = ""
    @State private var type = "Réduction"
    @State private var imageUrl = ""
    @State private var dateDebut = Date()
    @State private var dateFin = Date().addingTimeInterval(86400 * 14)
    
    // Conditional fields
    // Reduction
    @State private var pourcentageReduction: Double? = nil
    @State private var conditionsUtilisation = ""
    
    // Promotion
    @State private var detailPromotion = ""
    
    // Jeu
    @State private var nombreCases = 8
    @State private var recompenses: [RecompenseJeu] = []
    @State private var showingAddReward = false
    
    // Image Upload
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    @State private var hasChanges = false
    @State private var showDiscardAlert = false
    @FocusState private var focusedField: Field?
    
    private let types = ["Réduction", "Promotion", "Jeu"]
    
    enum Field {
        case titre, description, pourcentage, imageUrl, conditions, detailPromo
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
            .onAppear { if let pub = editingPublicite { load(pub) } }
            .onChange(of: titre) { _ in checkChanges() }
            .onChange(of: description) { _ in checkChanges() }
            .onChange(of: type) { _ in checkChanges() }
            .onChange(of: pourcentageReduction) { _ in checkChanges() }
            .onChange(of: imageUrl) { _ in checkChanges() }
            .onChange(of: selectedItem) { _ in
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                        // Convert to base64 for preview/storage immediately if needed, or just keep data
                        // For simplicity, we'll use base64 string for imageUrl if it's small enough, 
                        // but typically we upload. Here we follow instructions to use base64 in imageUrl or separate field.
                        // Instructions say: "Remplace le champ URL par un sélecteur d'image... Conversion automatique en base64"
                        imageUrl = "data:image/jpeg;base64," + data.base64EncodedString()
                        checkChanges()
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
            .sheet(isPresented: $showingAddReward) {
                AddRewardSheet(recompenses: $recompenses)
            }
        }
    }
    
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
    
    private var formSections: some View {
        VStack(spacing: 20) {
            // General Info
            formCard(title: "Informations", icon: "info.circle.fill") {
                VStack(spacing: 16) {
                    textField(
                        title: "Titre",
                        text: $titre,
                        placeholder: "Ex: Réduction Spéciale Rentrée",
                        icon: "text.bubble.fill",
                        field: .titre
                    )
                    textEditor(
                        title: "Description",
                        text: $description,
                        placeholder: "Décrivez votre publicité...",
                        icon: "text.alignleft"
                    )
                    typePicker
                }
            }
            
            // Conditional Fields
            if type == "Réduction" {
                formCard(title: "Détails de la réduction", icon: "percent") {
                    VStack(spacing: 16) {
                        HStack(spacing: 10) {
                            Image(systemName: "tag")
                                .foregroundColor(AppTheme.primary.opacity(0.6))
                            TextField(
                                "Pourcentage",
                                value: Binding(
                                    get: { pourcentageReduction ?? 0 },
                                    set: { pourcentageReduction = $0 }
                                ),
                                format: .number
                            )
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .pourcentage)
                            .textFieldStyle(.roundedBorder)
                            Text("%")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        textField(
                            title: "Conditions d'utilisation",
                            text: $conditionsUtilisation,
                            placeholder: "Ex: Valable sur tout le magasin",
                            icon: "doc.text",
                            field: .conditions
                        )
                    }
                }
            } else if type == "Promotion" {
                formCard(title: "Détails de la promotion", icon: "megaphone.fill") {
                    textField(
                        title: "Détail de la promotion",
                        text: $detailPromotion,
                        placeholder: "Ex: 1+1 gratuit",
                        icon: "star.fill",
                        field: .detailPromo
                    )
                }
            } else if type == "Jeu" {
                formCard(title: "Configuration du jeu", icon: "gamecontroller.fill") {
                    VStack(alignment: .leading, spacing: 16) {
                        Stepper("Nombre de cases: \(nombreCases)", value: $nombreCases, in: 4...16)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Récompenses")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Button(action: { showingAddReward = true }) {
                                    Label("Ajouter", systemImage: "plus")
                                        .font(.caption)
                                }
                            }
                            
                            ForEach(recompenses) { reward in
                                HStack {
                                    Text(reward.texte)
                                    Spacer()
                                    Text("-\(Int(reward.reduction))%")
                                        .foregroundColor(.gray)
                                    Text("\(Int(reward.probabilite))%")
                                        .foregroundColor(.blue)
                                    Button(action: {
                                        if let idx = recompenses.firstIndex(where: { $0.id == reward.id }) {
                                            recompenses.remove(at: idx)
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.vertical, 4)
                                Divider()
                            }
                            
                            if recompenses.isEmpty {
                                Text("Aucune récompense configurée")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
            
            // Image Upload
            formCard(title: "Image de la publicité", icon: "photo") {
                VStack(spacing: 12) {
                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .clipped()
                    } else if !imageUrl.isEmpty, let url = URL(string: imageUrl), imageUrl.hasPrefix("http") {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray.opacity(0.1)
                        }
                        .scaledToFill()
                        .frame(height: 200)
                        .cornerRadius(12)
                        .clipped()
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Sélectionner une image")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.primary, lineWidth: 1)
                        )
                    }
                }
            }
            
            // Dates
            formCard(title: "Durée de validité", icon: "calendar") {
                VStack(spacing: 16) {
                    datePicker(title: "Date de début", date: $dateDebut, icon: "calendar.badge.plus")
                    datePicker(title: "Date de fin", date: $dateFin, icon: "calendar.badge.minus")
                    
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
        }
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
            Text("Type").font(.subheadline).fontWeight(.medium)
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
    
    private var isValid: Bool {
        !titre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        dateDebut <= dateFin
    }
    
    private func load(_ publicite: Publicite) {
        titre = publicite.titre
        description = publicite.description
        type = publicite.type
        pourcentageReduction = publicite.pourcentageReduction
        imageUrl = publicite.imageUrl ?? ""
        if let debut = publicite.dateDebutDate { dateDebut = debut }
        if let fin = publicite.dateFinDate { dateFin = fin }
        
        // Load details
        if let detailsStr = publicite.details, let data = detailsStr.data(using: .utf8) {
            let decoder = JSONDecoder()
            if type == "Réduction", let detail = try? decoder.decode(DetailReduction.self, from: data) {
                pourcentageReduction = detail.pourcentage
                conditionsUtilisation = detail.conditionsUtilisation ?? ""
            } else if type == "Promotion", let detail = try? decoder.decode(DetailPromotion.self, from: data) {
                detailPromotion = detail.offre
            } else if type == "Jeu", let detail = try? decoder.decode(DetailJeu.self, from: data) {
                nombreCases = detail.nombreCases
                // Reconstruct rewards from arrays
                recompenses = []
                for i in 0..<(detail.gains.count) {
                    let text = detail.gains[i]
                    let red = i < detail.reductions.count ? detail.reductions[i] : 0
                    let prob = i < detail.probabilites.count ? detail.probabilites[i] : 0
                    recompenses.append(RecompenseJeu(texte: text, reduction: red, probabilite: prob))
                }
            }
        }
        
        hasChanges = false
    }
    
    private func checkChanges() {
        // Simplified change check
        hasChanges = true
    }
    
    private func save() async {
        let formatter = ISO8601DateFormatter()
        let partenaireId = AuthManager.shared.currentUser?.id
        
        // Encode details
        var detailsJson: String? = nil
        let encoder = JSONEncoder()
        
        if type == "Réduction" {
            let detail = DetailReduction(pourcentage: pourcentageReduction ?? 0, conditionsUtilisation: conditionsUtilisation)
            if let data = try? encoder.encode(detail) {
                detailsJson = String(data: data, encoding: .utf8)
            }
        } else if type == "Promotion" {
            let detail = DetailPromotion(offre: detailPromotion, conditions: nil)
            if let data = try? encoder.encode(detail) {
                detailsJson = String(data: data, encoding: .utf8)
            }
        } else if type == "Jeu" {
            let detail = DetailJeu(
                description: nil,
                gains: recompenses.map { $0.texte },
                reductions: recompenses.map { $0.reduction },
                nombreCases: nombreCases,
                probabilites: recompenses.map { $0.probabilite }
            )
            if let data = try? encoder.encode(detail) {
                detailsJson = String(data: data, encoding: .utf8)
            }
        }
        
        let dto = PubliciteDTO(
            titre: titre.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            pourcentageReduction: pourcentageReduction,
            imageUrl: imageUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : imageUrl,
            dateDebut: formatter.string(from: dateDebut),
            dateFin: formatter.string(from: dateFin),
            partenaireId: partenaireId,
            details: detailsJson,
            categorie: nil
        )
        
        if let editingPublicite = editingPublicite {
            _ = await viewModel.updatePublicite(id: editingPublicite.id, dto: dto)
        } else {
            _ = await viewModel.createPublicite(dto)
        }
    }
}

struct AddRewardSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var recompenses: [RecompenseJeu]
    
    @State private var texte = ""
    @State private var reduction: Double = 0
    @State private var probabilite: Double = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Détails") {
                    TextField("Récompense (ex: -10%)", text: $texte)
                    
                    VStack {
                        Text("Réduction: \(Int(reduction))%")
                        Slider(value: $reduction, in: 0...100, step: 5)
                    }
                    
                    VStack {
                        Text("Probabilité: \(Int(probabilite))%")
                        Slider(value: $probabilite, in: 0...100, step: 5)
                    }
                }
            }
            .navigationTitle("Ajouter une récompense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        recompenses.append(RecompenseJeu(texte: texte, reduction: reduction, probabilite: probabilite))
                        dismiss()
                    }
                    .disabled(texte.isEmpty)
                }
            }
        }
    }
}

