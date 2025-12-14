# 🎨 Correspondance Design → Code

## Vue d'ensemble

Ce document montre la correspondance exacte entre le design fourni et les composants SwiftUI créés.

---

## 📱 Structure de l'Interface

```
┌─────────────────────────────────────────────────────────┐
│  ☰  Offres Étudiantes                            🔔     │  ← ModernHeaderView
├─────────────────────────────────────────────────────────┤
│  🔍 Rechercher une marque...                      ⚙️    │  ← ModernSearchBar
├─────────────────────────────────────────────────────────┤
│  [Tout] [Nourriture] [Tech] [Loisirs] [Vêtement] →     │  ← CategoryChipsView
├─────────────────────────────────────────────────────────┤
│  Nos Marques Partenaires                           ➕   │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                   │
│  │ P  │ │ T  │ │ B  │ │ S  │ │ F  │  →                │  ← MarquePartenaireView
│  └────┘ └────┘ └────┘ └────┘ └────┘                   │
│  Pizza  Tech   Book   Style  Food                      │
├─────────────────────────────────────────────────────────┤
│  Toutes les Promotions                             ➕   │
│                                                         │
│  ┌───────────────────────────────────────────────┐     │
│  │ ┌─────────────────────────────────────┐  ✏️ 🗑️│     │
│  │ │                                     │       │     │
│  │ │         [Image Pizza]               │       │     │
│  │ │                                     │       │     │  ← ModernPubliciteCard
│  │ └─────────────────────────────────────┘       │     │
│  │ Pizza Express                                 │     │
│  │ 2 Pizzas Achetées = 1 Offerte                 │     │
│  │ 📅 Expire le 31 décembre                      │     │
│  └───────────────────────────────────────────────┘     │
│                                                         │
│  ┌───────────────────────────────────────────────┐     │
│  │ [Autre publicité...]                          │     │
│  └───────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

---

## 🧩 Composants et Correspondance

### 1. Header (Ligne 1)

**Design** :
```
☰  Offres Étudiantes  🔔
```

**Composant** : `ModernHeaderView.swift`

**Code** :
```swift
ModernHeaderView(
    title: "Offres Étudiantes",
    onMenuTap: { /* Menu */ },
    onNotificationTap: { /* Notifications */ }
)
```

**Éléments** :
- ☰ Menu hamburger (gauche)
- "Offres Étudiantes" (centré)
- 🔔 Notifications avec badge (droite)

---

### 2. Barre de Recherche (Ligne 2)

**Design** :
```
🔍 Rechercher une marque...  ⚙️
```

**Composant** : `ModernSearchBar.swift`

**Code** :
```swift
ModernSearchBar(
    searchText: $searchText,
    placeholder: "Rechercher une marque...",
    onFilterTap: { /* Filtres */ }
)
```

**Éléments** :
- 🔍 Icône loupe
- Champ de texte
- ⚙️ Bouton filtre
- Fond gris clair (#F2F2F2)
- Coins arrondis (12pt)

---

### 3. Catégories (Ligne 3)

**Design** :
```
[Tout] [Nourriture] [Tech] [Loisirs] →
```

**Composant** : `CategoryChipsView.swift`

**Code** :
```swift
CategoryChipsView(
    selectedCategory: $selectedCategory,
    categories: ["Tout", "Nourriture", "Tech", "Loisirs", ...]
)
```

**Éléments** :
- Scroll horizontal
- Chips cliquables
- Sélection en bleu
- Non-sélection en gris clair
- Coins arrondis (20pt)

---

### 4. Marques Partenaires (Lignes 4-6)

**Design** :
```
Nos Marques Partenaires  ➕

[P]  [T]  [B]  [S]  →
Pizza Tech Book Style
```

**Composant** : `MarquePartenaireView.swift`

**Code** :
```swift
MarquePartenaireView(
    marques: viewModel.partnerBrands,
    onAddTap: { /* Ajouter marque */ }
)
```

**Éléments** :
- Titre "Nos Marques Partenaires"
- Bouton ➕ (droite)
- Scroll horizontal
- Cartes circulaires (64x64pt)
- Initiales en blanc
- Couleurs aléatoires
- Nom en dessous

---

### 5. Liste de Publicités (Lignes 7+)

**Design** :
```
Toutes les Promotions  ➕

