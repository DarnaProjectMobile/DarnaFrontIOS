//
//  UserReviewsListView.swift
//  DarnaApp
//

import SwiftUI

struct UserReviewsListView: View {
    // Use your global Review model from Review.swift
    var reviews: [Review] = Review.sampleData
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Title
                    Text("Mes Avis")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 20)
                        .padding(.horizontal)
                    
                    // MARK: - Reviews List
                    if reviews.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("Vous n'avez pas encore laissé d'avis.")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        ForEach(reviews) { review in
                            ReviewCardView(review: review)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Mes Avis")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Review Card Component
struct ReviewCardView: View {
    let review: Review   // 👈 using global Review model
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(review.propertyName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: i < review.rating ? "star.fill" : "star")
                            .foregroundColor(i < review.rating ? .yellow : .gray.opacity(0.3))
                            .font(.system(size: 14))
                    }
                }
            }
            
            // Comment
            Text(review.comment)
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            // Date
            Text(review.date, format: Date.FormatStyle().day().month().year())
                .font(.caption)
                .foregroundColor(.gray.opacity(0.6))
                .padding(.top, 2)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
struct UserReviewsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserReviewsListView()
        }
    }
}
