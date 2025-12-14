# Fichiers Concernant les Visites - DarnaApp finam

## Date: 2025-12-05

## 📁 Structure Complète des Fichiers de Visite

### DarnaApp/Models/
```
Visit.swift
├── VisitStatus (enum)
│   ├── pending
│   ├── confirmed
│   ├── refused
│   ├── cancelled
│   ├── completed
│   ├── validated
│   └── unknown
├── Visit (struct)
├── VisitReview (struct)
├── VisitCreationPayload (struct)
├── VisitUpdatePayload (struct)
├── VisitStatusPayload (struct)
├── VisitReviewPayload (struct)
├── VisitReservationDraft (struct)
├── VisitEditDraft (struct)
├── VisitReviewDraft (struct)
└── VisitDateFormatter (class)
```

### DarnaApp/Network/
```
VisitAPIService.swift
├── fetchClientVisits() -> [Visit]
├── fetchCollectorVisits() -> [Visit]
├── createVisit(payload: VisitCreationPayload) -> Visit
├── updateVisit(id: String, payload: VisitUpdatePayload) -> Visit
├── updateVisitStatus(id: String, payload: VisitStatusPayload) -> Visit
├── validateVisit(id: String) -> Visit
├── deleteVisit(id: String) -> Void
├── createReview(payload: VisitReviewPayload) -> VisitReview
└── fetchReview(visitId: String) -> VisitReview
```

### DarnaApp/Repository/
```
VisitRepository.swift
├── fetchVisits(forCollector: Bool) -> [Visit]
├── createVisit(payload: VisitCreationPayload) -> Visit
├── updateVisit(id: String, payload: VisitUpdatePayload) -> Visit
├── acceptVisit(id: String) -> Visit
├── refuseVisit(id: String) -> Visit
├── cancelVisit(id: String) -> Visit
├── validateVisit(id: String) -> Visit
├── deleteVisit(id: String) -> Void
├── createReview(payload: VisitReviewPayload) -> VisitReview
└── fetchReview(visitId: String) -> VisitReview
```

### DarnaApp/ViewModels/
```
VisitViewModel.swift
├── Properties
│   ├── @Published visits: [Visit]
│   ├── @Published isLoading: Bool
│   ├── @Published errorMessage: String?
│   ├── @Published selectedFilter: VisitStatus?
│   └── filteredVisits: [Visit]
├── Methods
│   ├── loadVisits(forCollector: Bool)
│   ├── createVisit(payload: VisitCreationPayload)
│   ├── updateVisit(id: String, payload: VisitUpdatePayload)
│   ├── acceptVisit(id: String)
│   ├── refuseVisit(id: String)
│   ├── cancelVisit(id: String)
│   ├── validateVisit(id: String)
│   ├── deleteVisit(id: String)
│   ├── createReview(payload: VisitReviewPayload)
│   ├── fetchReview(visitId: String)
│   └── filterVisits(by: VisitStatus?)
```

### DarnaApp/Views/Components/
```
VisitCardView.swift
├── UI Components
│   ├── Status Badge
│   ├── Property Title
│   ├── Date & Time Display
│   ├── Contact Information
│   ├── Notes Section
│   └── Action Buttons
├── Actions
│   ├── onEdit: () -> Void
│   ├── onCancel: () -> Void
│   ├── onValidate: () -> Void
│   └── onRate: () -> Void
└── Styling
    ├── Modern Card Design
    ├── Color-coded Status
    └── Smooth Animations
```

### DarnaApp/Views/Screens/
```
CollocatorVisitsView.swift
├── Header with Filters
├── Visit Statistics
├── Visit List (filtered)
├── Empty State
└── Actions
    ├── Accept Visit
    ├── Refuse Visit
    └── View Details

VisitEditSheet.swift
├── Date Picker
├── Time Picker
├── Notes TextField
├── Contact Phone TextField
├── Save Button
└── Cancel Button

VisitManagementView.swift
├── Navigation Bar
├── Visit List
├── Filter Options
├── Sort Options
└── Actions
    ├── Edit Visit
    ├── Cancel Visit
    ├── Delete Visit
    └── Validate Visit

VisitReservationView.swift
├── Property Selection
├── Date & Time Picker
├── Contact Information
│   ├── Phone Number
│   └── Notes
├── Submit Button
└── Form Validation

VisitReviewSheet.swift
├── Visit Information Display
├── Rating Sections
│   ├── Collector Rating (1-5 stars)
│   ├── Cleanliness Rating (1-5 stars)
│   ├── Location Rating (1-5 stars)
│   └── Conformity Rating (1-5 stars)
├── Comment TextField
├── Submit Button
└── Cancel Button
```

## 📊 Détails des Fichiers

