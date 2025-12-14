# Intégration Stripe

Le code pour le paiement Stripe a été intégré mais nécessite l'ajout de la dépendance `StripePaymentSheet` pour fonctionner.

## Étapes pour activer le paiement :

1. Ouvrez le projet dans Xcode (`DarnaApp.xcodeproj`).
2. Allez dans **File > Add Packages Dependencies...**.
3. Dans la barre de recherche, entrez l'URL : `https://github.com/stripe/stripe-ios`.
4. Sélectionnez le package **stripe-ios**.
5. Cliquez sur **Add Package**.
6. Dans la fenêtre de sélection des produits, cochez **StripePaymentSheet**.
7. Cliquez sur **Add Package**.

Une fois la dépendance ajoutée, le code de paiement s'activera automatiquement grâce aux directives de compilation (`#if canImport(StripePaymentSheet)`).

## Configuration

La clé publique Stripe est configurée dans `Config/StripeConfig.swift`.
L'URL du backend pour le `PaymentIntent` est dans `Network/PaymentService.swift`. Assurez-vous que votre backend est accessible à l'adresse indiquée (`http://192.168.137.1:3000`).
