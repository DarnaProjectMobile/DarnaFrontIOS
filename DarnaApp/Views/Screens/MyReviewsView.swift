//
//  MyReviewsView.swift
//  DarnaApp
//
//  Vue pour afficher les avis donnés par l'utilisateur
//

import SwiftUI

struct MyReviewsView: View {
    @StateObject private var viewModel = VisitViewModel()
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Animated Background
            AnimatedBackgroundGradient()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Header
                    heroHeader
                        .padding(.top, 20)
                    
                    // Content
                    if isLoading && viewModel.enrichedGivenReviews.isEmpty {
                        LoadingView()
                            .padding(.top, 60)
                    } else if viewModel.enrichedGivenReviews.isEmpty {
                        emptyState
                            .padding(.top, 60)
                    } else {
                        // Statistics Card
                        reviewStatisticsCard
                            .padding(.horizontal)
                        
                        // Reviews List
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.enrichedGivenReviews) { enriched in
                                MyReviewCard(enriched: enriched)
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)
                                    ))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadReviews()
        }
        .refreshable {
            await loadReviews()
        }
    }
    
    // MARK: - Hero Header
    private var heroHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: Color.orange.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: "star.bubble.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text("Mes avis")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.2),
                            Color(red: 0.2, green: 0.2, blue: 0.3)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Consultez tous les avis que vous avez donnés")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Statistics Card
    private var reviewStatisticsCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Résumé de vos avis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(viewModel.enrichedGivenReviews.count) avis donné\(viewModel.enrichedGivenReviews.count > 1 ? "s" : "")")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Average Rating
            if let avgRating = calculateAverageRating() {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Note moyenne")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.orange)
                            
                            Text(String(format: "%.1f", avgRating))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("/ 5")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Star Rating Display
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= Int(avgRating.rounded()) ? "star.fill" : "star")
                                .font(.system(size: 14))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.05))
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .orange.opacity(0.1), radius: 15, x: 0, y: 8)
        )
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "star.slash")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.gray, .gray.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("Aucun avis donné")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Vous n'avez pas encore laissé d'avis.\nVisitez des logements et partagez votre expérience !")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Helper Functions
    private func loadReviews() async {
        isLoading = true
        await viewModel.refreshMyVisits()
        isLoading = false
    }
    
    private func calculateAverageRating() -> Float? {
        let reviews = viewModel.enrichedGivenReviews.map { $0.review }
        guard !reviews.isEmpty else { return nil }
        
        var totalRating: Float = 0
        var count = 0
        
        for review in reviews {
            if let collectorRating = review.collectorRating {
                totalRating += collectorRating
                count += 1
            }
            if let cleanlinessRating = review.cleanlinessRating {
                totalRating += cleanlinessRating
                count += 1
            }
            if let locationRating = review.locationRating {
                totalRating += locationRating
                count += 1
            }
            if let conformityRating = review.conformityRating {
                totalRating += conformityRating
                count += 1
            }
        }
        
        return count > 0 ? totalRating / Float(count) : nil
    }
}

// MARK: - My Review Card
struct MyReviewCard: View {
    let enriched: EnrichedReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with Property Info
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.8), Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: Color.orange.opacity(0.4), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "house.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(enriched.visit.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text(enriched.visit.formattedDate)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.08),
                        Color.orange.opacity(0.03)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // Ratings Grid
            VStack(spacing: 12) {
                if let collectorRating = enriched.review.collectorRating {
                    RatingRow(title: "Colocataire", rating: collectorRating, icon: "person.fill")
                }
                
                if let cleanlinessRating = enriched.review.cleanlinessRating {
                    RatingRow(title: "Propreté", rating: cleanlinessRating, icon: "sparkles")
                }
                
                if let locationRating = enriched.review.locationRating {
                    RatingRow(title: "Emplacement", rating: locationRating, icon: "location.fill")
                }
                
                if let conformityRating = enriched.review.conformityRating {
                    RatingRow(title: "Conformité", rating: conformityRating, icon: "checkmark.seal.fill")
                }
            }
            .padding(.horizontal, 16)
            
            // Comment
            if let comment = enriched.review.comment, !comment.isEmpty {
                Divider()
                    .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "text.bubble.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        
                        Text("Votre commentaire")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(comment)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            } else {
                Spacer()
                    .frame(height: 8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.3),
                                    Color.orange.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: Color.orange.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Rating Row
struct RatingRow: View {
    let title: String
    let rating: Float
    let icon: String
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: Float(index) <= rating ? "star.fill" : "star")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                }
                
                Text(String(format: "%.1f", rating))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.orange)
                    .padding(.leading, 4)
            }
        }
    }
}

struct MyReviewsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyReviewsView()
        }
    }
}
