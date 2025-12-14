# Interface Moderne - Offres Étudiantes

## 📱 Vue d'ensemble

Cette nouvelle interface SwiftUI moderne reproduit exactement le design fourni avec une architecture propre et modulaire.

## 🎨 Composants créés

### 1. **ModernHeaderView.swift**
Header avec menu hamburger, titre centré et icône de notifications.

**Utilisation :**
```swift
ModernHeaderView(
    title: "Offres Étudiantes",
    onMenuTap: { /* Action menu */ },
    onNotificationTap: { /* Action notifications */ }
)
```

### 2. **ModernSearchBar.swift**
Barre de recherche moderne avec icône loupe et bouton filtre.

**Utilisation :**
```swift
ModernSearchBar(
    searchText: $searchText,
    placeholder: "Rechercher une marque...",
    onFilterTap: { /* Action filtre */ }
)
```

### 3. **CategoryChipsView.swift**
Liste horizontale de catégories sous forme de chips (style Material Design).

**Utilisation :**
```swift
CategoryChipsView(
    selectedCategory: $selectedCategory,
    categories: ["Tout", "Nourriture", "Tech", "Loisirs"]
)
```

### 4. **MarquePartenaireView.swift**
Section des marques partenaires avec scroll horizontal et bouton d'ajout.

**Utilisation :**
```swift
MarquePartenaireView(
    marques: viewModel.partnerBrands,
    onAddTap: { /* Action ajouter marque */ }
)
```

### 5. **ModernPubliciteCard.swift**
Carte de publicité moderne avec :
- Image en haut (coins arrondis)
- Informations en bas
- Boutons edit/delete conditionnels selon les permissions

**Utilisation :**
```swift
ModernPubliciteCard(
    publicite: publicite,
    canEdit: viewModel.canEdit(publicite),
    onEdit: { /* Action éditer */ },
    onDelete: { /* Action supprimer */ }
)
```

### 6. **OffresEtudiantesView.swift**
Vue principale qui assemble tous les composants.

## 🔐 Logique de Permissions

### Fonction `canEdit(_ publicite: Publicite) -> Bool`

**Règles implémentées :**

1. **Admin** : Peut éditer/supprimer TOUTES les publicités
2. **Sponsor** : Peut éditer/supprimer UNIQUEMENT ses propres publicités
   - Vérifie que `publicite.sponsorId == currentUser.id`
3. **Autres rôles** : Aucun droit d'édition

**Code dans PubliciteViewModel.swift :**
```swift
func canEdit(_ publicite: Publicite) -> Bool {
    guard let currentUser = AuthenticationManager.shared.currentUser else {
        return false
    }
    
    // Admin peut tout éditer
    if currentUser.role?.lowercased() == "admin" {
        return true
    }
    
    // Sponsor peut éditer uniquement ses publicités
    if currentUser.role?.lowercased() == "sponsor" {
        return publicite.sponsorId == currentUser.id
    }
    
    return false
}
```

### Affichage conditionnel des boutons

Les boutons **Edit** et **Delete** s'affichent uniquement si `canEdit` retourne `true` :

```swift
ModernPubliciteCard(
    publicite: publicite,
    canEdit: viewModel.canEdit(publicite), // ✅ Vérifie les permissions
    onEdit: { /* ... */ },
    onDelete: { /* ... */ }
)
```

## 📊 Modèles de données

### Publicite (déjà existant)
```swift
struct Publicite {
    let id: String
    let titre: String
    let description: String
    let type: String
    let imageUrl: String?
    let sponsorId: String?      // ✅ ID du sponsor
    let sponsorName: String?
    let sponsorLogo: String?
    let dateExpiration: String?
    // ...
}
```

### User (déjà existant)
```swift
struct User {
    let id: String
    let username: String
    let email: String
    let role: String?  // "sponsor", "admin", "user"
    // ...
}
```

## 🎯 Fonctionnalités

### ✅ Recherche
- Recherche en temps réel avec debounce (300ms)
- Filtre sur titre, description et nom du sponsor

### ✅ Filtres par catégorie
- Chips horizontales
- Catégorie sélectionnée en bleu
- "Tout" pour afficher toutes les publicités

### ✅ Marques partenaires
- Extraction automatique des sponsors uniques
- Affichage des initiales si pas de logo
- Couleurs aléatoires basées sur le nom

