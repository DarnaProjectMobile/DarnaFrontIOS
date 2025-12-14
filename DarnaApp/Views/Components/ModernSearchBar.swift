//
//  ModernSearchBar.swift
//  DarnaApp
//
//  Barre de recherche moderne avec icône loupe et filtre
//

import SwiftUI

struct ModernSearchBar: View {
    @Binding var searchText: String
    var placeholder: String = "Rechercher une marque..."
    var onFilterTap: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 12) {
            // Icône loupe
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            // Champ de recherche
            TextField(placeholder, text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .autocorrectionDisabled()
                .font(.system(size: 15))
            
            // Bouton filtre
            Button(action: onFilterTap) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    ModernSearchBar(searchText: .constant(""))
}
