# Guide d'Intégration - Interface Moderne

## 🎯 Résumé des modifications

### ✅ Fichiers créés

1. **ModernHeaderView.swift** - Header avec menu et notifications
2. **ModernSearchBar.swift** - Barre de recherche moderne
3. **CategoryChipsView.swift** - Catégories horizontales (chips)
4. **MarquePartenaireView.swift** - Section marques partenaires
5. **ModernPubliciteCard.swift** - Carte de publicité moderne
6. **OffresEtudiantesView.swift** - Vue principale complète

### ✅ Fichiers modifiés

1. **PubliciteViewModel.swift** - Ajout des fonctions `canEdit()` et `canDelete()`

## 🔐 Logique de Permissions - Exemples

### Exemple 1 : Sponsor avec ses publicités

```swift
// Utilisateur connecté
let currentUser = User(
    id: "sponsor123",
    username: "Pizza Express",
    role: "sponsor"
)

// Publicité du sponsor
let publicite = Publicite(
    id: "pub1",
    titre: "2 Pizzas = 1 Offerte",
    sponsorId: "sponsor123"  // ✅ Même ID que currentUser
)

// Résultat
viewModel.canEdit(publicite) // ✅ true
// Les boutons edit/delete s'affichent
```

### Exemple 2 : Sponsor avec publicité d'un autre

```swift
// Utilisateur connecté
let currentUser = User(
    id: "sponsor123",
    username: "Pizza Express",
    role: "sponsor"
)

// Publicité d'un autre sponsor
let publicite = Publicite(
    id: "pub2",
    titre: "Réduction Tech",
    sponsorId: "sponsor456"  // ❌ ID différent
)

// Résultat
viewModel.canEdit(publicite) // ❌ false
// Les boutons edit/delete ne s'affichent PAS
```

### Exemple 3 : Admin

```swift
// Utilisateur admin
let currentUser = User(
    id: "admin1",
    username: "Admin",
    role: "admin"
)

// N'importe quelle publicité
let publicite = Publicite(
    id: "pub3",
    titre: "Offre quelconque",
    sponsorId: "sponsor789"
)

// Résultat
viewModel.canEdit(publicite) // ✅ true
// Admin peut tout éditer
```

### Exemple 4 : Utilisateur normal

```swift
// Utilisateur normal
let currentUser = User(
    id: "user1",
    username: "Étudiant",
    role: "user"
)

// N'importe quelle publicité
let publicite = Publicite(
    id: "pub4",
    titre: "Offre",
    sponsorId: "sponsor123"
)

// Résultat
viewModel.canEdit(publicite) // ❌ false
// Utilisateur normal ne peut rien éditer
```

## 📱 Utilisation dans votre app

### Option 1 : Remplacer HomePublicitesView

Dans votre fichier de navigation principal :

```swift
// ContentView.swift ou TabView

TabView {
    // Avant
    // HomePublicitesView()
    
    // Après
    OffresEtudiantesView()
        .tabItem {
            Label("Offres", systemImage: "megaphone.fill")
        }
}
```

### Option 2 : Ajouter comme nouvelle vue

```swift
NavigationLink("Offres Étudiantes") {
    OffresEtudiantesView()
}
```

## 🎨 Personnalisation

### Modifier les couleurs

Dans `ModernPubliciteCard.swift` :

```swift
// Bouton éditer
.background(Color.blue.opacity(0.9))  // Changez .blue

// Bouton supprimer
.background(Color.red.opacity(0.9))   // Changez .red
```

Dans `CategoryChipsView.swift` :

```swift
// Catégorie sélectionnée
.background(isSelected ? Color.blue : Color(.systemGray6))
```

### Modifier les catégories

Dans `OffresEtudiantesView.swift` :

```swift
private let categories = [
    "Tout", 
    "Nourriture",  // Modifiez ou ajoutez
    "Tech", 
    "Loisirs", 
    "Vêtement", 
    "Santé", 
    "Transport"
]
```

### Modifier le placeholder de recherche

```swift
ModernSearchBar(
    searchText: $searchText,
    placeholder: "Votre texte personnalisé...",  // ✏️ Modifiez ici
    onFilterTap: { }
)
```

## 🧪 Tests à effectuer

### 1. Test des permissions

