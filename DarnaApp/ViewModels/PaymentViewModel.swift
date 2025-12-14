//
//  PaymentViewModel.swift
//  DarnaApp
//
//  ViewModel pour gérer l'état du paiement Stripe côté iOS,
//  inspiré de PaymentViewModel sur Android.
//

import Foundation
import Combine

@MainActor
final class PaymentViewModel: ObservableObject {
    enum UiState: Equatable {
        case idle
        case loading
        case success(String)       // clientSecret
        case error(String)
        case paymentCompleted
    }

    @Published var uiState: UiState = .idle
    @Published var clientSecret: String?

    private let service: PaymentServiceProtocol

    init(service: PaymentServiceProtocol = PaymentService.shared) {
        self.service = service
    }

    /// Crée un PaymentIntent côté backend.
    /// - Parameter amount: Montant en euros (le backend multiplie par 100 pour Stripe).
    func createPaymentIntent(amount: Int) async {
        guard amount > 0 else {
            uiState = .error("Le montant doit être supérieur à 0.")
            return
        }

        uiState = .loading
        do {
            let secret = try await service.createPaymentIntent(amount: amount)
            clientSecret = secret
            uiState = .success(secret)
        } catch {
            uiState = .error(error.localizedDescription)
        }
    }

    func resetState() {
        uiState = .idle
        clientSecret = nil
    }

    func onPaymentSuccess() {
        uiState = .paymentCompleted
    }

    func onPaymentError(_ message: String) {
        uiState = .error(message)
    }
}

