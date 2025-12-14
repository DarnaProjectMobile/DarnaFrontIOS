//
//  PubliciteFormView.swift
//  DarnaApp
//
//  Formulaire d'ajout/édition de publicité
//

import SwiftUI

struct PubliciteFormView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PubliciteViewModel
    
    // Mode : création ou édition
    let publicite: Publicite?
    let isEditing: Bool
    
    // Champs du formulaire
    @State private var titre: String = ""
    @State private var description: String = ""
    @State private var imageUrl: String = ""
    @State private var selectedType: String = "promotion"
    @State private var selectedCategorie: String = "Nourriture"
    @State private var details: String = ""
    
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let types = ["reduction", "promotion", "jeu"]
    let categories = ["Nourriture", "Tech", "Loisirs", "Vêtement", "Santé", "Transport"]
    
    init(viewModel: PubliciteViewModel = PubliciteViewModel(), publicite: Publicite? = nil) {
        self.viewModel = viewModel
        self.publicite = publicite
        self.isEditing = publicite != nil
        
        // Pré-remplir si édition
        if let pub = publicite {
            _titre = State(initialValue: pub.titre)
            _description = State(initialValue: pub.description)
            _imageUrl = State(initialValue: pub.imageUrl ?? "")
            _selectedType = State(initialValue: pub.type)
            _selectedCategorie = State(initialValue: pub.categorie ?? "Nourriture")
            _details = State(initialValue: pub.details ?? "")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Section informations de base
                Section("Informations de base") {
                    TextField("Titre de l'offre", text: $titre)
                        .autocorrectionDisabled()
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .overlay(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Description de l'offre...")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }
                
                // Section image
                Section("Image") {
                    TextField("URL de l'image", text: $imageUrl)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    
                    if !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(12)
                            case .failure:
                                imageErrorView
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                
                // Section type et catégorie
                Section("Type et catégorie") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(types, id: \.self) { type in
                            Text(type.capitalized).tag(type)
                        }
                    }
                    
                    Picker("Catégorie", selection: $selectedCategorie) {
                        ForEach(categories, id: \.self) { categorie in
                            Text(categorie).tag(categorie)
                        }
                    }
                }
                
                // Section détails optionnels
                Section("Détails (optionnel)") {
                    TextEditor(text: $details)
                        .frame(minHeight: 80)
                        .overlay(alignment: .topLeading) {
                            if details.isEmpty {
                                Text("Détails supplémentaires...")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }
            .navigationTitle(isEditing ? "Modifier" : "Nouvelle publicité")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Enregistrer" : "Créer") {
                        submitForm()
                    }
                    .disabled(!isFormValid || isSubmitting)
                }
            }
            .disabled(isSubmitting)
            .overlay {
                if isSubmitting {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                    }
                }
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Views
    
    private var imageErrorView: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Impossible de charger l'image")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Validation
    
    private var isFormValid: Bool {
        !titre.isEmpty &&
        !description.isEmpty &&
        !imageUrl.isEmpty &&
        !selectedType.isEmpty &&
        !selectedCategorie.isEmpty
    }
    
    // MARK: - Submit
    
    private func submitForm() {
        isSubmitting = true
        
        let dto = PubliciteDTO(
            titre: titre,
            description: description,
            image: imageUrl,
            type: selectedType,
            details: details.isEmpty ? nil : details,
            categorie: selectedCategorie
        )
        
        Task {
            let success: Bool
            
            if isEditing, let publicite = publicite {
                // Mise à jour
                success = await viewModel.updatePublicite(id: publicite.id, dto: dto)
            } else {
                // Création
                success = await viewModel.createPublicite(dto)
            }
            
            isSubmitting = false
            
            if success {
                dismiss()
            } else {
                errorMessage = viewModel.errorMessage ?? "Une erreur est survenue"
                showError = true
            }
        }
    }
}

#Preview("Création") {
    PubliciteFormView()
}

#Preview("Édition") {
    PubliciteFormView(publicite: Publicite(
        id: "1",
        titre: "2 Pizzas = 1 Offerte",
        description: "Profitez de notre offre",
        type: "promotion",
        imageUrl: "https://example.com/pizza.jpg",
        categorie: "Nourriture"
    ))
}
