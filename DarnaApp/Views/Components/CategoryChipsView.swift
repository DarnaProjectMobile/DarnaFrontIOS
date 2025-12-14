//
//  CategoryChipsView.swift
//  DarnaApp
//
//  Liste horizontale de catégories sous forme de chips
//

import SwiftUI

struct CategoryChipsView: View {
    @Binding var selectedCategory: String?
    let categories: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: selectedCategory == category || (category == "Tout" && selectedCategory == nil),
                        action: {
                            if category == "Tout" {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

#Preview {
    CategoryChipsView(
        selectedCategory: .constant("Nourriture"),
        categories: ["Tout", "Nourriture", "Tech", "Loisirs", "Vêtement", "Santé"]
    )
}
