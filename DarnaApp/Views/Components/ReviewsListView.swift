//
//  ReviewsListView.swift
//  DarnaApp
//
//  Modern, Creative & Elegant Design
//

import SwiftUI

struct ReviewsListView: View {
    let reviews: [EnrichedReview]
    let isLoading: Bool
    let isReceivedReview: Bool // true = colocataire (avis reçus), false = client (avis donnés)
    
    // Groupement par logement
    private var groupedReviews: [(key: String, value: [EnrichedReview])] {
        var groups: [String: [EnrichedReview]] = [:]
        
        for review in reviews {
            let logementTitle = review.visit.logementTitle ?? "Logement inconnu"
            groups[logementTitle, default: []].append(review)
        }
        
        return groups.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading && reviews.isEmpty {
                LoadingView()
                    .padding(.top, 60)
            } else if reviews.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(groupedReviews, id: \.key) { (logementTitle, reviews) in
                            VStack(alignment: .leading, spacing: 12) {
                                // Section Header: Logement
                                HStack {
                                    Image(systemName: "building.2.fill")
                                        .foregroundColor(.blue)
                                    Text(logementTitle)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(reviews.count) avis")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal, 20)
                                
                                // Reviews for this logement
                                ForEach(reviews) { enriched in
                                    ReviewCard(enriched: enriched, isReceivedReview: isReceivedReview)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "star.slash.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("Aucun avis")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Les avis apparaîtront ici.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let enriched: EnrichedReview
    let isReceivedReview: Bool // true = afficher le client, false = afficher le logement
    
    var review: VisitReview { enriched.review }
    var visit: Visit { enriched.visit }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            commentSection
            detailsSection
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var headerSection: some View {
        HStack(spacing: 12) {
            avatarView
            userInfoView
            Spacer()
            ratingBadge
        }
    }
    
    private var avatarView: some View {
        Circle()
            .fill(isReceivedReview ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
            .frame(width: 44, height: 44)
            .overlay(
                Image(systemName: isReceivedReview ? "person.fill" : "building.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isReceivedReview ? .orange : .blue)
            )
    }
    
    private var userInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isReceivedReview {
                // Avis reçus (colocataire) : afficher le client ET le logement
                Text(visit.clientUsername ?? "Client")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(visit.logementTitle ?? "Logement")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            } else {
                // Avis donnés (client) : afficher UNIQUEMENT le logement
                Text(visit.logementTitle ?? "Logement")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            if let date = review.createdAt {
                Text(formatDate(date))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var ratingBadge: some View {
        HStack(spacing: 4) {
            Text(String(format: "%.1f", review.rating ?? 0))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.orange)
            
            Image(systemName: "star.fill")
                .font(.system(size: 14))
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var commentSection: some View {
        if let comment = review.comment, !comment.isEmpty {
            Text(comment)
                .font(.system(size: 15))
                .foregroundColor(Color(uiColor: .label))
                .lineSpacing(4)
                .padding(.vertical, 4)
        }
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        if hasDetails {
            Divider()
                .padding(.vertical, 4)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                if let clean = review.cleanlinessRating {
                    detailRow(icon: "sparkles", label: "Propreté", value: clean)
                }
                if let collector = review.collectorRating {
                    detailRow(icon: "person.fill", label: "Accueil", value: collector)
                }
                if let loc = review.locationRating {
                    detailRow(icon: "location.fill", label: "Emplacement", value: loc)
                }
                if let conf = review.conformityRating {
                    detailRow(icon: "checkmark.seal.fill", label: "Conformité", value: conf)
                }
            }
        }
    }
    
    private var hasDetails: Bool {
        review.cleanlinessRating != nil || review.collectorRating != nil || review.locationRating != nil || review.conformityRating != nil
    }
    
    private func detailRow(icon: String, label: String, value: Float) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack(spacing: 2) {
                Text(String(format: "%.0f", value))
                    .font(.system(size: 13, weight: .semibold))
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.string(from: date)
        }
        return dateString
    }
}