```swift
// Dans OffresEtudiantesView, ajoutez temporairement :
.onAppear {
    if let user = AuthenticationManager.shared.currentUser {
        print("👤 User ID: \(user.id)")
        print("👤 User role: \(user.role ?? "nil")")
        print("👤 Is sponsor: \(viewModel.isSponsor)")
    }
    
    for pub in viewModel.filteredPublicites {
        print("📢 Pub: \(pub.titre)")
        print("   Sponsor ID: \(pub.sponsorId ?? "nil")")
        print("   Can edit: \(viewModel.canEdit(pub))")
    }
}
```

### 2. Test de la recherche

1. Tapez dans la barre de recherche
2. Vérifiez que les résultats se filtrent en temps réel
3. Effacez le texte → toutes les publicités réapparaissent

### 3. Test des catégories

1. Tapez sur "Nourriture"
2. Vérifiez que seules les publicités de cette catégorie s'affichent
3. Tapez sur "Tout" → toutes les publicités réapparaissent

### 4. Test des boutons

**En tant que sponsor :**
1. Vérifiez que le bouton + apparaît en haut de "Toutes les Promotions"
2. Vérifiez que les boutons edit/delete apparaissent sur VOS publicités
3. Vérifiez qu'ils n'apparaissent PAS sur les publicités des autres

**En tant qu'utilisateur normal :**
1. Vérifiez qu'aucun bouton + n'apparaît
2. Vérifiez qu'aucun bouton edit/delete n'apparaît

## 🐛 Résolution de problèmes

### Problème : Les boutons ne s'affichent pas

**Solution 1 : Vérifier l'utilisateur connecté**
```swift
print(AuthenticationManager.shared.currentUser)
```

**Solution 2 : Vérifier le sponsorId**
```swift
print("Publicite sponsorId: \(publicite.sponsorId)")
print("Current user id: \(AuthenticationManager.shared.currentUser?.id)")
```

**Solution 3 : Vérifier le rôle**
```swift
print("User role: \(AuthenticationManager.shared.currentUser?.role)")
```

### Problème : Erreur de compilation

**Si les fichiers ne sont pas reconnus par Xcode :**

1. Ouvrez Xcode
2. Clic droit sur le dossier `Views/Components`
3. "Add Files to DarnaApp..."
4. Sélectionnez tous les nouveaux fichiers
5. ✅ Cochez "Copy items if needed"
6. ✅ Cochez "Create groups"
7. ✅ Sélectionnez la target "DarnaApp"
8. Cliquez "Add"

### Problème : Les images ne s'affichent pas

**Vérifiez l'URL de l'image :**
```swift
if let imageUrl = publicite.imageUrl {
    print("Image URL: \(imageUrl)")
}
```

**Vérifiez que l'URL est complète :**
- ✅ `https://example.com/image.jpg`
- ❌ `/uploads/image.jpg` (URL relative)

## 📊 Structure des données attendue

### Backend doit renvoyer :

```json
{
  "_id": "pub123",
  "titre": "2 Pizzas Achetées = 1 Offerte",
  "description": "Profitez de notre offre",
  "type": "promotion",
  "image": "https://example.com/pizza.jpg",
  "sponsorId": "sponsor123",        // ✅ IMPORTANT
  "sponsorName": "Pizza Express",
  "sponsorLogo": "https://...",
  "dateExpiration": "2025-12-31",
  "categorie": "Nourriture"
}
```

### Champs critiques pour les permissions :

- `sponsorId` : ID du sponsor propriétaire
- `_id` : ID de la publicité

## 🚀 Prochaines étapes recommandées

1. **Formulaire d'ajout de publicité**
   - Créer `AddPubliciteView.swift`
   - Lier au bouton + dans `OffresEtudiantesView`

2. **Formulaire d'édition**
   - Créer `EditPubliciteView.swift`
   - Pré-remplir avec les données de la publicité

3. **Détails de la publicité**
   - Améliorer `PubliciteDetailView.swift`
   - Ajouter les boutons edit/delete si permissions

4. **Animations**
   - Ajouter des transitions entre les vues
   - Animer l'apparition des cartes

5. **Gestion des erreurs**
   - Améliorer les messages d'erreur
   - Ajouter des retry automatiques

## 📞 Support

Si vous rencontrez des problèmes :

1. Vérifiez les logs dans la console Xcode
2. Vérifiez que le backend renvoie bien `sponsorId`
3. Vérifiez que l'utilisateur est bien connecté
4. Testez avec différents rôles (sponsor, admin, user)

---

**Bon développement ! 🚀**
