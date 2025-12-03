//
//  CollocatorReviewsView.swift
//  DarnaApp
//

import SwiftUI

struct CollocatorReviewsView: View {
    @StateObject private var viewModel = VisitViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Section Commentaires
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Commentaires")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if viewModel.isLoading && viewModel.enrichedReceivedReviews.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if viewModel.enrichedReceivedReviews.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "star.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Aucun avis pour le moment")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        } else {
                            ForEach(viewModel.enrichedReceivedReviews) { enriched in
                                ReviewCard(enriched: enriched, isReceivedReview: true)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Avis des locataires")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadInitialData()
            }
            .refreshable {
                await viewModel.loadInitialData()
            }
        }
    }
}
