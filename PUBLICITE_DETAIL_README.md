# 📱 Interface Détail Publicité - Documentation

## 📋 Vue d'ensemble

Cette interface complète permet d'afficher les détails d'une publicité avec trois types différents :
- **Réduction** : Affiche un code promo avec QR code
- **Promotion** : Affiche les détails de l'offre promotionnelle
- **Jeu** : Roue de la fortune interactive avec récompenses aléatoires

## 🗂️ Fichiers créés

### Models
- **`RouletteConfig.swift`** : Configuration de la roue (options, probabilités, couleurs)

### Services
- **`RouletteEngine.swift`** : Moteur de calcul pour les résultats aléatoires et angles de rotation

### ViewModels
- **`PubliciteDetailViewModel.swift`** : Gestion de l'état de la vue détail et logique du jeu

### Views
- **`PubliciteDetailView.swift`** : Vue principale avec navigation conditionnelle selon le type
- **`RouletteView.swift`** : Composant de la roue animée
- **`RouletteSegmentView.swift`** : Segment individuel de la roue
- **`QRCodeConfirmationView.swift`** : Écran de confirmation avec QR code

## 🎨 Fonctionnalités

### Type : Réduction
```swift
PubliciteDetailView(
    publicite: Publicite(
        id: "1",
        titre: "Réduction Étudiants",
        description: "Profitez de -20%",
        type: "reduction",
        detailReduction: DetailReduction(
            pourcentage: 20,
            conditionsUtilisation: "Carte étudiante requise"
        )
    )
)
```

**Affiche :**
- Code promo généré automatiquement
- Conditions d'utilisation
- Bouton "Utiliser ce code" → QR code

### Type : Promotion
```swift
PubliciteDetailView(
    publicite: Publicite(
        id: "2",
        titre: "Offre Spéciale",
        description: "Promotion limitée",
        type: "promotion",
        detailPromotion: DetailPromotion(
            offre: "1 acheté = 1 offert",
            conditions: "Valable jusqu'au 31/12"
        )
    )
)
```

**Affiche :**
- Icône cadeau
- Détail de l'offre
- Conditions si disponibles

### Type : Jeu
```swift
PubliciteDetailView(
    publicite: Publicite(
        id: "3",
        titre: "Roue de la Fortune",
        description: "Tentez votre chance !",
        type: "jeu",
        detailJeu: DetailJeu(
            description: "Gagnez des réductions",
            gains: ["-10%", "-20%", "-50%", "Rien gagné"],
            reductions: nil,
            nombreCases: 8,
            probabilites: [0.3, 0.2, 0.1, 0.4]
        )
    )
)
```

**Affiche :**
- Roue animée avec segments colorés
- Bouton "JOUER" au centre
- Animation de rotation fluide (2.5 secondes)
- Résultat affiché dans une bannière
- Bouton "Utiliser ma réduction" si gain

## 🎯 Utilisation

### Navigation vers la vue détail

```swift
NavigationLink {
    PubliciteDetailView(publicite: maPublicite)
} label: {
    PubliciteCardView(publicite: maPublicite)
}
```

### Configuration de la roue

Le `RouletteEngine` calcule automatiquement :
- Le résultat gagnant basé sur les probabilités
- L'angle de rotation final (5 tours + position finale)
- L'animation fluide avec `easeInOut`

```swift
let (result, index) = RouletteEngine.spin(
    options: ["Prix 1", "Prix 2", "Prix 3"],
    probabilities: [0.5, 0.3, 0.2]
)
```

### Personnalisation des couleurs

```swift
let config = RouletteConfig(
    options: ["-10%", "-20%", "-50%"],
    probabilities: [0.4, 0.3, 0.3],
    colors: ["#FF6B9D", "#4ECDC4", "#FFE66D"]  // Hex colors
)
```

## 🎨 Design

### Couleurs par défaut de la roue
- Rose vif : `#FF6B9D`
- Turquoise : `#4ECDC4`
- Jaune : `#FFE66D`
- Vert menthe : `#A8E6CF`
- Rouge corail : `#FF8B94`
- Violet pastel : `#B4A7D6`
- Cyan : `#95E1D3`
- Orange pêche : `#FFDAC1`

### Animations
- **Rotation de la roue** : `easeInOut` sur 2.5 secondes
- **Apparition du résultat** : `move(edge: .bottom)` + `opacity`
- **Indicateur** : Triangle rouge/orange en haut

## 🔧 Personnalisation

### Modifier la durée de rotation

```swift
// Dans RouletteEngine.swift
static let spinDuration: Double = 3.0  // 3 secondes au lieu de 2.5
```

### Modifier le nombre de tours

```swift
// Dans RouletteEngine.swift
static let numberOfSpins: Double = 7.0  // 7 tours au lieu de 5
```

### Changer les couleurs du badge de type

```swift
// Dans PubliciteDetailView.swift
private var typeColor: Color {
    switch viewModel.publicite.publiciteType {
    case .reduction:
        return Color.blue  // Au lieu de green
    // ...
    }
}
```

## ⚠️ Notes importantes

1. **Probabilités** : Doivent sommer à 1.0 (ou proche avec tolérance de 0.01)
2. **QR Code** : Nécessite `import CoreImage.CIFilterBuiltins`
3. **Animations** : Utilisent `@State` et `withAnimation` pour la fluidité
4. **Navigation** : Utilise `@Environment(\.dismiss)` pour le retour

## 🚀 Compilation

Tous les fichiers sont prêts et compilent sans erreur. Pour tester :

```bash
# Nettoyer le build
xcodebuild clean -project "DarnaApp.xcodeproj" -scheme DarnaApp

# Compiler
xcodebuild build -project "DarnaApp.xcodeproj" -scheme DarnaApp -sdk iphonesimulator
```

## 📱 Preview

Chaque vue dispose d'un `#Preview` pour visualisation dans Xcode :

```swift
#Preview {
    NavigationStack {
        PubliciteDetailView(
            publicite: Publicite(/* ... */)
        )
    }
}
```

## ✅ Checklist

- [x] Models créés (RouletteConfig)
- [x] Engine créé (RouletteEngine)
- [x] ViewModel créé (PubliciteDetailViewModel)
- [x] Vue principale créée (PubliciteDetailView)
- [x] Composant roue créé (RouletteView)
- [x] Composant segment créé (RouletteSegmentView)
- [x] Vue confirmation créée (QRCodeConfirmationView)
- [x] Animations fluides implémentées
- [x] Support des 3 types de publicité
- [x] Code propre et commenté
- [x] Compatible iOS 16+