┌─────────────────────────┐
│ [Image]          ✏️ 🗑️ │
│ Pizza Express          │
│ 2 Pizzas = 1 Offerte   │
│ 📅 Expire le 31 déc    │
└─────────────────────────┘
```

**Composant** : `ModernPubliciteCard.swift`

**Code** :
```swift
ModernPubliciteCard(
    publicite: publicite,
    canEdit: viewModel.canEdit(publicite),
    onEdit: { /* Éditer */ },
    onDelete: { /* Supprimer */ }
)
```

**Éléments** :
- Image (200pt de hauteur)
- Boutons ✏️ 🗑️ (top-right, conditionnels)
- Nom du sponsor (bleu)
- Titre de l'offre (gras)
- Date d'expiration (gris)
- Coins arrondis (16pt)
- Ombre légère

---

## 🎨 Styles et Couleurs

### Couleurs Utilisées

| Élément | Couleur | Code SwiftUI |
|---------|---------|--------------|
| Catégorie sélectionnée | Bleu | `Color.blue` |
| Catégorie non-sélectionnée | Gris clair | `Color(.systemGray6)` |
| Bouton éditer | Bleu | `Color.blue.opacity(0.9)` |
| Bouton supprimer | Rouge | `Color.red.opacity(0.9)` |
| Bouton ajouter | Bleu | `Color.blue` |
| Fond de recherche | Gris clair | `Color(.systemGray6)` |
| Texte sponsor | Bleu | `Color.blue` |
| Texte date | Gris | `Color.gray` |

### Espacements

| Élément | Espacement |
|---------|------------|
| Entre sections | 20pt |
| Entre cartes | 16pt |
| Padding horizontal | 16pt |
| Entre chips | 12pt |
| Padding interne carte | 16pt |

### Coins Arrondis

| Élément | Rayon |
|---------|-------|
| Cartes de publicité | 16pt |
| Barre de recherche | 12pt |
| Chips de catégorie | 20pt |
| Boutons circulaires | Circle |

---

## 🔐 Logique de Permissions

### Affichage Conditionnel

**Bouton + (Ajouter publicité)** :
```swift
if viewModel.isSponsor {
    Button("+") { showAddPublicite = true }
}
```

**Boutons Edit/Delete** :
```swift
ModernPubliciteCard(
    canEdit: viewModel.canEdit(publicite)  // ✅ Vérification
)
```

### Fonction de Vérification

```swift
func canEdit(_ publicite: Publicite) -> Bool {
    guard let currentUser = AuthenticationManager.shared.currentUser else {
        return false
    }
    
    // Admin → tout éditer
    if currentUser.role?.lowercased() == "admin" {
        return true
    }
    
    // Sponsor → ses publicités uniquement
    if currentUser.role?.lowercased() == "sponsor" {
        return publicite.sponsorId == currentUser.id
    }
    
    return false
}
```

---

## 📊 Flux de Données

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  OffresEtudiantesView                               │
│  ┌───────────────────────────────────────────────┐ │
│  │                                               │ │
│  │  @StateObject viewModel = PubliciteViewModel  │ │
│  │                                               │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │ ModernHeaderView                        │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  │                                               │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │ ModernSearchBar                         │ │ │
│  │  │   searchText → viewModel.searchText     │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  │                                               │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │ CategoryChipsView                       │ │ │
│  │  │   selectedCategory → viewModel          │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  │                                               │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │ MarquePartenaireView                    │ │ │
│  │  │   marques ← viewModel.partnerBrands     │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  │                                               │ │
│  │  ForEach(viewModel.filteredPublicites)       │ │
│  │  ┌─────────────────────────────────────────┐ │ │
│  │  │ ModernPubliciteCard                     │ │ │
│  │  │   canEdit ← viewModel.canEdit(pub)      │ │ │
│  │  └─────────────────────────────────────────┘ │ │
│  │                                               │ │
│  └───────────────────────────────────────────────┘ │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🎯 Points Clés

### ✅ Respect du Design

- [x] Header identique
- [x] Barre de recherche identique
- [x] Catégories identiques
- [x] Marques partenaires identiques
- [x] Cartes de publicités identiques
- [x] Boutons conditionnels selon permissions

### ✅ Fonctionnalités

- [x] Recherche en temps réel
- [x] Filtres par catégorie
- [x] Scroll horizontal (catégories, marques)
- [x] Scroll vertical (publicités)
- [x] Navigation vers détails
- [x] Ajout/édition/suppression avec permissions

### ✅ Qualité du Code

- [x] Composants réutilisables
- [x] Séparation des responsabilités
- [x] Code propre et commenté
- [x] Gestion des états (loading, empty, error)
- [x] Async/await pour les opérations réseau

---

## 📝 Exemple d'Utilisation Complète

```swift
import SwiftUI

struct OffresEtudiantesView: View {
    @StateObject private var viewModel = PubliciteViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Header
                    ModernHeaderView(
                        title: "Offres Étudiantes",
                        onMenuTap: { },
                        onNotificationTap: { }
                    )
                    
                    // 2. Recherche
                    ModernSearchBar(
                        searchText: $searchText,
                        onFilterTap: { }
                    )
                    .onChange(of: searchText) { newValue in
                        viewModel.searchText = newValue
                    }
                    
                    // 3. Catégories
                    CategoryChipsView(
                        selectedCategory: $selectedCategory,
                        categories: ["Tout", "Nourriture", "Tech"]
                    )
                    .onChange(of: selectedCategory) { newValue in
                        viewModel.selectedCategory = newValue
                    }
                    
                    // 4. Marques
                    MarquePartenaireView(
                        marques: viewModel.partnerBrands,
                        onAddTap: { }
                    )
                    
                    // 5. Publicités
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredPublicites) { pub in
                            ModernPubliciteCard(
                                publicite: pub,
                                canEdit: viewModel.canEdit(pub),
                                onEdit: { },
                                onDelete: { }
                            )
                        }
                    }
                }
            }
            .task {
                await viewModel.loadPublicites()
            }
        }
    }
}
```

---

## ✨ Résultat Final

Vous avez maintenant une interface **100% conforme** au design fourni, avec :

- ✅ Tous les composants visuels identiques
- ✅ Toutes les fonctionnalités implémentées
- ✅ Logique de permissions robuste
- ✅ Code propre et maintenable

**Félicitations ! 🎉**

---

**Créé le** : 29 novembre 2025  
**Version** : 1.0
