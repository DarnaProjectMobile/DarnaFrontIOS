//
//  ReviewsPage.swift
//  DarnaApp
//

import SwiftUI

struct ReviewsPage: View {
    let property: Property

    @State private var selectedFilter: Int? = nil // nil = All
    @State private var reviews: [PropertyReview] = [
        PropertyReview(name: "Amine B.", stars: 5, comment: "Appartement très calme et bien situé."),
        PropertyReview(name: "Sara K.", stars: 4, comment: "Bon rapport qualité-prix."),
        PropertyReview(name: "Omar L.", stars: 3, comment: "Pas mal, mais un peu bruyant le soir."),
        PropertyReview(name: "Noura M.", stars: 5, comment: "Propriétaire super sympa !"),
        PropertyReview(name: "Rami D.", stars: 2, comment: "Trop petit pour le prix."),
    ]

    // Filtered reviews by star rating
    var filteredReviews: [PropertyReview] {
        if let filter = selectedFilter {
            return reviews.filter { $0.stars == filter }
        }
        return reviews
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text("Avis sur \(property.title)")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                // Filters like Google Play
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterButton(label: "Tous", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        ForEach((1...5).reversed(), id: \.self) { star in
                            FilterButton(label: "\(star)★", isSelected: selectedFilter == star) {
                                selectedFilter = star
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Reviews List
                VStack(spacing: 16) {
                    ForEach(filteredReviews) { review in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { s in
                                        Image(systemName: s <= review.stars ? "star.fill" : "star")
                                            .foregroundColor(s <= review.stars ? .yellow : .gray.opacity(0.3))
                                            .font(.system(size: 14))
                                    }
                                }
                                Text(review.name)
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text("Il y a \(Int.random(in: 1...10)) jours")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Text(review.comment)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Tous les avis")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Local Review Model (Renamed)
struct PropertyReview: Identifiable {
    let id = UUID()
    let name: String
    let stars: Int
    let comment: String
}

// MARK: - Filter Button Component
struct FilterButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primaryLight : Color.gray.opacity(0.1))
                .cornerRadius(16)
                .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textPrimary)
        }
    }
}
