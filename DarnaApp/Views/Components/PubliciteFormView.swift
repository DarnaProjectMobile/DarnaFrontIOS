//
//  PubliciteFormView.swift
//  DarnaApp
//

import SwiftUI

struct PubliciteFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PubliciteViewModel
    var editingPublicite: Publicite?
    
    @State private var titre = ""
    @State private var description = ""
    @State private var type = "Réduction"
    @State private var pourcentageReduction: Double? = nil
    @State private var imageUrl = ""
    @State private var dateDebut = Date()
    @State private var dateFin = Date().addingTimeInterval(86400 * 14)
    @State private var hasChanges = false
    @State private var showDiscardAlert = false
    @FocusState private var focusedField: Field?
    
    private let types = ["Réduction", "Promo", "Bon plan"]
    
    enum Field {
        case titre, description, pourcentage, imageUrl
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
            .onChange(of: dateDebut) { _ in checkChanges() }
            .onChange(of: dateFin) { _ in checkChanges() }
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
                        title: "Titre",
                        text: $titre,
                        placeholder: "Ex: Réduction Étudiants",
                        icon: "text.bubble.fill",
                        field: .titre
                    )
                    textEditor(
                        title: "Description",
                        text: $description,
                        placeholder: "Décrivez votre offre…",
                        icon: "text.alignleft"
                    )
                    typePicker
                }
            }
            
            formCard(title: "Réduction", icon: "percent") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Afficher un pourcentage", isOn: Binding(
                        get: { pourcentageReduction != nil },
                        set: { newValue in
                            pourcentageReduction = newValue ? (pourcentageReduction ?? 0) : nil
                        })
                    )
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))
                    
                    if pourcentageReduction != nil {
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
                    }
                }
            }
            
            formCard(title: "Média", icon: "photo") {
                textField(
                    title: "URL de l’image",
                    text: $imageUrl,
                    placeholder: "https://example.com/image.jpg",
                    icon: "link",
                    field: .imageUrl
                )
            }
            
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
            
            previewSection
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
    
    private var previewSection: some View {
        formCard(title: "Aperçu", icon: "eye.fill") {
            if isValid {
                PubliciteCardView(
                    publicite: previewPublicite,
                    isSponsor: true, // pour voir les actions
                    onEdit: nil,
                    onDelete: nil
                )
            } else {
                VStack {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 30))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                    Text("Complétez les champs obligatoires pour voir l’aperçu.")
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
            description: description.isEmpty ? "Description de l’offre…" : description,
            type: type,
            pourcentageReduction: pourcentageReduction,
            imageUrl: imageUrl.isEmpty ? nil : imageUrl,
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
        hasChanges = false
    }
    
    private func checkChanges() {
        guard let editingPublicite = editingPublicite else {
            hasChanges = !titre.isEmpty || !description.isEmpty || pourcentageReduction != nil || !imageUrl.isEmpty
            return
        }
        
        hasChanges = titre != editingPublicite.titre ||
                     description != editingPublicite.description ||
                     type != editingPublicite.type ||
                     pourcentageReduction != editingPublicite.pourcentageReduction ||
                     imageUrl != (editingPublicite.imageUrl ?? "") ||
                     dateDebut != editingPublicite.dateDebutDate ||
                     dateFin != editingPublicite.dateFinDate
    }
    
    private func save() async {
        let formatter = ISO8601DateFormatter()
        let partenaireId = AuthenticationManager.shared.currentUser?.id
        
        let dto = PubliciteDTO(
            titre: titre.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            pourcentageReduction: pourcentageReduction,
            imageUrl: imageUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : imageUrl,
            dateDebut: formatter.string(from: dateDebut),
            dateFin: formatter.string(from: dateFin),
            partenaireId: partenaireId
        )
        
        if let editingPublicite = editingPublicite {
            _ = await viewModel.updatePublicite(id: editingPublicite.id, dto: dto)
        } else {
            _ = await viewModel.createPublicite(dto)
        }
    }
}