### ✅ Gestion des publicités
- **Ajout** : Bouton + visible uniquement pour les sponsors
- **Édition** : Bouton visible uniquement pour les publicités du sponsor
- **Suppression** : Bouton visible uniquement pour les publicités du sponsor
- **Navigation** : Tap sur la carte pour voir les détails

### ✅ États de l'interface
- **Loading** : ProgressView pendant le chargement
- **Empty** : Message + bouton d'ajout si aucune publicité
- **Error** : Alertes pour les erreurs
- **Success** : Alertes pour les succès

## 🚀 Utilisation

### Remplacer l'ancienne vue

Dans votre navigation, remplacez `HomePublicitesView` par `OffresEtudiantesView` :

```swift
// Avant
NavigationLink("Publicités") {
    HomePublicitesView()
}

// Après
NavigationLink("Publicités") {
    OffresEtudiantesView()
}
```

### Tester les permissions

1. **En tant que Sponsor** :
   - Vous verrez le bouton + pour ajouter des publicités
   - Vous verrez les boutons edit/delete UNIQUEMENT sur VOS publicités

2. **En tant qu'Admin** :
   - Vous verrez les boutons edit/delete sur TOUTES les publicités

3. **En tant qu'Utilisateur normal** :
   - Vous ne verrez AUCUN bouton edit/delete
   - Vous ne verrez pas le bouton + pour ajouter

## 🎨 Design System

### Couleurs
- **Primary** : Bleu système (`.blue`)
- **Background** : `.systemGroupedBackground`
- **Cards** : `.systemBackground`
- **Text Primary** : `.primary`
- **Text Secondary** : `.secondary`

### Espacements
- **Section spacing** : 20pt
- **Card spacing** : 16pt
- **Horizontal padding** : 16pt
- **Chip spacing** : 12pt

### Coins arrondis
- **Cards** : 16pt
- **Search bar** : 12pt
- **Chips** : 20pt
- **Buttons** : Circle ou 12pt

### Ombres
- **Cards** : `radius: 8, x: 0, y: 4, opacity: 0.08`

## 📝 Notes importantes

1. **AuthenticationManager** : La logique de permissions utilise `AuthenticationManager.shared.currentUser`
2. **sponsorId** : Le modèle `Publicite` doit avoir le champ `sponsorId` (déjà présent)
3. **Navigation** : Utilise `NavigationStack` (iOS 16+)
4. **Async/Await** : Toutes les opérations réseau sont asynchrones
5. **Pull to refresh** : Implémenté avec `.refreshable`

## 🐛 Debugging

Si les boutons ne s'affichent pas :
1. Vérifiez que `currentUser` est bien défini
2. Vérifiez que `publicite.sponsorId` correspond à `currentUser.id`
3. Vérifiez le rôle de l'utilisateur (`role == "sponsor"`)

Console logs utiles :
```swift
print("Current user ID: \(AuthenticationManager.shared.currentUser?.id ?? "nil")")
print("Publicite sponsor ID: \(publicite.sponsorId ?? "nil")")
print("Can edit: \(viewModel.canEdit(publicite))")
```

## 📦 Fichiers créés

```
DarnaApp/
├── Views/
│   ├── Components/
│   │   ├── ModernHeaderView.swift          ✅ Nouveau
│   │   ├── ModernSearchBar.swift           ✅ Nouveau
│   │   ├── CategoryChipsView.swift         ✅ Nouveau
│   │   ├── MarquePartenaireView.swift      ✅ Nouveau
│   │   └── ModernPubliciteCard.swift       ✅ Nouveau
│   └── Screens/
│       └── OffresEtudiantesView.swift      ✅ Nouveau
└── ViewModels/
    └── PubliciteViewModel.swift            ✅ Modifié (ajout canEdit)
```

## 🎯 Prochaines étapes

1. Ajouter les vues de création/édition de publicités
2. Implémenter la navigation vers les détails
3. Ajouter les animations de transition
4. Implémenter le menu hamburger
5. Implémenter les notifications
6. Ajouter la gestion des favoris

---

**Créé le** : 29 novembre 2025  
**Version** : 1.0  
**Design** : Interface moderne type "Offres Étudiantes"
