//
//  AdFormView.swift
//  DarnaApp
//

import SwiftUI

struct AdFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: AdsStore
    
    var editingAd: Ad?
    
    @State private var title = ""
    @State private var brand = ""
    @State private var type: AdType = .reduction
    @State private var discountText = ""
    @State private var description = ""
    @State private var promoCode = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 14)
    @State private var hasChanges = false
    @State private var showDiscardAlert = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, brand, discount, description, promoCode
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header avec icône
                        headerSection
                        
                        // Indicateur de modification
                        if editingAd != nil && hasChanges {
                            HStack {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.orange)
                                Text("Modifications non enregistrées")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                        
                        // Formulaire
                        VStack(spacing: 20) {
                            // Section Informations
                            formCard(title: "Informations", icon: "info.circle.fill") {
                                VStack(spacing: 16) {
                                    customTextField(
                                        title: "Titre du Publicité",
                                        text: $title,
                                        icon: "text.bubble.fill",
                                        placeholder: "Ex: Réduction Étudiants",
                                        field: .title
                                    )
                                    
                                    customTextField(
                                        title: "Marque / Partenaire",
                                        text: $brand,
                                        icon: "building.2.fill",
                                        placeholder: "Ex: BlueCoffee",
                                        field: .brand
                                    )
                                    
                                    typePicker
                                }
                            }
                            
                            // Section Avantage
                            formCard(title: "Avantage", icon: "tag.fill") {
                                VStack(spacing: 16) {
                                    customTextField(
                                        title: "Réduction / Promo",
                                        text: $discountText,
                                        icon: "percent",
                                        placeholder: "Ex: -20% ou 2 pour 1",
                                        field: .discount
                                    )
                                    
                                    customTextEditor(
                                        title: "Description",
                                        text: $description,
                                        icon: "text.alignleft",
                                        placeholder: "Décrivez votre offre..."
                                    )
                                    
                                    customTextField(
                                        title: "Code promo (optionnel)",
                                        text: $promoCode,
                                        icon: "barcode",
                                        placeholder: "Ex: STUDENT20",
                                        field: .promoCode
                                    )
                                }
                            }
                            
                            // Section Durée
                            formCard(title: "Durée de validité", icon: "calendar") {
                                VStack(spacing: 16) {
                                    customDatePicker(
                                        title: "Date de début",
                                        date: $startDate,
                                        icon: "calendar.badge.plus"
                                    )
                                    
                                    customDatePicker(
                                        title: "Date de fin",
                                        date: $endDate,
                                        icon: "calendar.badge.minus"
                                    )
                                    
                                    if startDate > endDate {
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.orange)
                                            Text("La date de fin doit être après la date de début")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // Aperçu en temps réel
                            previewSection
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
                
                // Bouton de sauvegarde fixe en bas
                VStack {
                    Spacer()
                    saveButton
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
            .navigationTitle(editingAd == nil ? "Nouvelle Publicité" : "Modifier la Publicité")
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
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                            Text("Annuler")
                        }
                        .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .onAppear {
                if let ad = editingAd {
                    load(ad)
                }
            }
            .onChange(of: title) { _ in checkChanges() }
            .onChange(of: brand) { _ in checkChanges() }
            .onChange(of: type) { _ in checkChanges() }
            .onChange(of: discountText) { _ in checkChanges() }
            .onChange(of: description) { _ in checkChanges() }
            .onChange(of: promoCode) { _ in checkChanges() }
            .onChange(of: startDate) { _ in checkChanges() }
            .onChange(of: endDate) { _ in checkChanges() }
            .alert("Modifications non enregistrées", isPresented: $showDiscardAlert) {
                Button("Continuer l'édition", role: .cancel) { }
                Button("Abandonner", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Vous avez des modifications non enregistrées. Voulez-vous vraiment quitter sans sauvegarder ?")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight)
                    .frame(width: 80, height: 80)
                
                Image(systemName: editingAd == nil ? "plus.circle.fill" : "pencil.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.primary)
            }
            
            Text(editingAd == nil ? "Créez une nouvelle Publicité" : "Modifiez votre Publicité")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            if let editingAd = editingAd {
                Text("ID: \(editingAd.id.uuidString.prefix(8).uppercased())")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Form Card
    private func formCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary)
                    .font(.system(size: 16))
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
                    .foregroundColor(AppTheme.primary.opacity(0.6))
                    .frame(width: 20)
                
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
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textPrimary)
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary.opacity(0.6))
                    .frame(width: 20)
                    .padding(.top, 4)
                
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
    
    // MARK: - Type Picker
    private var typePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type de Publicité")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textPrimary)
            
            HStack(spacing: 12) {
                ForEach(AdType.allCases) { adType in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            type = adType
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: iconForType(adType))
                            Text(adType.rawValue)
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(type == adType ? AppTheme.onPrimary : AppTheme.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(type == adType ? AppTheme.primary : AppTheme.primaryLight.opacity(0.3))
                        )
                    }
                }
            }
        }
    }
    
    private func iconForType(_ type: AdType) -> String {
        switch type {
        case .reduction:
            return "percent"
        case .promo:
            return "tag.fill"
        case .bonPlan:
            return "star.fill"
        }
    }
    
    // MARK: - Custom Date Picker
    private func customDatePicker(
        title: String,
        date: Binding<Date>,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textPrimary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primary.opacity(0.6))
                    .frame(width: 20)
                
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
    
    // MARK: - Preview Section
    private var previewSection: some View {
        formCard(title: "Aperçu", icon: "eye.fill") {
            if isValid {
                AdCardView(ad: previewAd)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 30))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                    Text("Remplissez les champs obligatoires pour voir l'aperçu")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
            }
        }
    }
    
    private var previewAd: Ad {
        Ad(
            id: editingAd?.id ?? UUID(),
            title: title.isEmpty ? "Titre de Publicité " : title,
            brand: brand.isEmpty ? "Marque" : brand,
            type: type,
            discountText: discountText.isEmpty ? "-XX%" : discountText,
            description: description.isEmpty ? "Description de l'offre..." : description,
            promoCode: promoCode.isEmpty ? nil : promoCode,
            startDate: startDate,
            endDate: endDate,
            imageURL: nil
        )
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            save()
        } label: {
            HStack {
                Image(systemName: editingAd == nil ? "paperplane.fill" : "checkmark.circle.fill")
                Text(editingAd == nil ? "Publier la Publicité " : "Enregistrer les modifications")
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
        .disabled(!isValid)
        .animation(.easeInOut, value: isValid)
    }
    
    // MARK: - Validation & Actions
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !brand.trimmingCharacters(in: .whitespaces).isEmpty &&
        !discountText.trimmingCharacters(in: .whitespaces).isEmpty &&
        startDate <= endDate
    }
    
    private func load(_ ad: Ad) {
        title = ad.title
        brand = ad.brand
        type = ad.type
        discountText = ad.discountText
        description = ad.description
        promoCode = ad.promoCode ?? ""
        startDate = ad.startDate
        endDate = ad.endDate
        hasChanges = false
    }
    
    private func checkChanges() {
        guard let editingAd = editingAd else {
            hasChanges = false
            return
        }
        
        hasChanges = title != editingAd.title ||
                     brand != editingAd.brand ||
                     type != editingAd.type ||
                     discountText != editingAd.discountText ||
                     description != editingAd.description ||
                     promoCode != (editingAd.promoCode ?? "") ||
                     startDate != editingAd.startDate ||
                     endDate != editingAd.endDate
    }
    
    private func save() {
        let newAd = Ad(
            id: editingAd?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespaces),
            brand: brand.trimmingCharacters(in: .whitespaces),
            type: type,
            discountText: discountText.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            promoCode: promoCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : promoCode,
            startDate: startDate,
            endDate: endDate,
            imageURL: nil
        )
        
        if editingAd == nil {
            store.add(newAd)
        } else {
            store.update(newAd)
        }
        
        dismiss()
    }
}
