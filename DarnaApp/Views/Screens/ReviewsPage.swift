//
//  ReviewsPage.swift
//  DarnaApp
//

import SwiftUI
import Foundation

struct ReviewsPage: View {
    let property: Property

    @State private var selectedFilter: Int? = nil // nil = All
    @State private var reviews: [Review] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showAddReview = false

    // Filtered reviews by star rating
    var filteredReviews: [Review] {
        if let filter = selectedFilter {
            return reviews.filter { $0.rating == filter }
        }
        return reviews
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                }
                
                // Header
                HStack {
                    Text("Avis sur \(property.title)")
                        .font(.system(size: 22, weight: .bold))
                    Spacer()
                    Button(action: { showAddReview = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Filters like Google Play
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterButton(label: "Tous", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        ForEach((1...5).reversed(), id: \.\self) { star in
                            FilterButton(label: "\(star)★", isSelected: selectedFilter == star) {
                                selectedFilter = star
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Loading indicator
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Spacer()
                    }
                }
                                
                // Reviews List
                VStack(spacing: 16) {
                    ForEach(filteredReviews) { review in
                        ReviewRowView(review: review, propertyOwnerId: property.user ?? "", onEdit: { updatedReview in
                            // Update the review in our local array
                            if let index = reviews.firstIndex(where: { $0.id == updatedReview.id }) {
                                reviews[index] = updatedReview
                            }
                        }, onDelete: { reviewId in
                            // Remove the review from our local array
                            reviews.removeAll { $0.id == reviewId }
                        })
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Tous les avis")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddReview) {
            AddReviewView(property: property) { newReview in
                // Add the new review to our local array
                reviews.insert(newReview, at: 0)
                showAddReview = false
            }
        }
        .onAppear {
            loadReviews()
        }
    }
}

// MARK: - Reviews Page Extension
extension ReviewsPage {
    private func loadReviews() {
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                let fetchedReviews = try await ReviewService.shared.fetchReviews(for: property.id)
                await MainActor.run {
                    reviews = fetchedReviews
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
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

// MARK: - Review Row View
struct ReviewRowView: View {
    let review: Review
    let propertyOwnerId: String
    let onEdit: (Review) -> Void
    let onDelete: (String) -> Void
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    var isOwnedByCurrentUser: Bool {
        review.userId == AuthenticationManager.shared.currentUser?.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.\self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .foregroundColor(star <= review.rating ? .yellow : .gray.opacity(0.3))
                            .font(.system(size: 14))
                    }
                }
                Text(review.userName.isEmpty ? "Utilisateur" : review.userName)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                
                // Show edit/delete options only for the review owner
                if isOwnedByCurrentUser {
                    Menu {
                        Button("Modifier") {
                            showEditSheet = true
                        }
                        Button("Supprimer", role: .destructive) {
                            showDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                Text(formatDate(review.date))
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
        .sheet(isPresented: $showEditSheet) {
            EditReviewView(review: review) { updatedReview in
                onEdit(updatedReview)
                showEditSheet = false
            }
        }
        .alert("Supprimer l'avis", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                deleteReview()
            }
        } message: {
            Text("Êtes-vous sûr de vouloir supprimer cet avis ?")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func deleteReview() {
        Task {
            do {
                try await ReviewService.shared.deleteReview(reviewId: review.id)
                await MainActor.run {
                    onDelete(review.id)
                }
            } catch {
                print("Error deleting review: \(error.localizedDescription)")
                // In a real app, you might want to show an error alert here
            }
        }
    }
}

// MARK: - Add Review View
struct AddReviewView: View {
    let property: Property
    let onAdd: (Review) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var rating = 0
    @State private var comment = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note")) {
                    HStack {
                        ForEach(1...5, id: \.\self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: 30))
                                .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.4))
                                .onTapGesture { rating = star }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Section(header: Text("Commentaire")) {
                    TextEditor(text: $comment)
                        .frame(height: 100)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Ajouter un avis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Publier") {
                        publishReview()
                    }
                    .disabled(rating == 0 || comment.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
    }
    
    private func publishReview() {
        guard rating > 0, !comment.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                let newReview = try await ReviewService.shared.createReview(
                    propertyId: property.id,
                    rating: rating,
                    comment: comment
                )
                await MainActor.run {
                    onAdd(newReview)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Edit Review View
struct EditReviewView: View {
    let review: Review
    let onUpdate: (Review) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var rating: Int
    @State private var comment: String
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    init(review: Review, onUpdate: @escaping (Review) -> Void) {
        self.review = review
        self.onUpdate = onUpdate
        _rating = State(initialValue: review.rating)
        _comment = State(initialValue: review.comment)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note")) {
                    HStack {
                        ForEach(1...5, id: \.\self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: 30))
                                .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.4))
                                .onTapGesture { rating = star }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Section(header: Text("Commentaire")) {
                    TextEditor(text: $comment)
                        .frame(height: 100)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Modifier l'avis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        updateReview()
                    }
                    .disabled(rating == 0 || comment.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
    }
    
    private func updateReview() {
        guard rating > 0, !comment.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                var updatedReview = review
                updatedReview.rating = rating
                updatedReview.comment = comment
                
                let result = try await ReviewService.shared.updateReview(
                    reviewId: review.id,
                    rating: rating,
                    comment: comment
                )
                await MainActor.run {
                    onUpdate(result)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
