//
//  StripeConfig.swift
//  DarnaApp
//
//  Configuration Stripe pour l'application iOS.
//  Remplacez la clé de test par votre clé publique Stripe.
//

import Foundation
#if canImport(StripePaymentSheet)
import StripePaymentSheet
#endif

struct StripeConfig {

    static let publishableKey: String = "pk_test_51SWhKDHzDVVYaCTRXPPjTHX3wP0Qsz5aFDkOfK2ji9vd26xwucYJsFFKx271d767HVHN3f6hVC07wb6a0cnEcR5Y00UqB3vKCH"

    /// Configure le client Stripe globalement.
    static func configureIfNeeded() {
        #if canImport(StripePaymentSheet)
        if STPAPIClient.shared.publishableKey != publishableKey {
            STPAPIClient.shared.publishableKey = publishableKey
        }
        #else
        print("⚠️ StripePaymentSheet module is missing. Please add the package to enable payments.")
        #endif
    }
}