### 1. Visit.swift (313 lignes)
- **Localisation**: `DarnaApp/Models/Visit.swift`
- **Taille**: 8.4 KB
- **Rôle**: Modèle de données principal pour les visites
- **Dépendances**: Foundation, SwiftUI

### 2. VisitAPIService.swift
- **Localisation**: `DarnaApp/Network/VisitAPIService.swift`
- **Rôle**: Service pour les appels API des visites
- **Dépendances**: Foundation, ServerConfig

### 3. VisitRepository.swift
- **Localisation**: `DarnaApp/Repository/VisitRepository.swift`
- **Rôle**: Couche repository pour la gestion des données
- **Dépendances**: Foundation, Combine, VisitAPIService

### 4. VisitViewModel.swift
- **Localisation**: `DarnaApp/ViewModels/VisitViewModel.swift`
- **Rôle**: ViewModel pour la logique métier
- **Dépendances**: Foundation, Combine, SwiftUI, VisitRepository

### 5. VisitCardView.swift
- **Localisation**: `DarnaApp/Views/Components/VisitCardView.swift`
- **Rôle**: Composant réutilisable pour afficher une visite
- **Dépendances**: SwiftUI, Visit

### 6. CollocatorVisitsView.swift
- **Localisation**: `DarnaApp/Views/Screens/CollocatorVisitsView.swift`
- **Rôle**: Dashboard des visites pour colocataire
- **Dépendances**: SwiftUI, VisitViewModel, VisitCardView

### 7. VisitEditSheet.swift
- **Localisation**: `DarnaApp/Views/Screens/VisitEditSheet.swift`
- **Rôle**: Feuille modale pour éditer une visite
- **Dépendances**: SwiftUI, VisitViewModel, Visit

### 8. VisitManagementView.swift
- **Localisation**: `DarnaApp/Views/Screens/VisitManagementView.swift`
- **Rôle**: Vue de gestion des visites
- **Dépendances**: SwiftUI, VisitViewModel, VisitCardView

### 9. VisitReservationView.swift
- **Localisation**: `DarnaApp/Views/Screens/VisitReservationView.swift`
- **Rôle**: Vue pour réserver une nouvelle visite
- **Dépendances**: SwiftUI, VisitViewModel, PropertyViewModel

### 10. VisitReviewSheet.swift
- **Localisation**: `DarnaApp/Views/Screens/VisitReviewSheet.swift`
- **Rôle**: Feuille modale pour évaluer une visite
- **Dépendances**: SwiftUI, VisitViewModel, Visit

## 🔗 Dépendances entre Fichiers

```
Visit.swift (Model)
    ↓
VisitAPIService.swift (Network)
    ↓
VisitRepository.swift (Repository)
    ↓
VisitViewModel.swift (ViewModel)
    ↓
┌─────────────────────────────────────┐
│                                     │
VisitCardView.swift              Views (Screens)
    ↓                                 ↓
    ├── CollocatorVisitsView.swift
    ├── VisitEditSheet.swift
    ├── VisitManagementView.swift
    ├── VisitReservationView.swift
    └── VisitReviewSheet.swift
```

## 🎯 Utilisation des Fichiers

### Pour Afficher les Visites
```swift
import SwiftUI

struct MyView: View {
    @StateObject private var viewModel = VisitViewModel()
    
    var body: some View {
        List(viewModel.filteredVisits) { visit in
            VisitCardView(
                visit: visit,
                onEdit: { /* ... */ },
                onCancel: { /* ... */ },
                onValidate: { /* ... */ },
                onRate: { /* ... */ }
            )
        }
        .onAppear {
            viewModel.loadVisits(forCollector: false)
        }
    }
}
```

### Pour Créer une Visite
```swift
let payload = VisitCreationPayload(
    logementId: "123",
    dateVisite: VisitDateFormatter.shared.isoString(from: Date()),
    notes: "Notes optionnelles",
    contactPhone: "+33612345678"
)

viewModel.createVisit(payload: payload)
```

### Pour Évaluer une Visite
```swift
let reviewPayload = VisitReviewPayload(
    visiteId: visit.id,
    collectorRating: 5,
    cleanlinessRating: 4,
    locationRating: 5,
    conformityRating: 4,
    comment: "Excellent logement!"
)

viewModel.createReview(payload: reviewPayload)
```

## ✅ Checklist de Vérification

- [x] Tous les fichiers copiés
- [x] Tous les fichiers ajoutés au projet Xcode
- [x] Structure de dossiers créée (Components, Screens)
- [x] Dépendances correctement configurées
- [x] Aucun conflit avec les fichiers existants
- [x] Documentation créée
- [x] Prêt pour la compilation

## 📝 Notes

- Tous les fichiers utilisent Swift 5+
- Compatible iOS 15+
- Utilise SwiftUI pour l'interface
- Suit le pattern MVVM
- Utilise Combine pour la gestion des états
- API REST pour la communication backend
