//
//  PaymentService.swift
//  DarnaApp
//
//  Service réseau pour créer un PaymentIntent Stripe via le backend
//  (équivalent de PaymentApi/PaymentRepository côté Android).
//

import Foundation

/// Représente la réponse du backend `/payments/create-intent`
struct PaymentIntentResponse: Decodable {
    let clientSecret: String
}

/// Requête envoyée au backend pour créer un PaymentIntent
struct CreatePaymentIntentRequest: Encodable {
    /// Montant en euros (le backend se charge de multiplier par 100 pour Stripe)
    let amount: Int
}

protocol PaymentServiceProtocol {
    /// Crée un PaymentIntent côté backend et renvoie le `clientSecret` Stripe.
    func createPaymentIntent(amount: Int) async throws -> String
}

final class PaymentService: PaymentServiceProtocol {
    static let shared = PaymentService()

    private let session: URLSession
    private let baseURL: String = "http://172.18.8.236:3000"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func createPaymentIntent(amount: Int) async throws -> String {
        let endpoint = "/payments/create-intent"
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        let body = CreatePaymentIntentRequest(amount: amount)
        let bodyData = try JSONEncoder().encode(body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Si vous utilisez un JWT, ajoutez ici l'entête Authorization
        if let token = await AuthenticationManager.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw APIError.httpError(statusCode: 401)
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(PaymentIntentResponse.self, from: data)
            return decoded.clientSecret
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
