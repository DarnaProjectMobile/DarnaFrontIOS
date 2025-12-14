# Instructions pour PubliciteFormView - Upload Image et Champs Conditionnels

## 📋 Fichiers à modifier/ajouter

### ✅ Fichier modifié (déjà fait)
- **`DarnaApp/Views/Components/PubliciteFormView.swift`** - Fichier principal avec toutes les nouvelles fonctionnalités

### 📦 Fichiers à vérifier (déjà présents dans le projet)
Ces fichiers doivent déjà exister dans votre projet. Vérifiez qu'ils sont bien présents :

1. **`DarnaApp/Models/Publicite.swift`** 
   - Doit contenir les structures `DetailReduction`, `DetailPromotion`, `DetailJeu`, `ReductionJeu`
   - Doit contenir `PubliciteDTO` avec les champs : `titre`, `description`, `image`, `type`, `details`, `categorie`

2. **`DarnaApp/Services/AuthenticationManager.swift`**
   - Pour accéder à `AuthenticationManager.shared.currentUser?.id`

3. **`DarnaApp/ViewModels/PubliciteViewModel.swift`**
   - Doit avoir les méthodes `createPublicite(_ dto: PubliciteDTO)` et `updatePublicite(id: String, dto: PubliciteDTO)`

4. **`DarnaApp/Views/Components/PubliciteCardView.swift`**
   - Pour l'aperçu dans le formulaire

### 🔧 Imports nécessaires
Le fichier `PubliciteFormView.swift` utilise :
- `import SwiftUI` (déjà présent)
- `import PhotosUI` (ajouté pour l'upload d'image)

### 📝 Structures ajoutées dans PubliciteFormView.swift
Les structures suivantes sont définies à la fin du fichier :
- `RecompenseJeu` - Pour gérer les récompenses du jeu
- `DetailReductionDTO` - Pour encoder les détails de réduction
- `DetailPromotionDTO` - Pour encoder les détails de promotion
- `DetailJeuDTO` - Pour encoder les détails du jeu (roulette)

## 🎯 Fonctionnalités implémentées

### 1. Upload d'image
- Remplace le champ URL par un sélecteur d'image (`PhotosPicker`)
- Conversion automatique en base64
- Aperçu de l'image sélectionnée
- Supporte aussi l'URL si nécessaire (rétrocompatibilité)

### 2. Champs conditionnels selon le type

#### Type "Réduction"
- **Pourcentage de réduction (%)** : Champ numérique obligatoire
- **Conditions d'utilisation** : Champ texte multiligne optionnel

#### Type "Promo"
- **Détail de la promotion** : Champ texte obligatoire (ex: "1+1 gratuit")

#### Type "Bon plan" (Jeu)
- **Nombre de cases** : Stepper de 4 à 16 cases
- **Liste des récompenses** : 
  - Ajout/suppression de récompenses
  - Chaque récompense a :
    - Texte (ex: "-10%", "Rien gagné")
    - Pourcentage de réduction (0-100%)
    - Probabilité (0-100%)
- **Sheet modal** pour ajouter une nouvelle récompense avec sliders

### 3. Validation
- Validation conditionnelle selon le type
- Champs obligatoires marqués avec `*`
- Vérification des dates (fin > début)
- Vérification de l'image (base64 ou URL)

## 🔄 Encodage des données

Les détails conditionnels sont encodés en JSON dans le champ `details` du `PubliciteDTO` :

- **Réduction** : `{"pourcentage": 25, "conditionsUtilisation": "..."}`
- **Promotion** : `{"offre": "1+1 gratuit", "conditions": null}`
- **Jeu** : `{"description": "...", "gains": [...], "reductions": [...], "nombreCases": 8, "probabilites": [...]}`

## 🚀 Utilisation

Le formulaire s'adapte automatiquement selon le type sélectionné :
1. L'utilisateur choisit un type dans le picker
2. Les champs correspondants s'affichent automatiquement
3. La validation s'adapte selon le type
4. Les données sont encodées correctement pour le backend

## ⚠️ Notes importantes

1. **Backend** : Assurez-vous que votre backend accepte :
   - Le champ `image` en base64 (format: `data:image/jpeg;base64,...`)
   - Le champ `details` en JSON string
   - Les types en minuscules : "reduction", "promotion", "jeu"

2. **Permissions** : Pour l'upload d'image, ajoutez dans `Info.plist` :
   ```xml
   <key>NSPhotoLibraryUsageDescription</key>
   <string>Nous avons besoin d'accéder à vos photos pour ajouter une image à votre publicité</string>
   ```

3. **Compatibilité** : Le code gère à la fois les images base64 et les URLs pour la rétrocompatibilité.

## 📱 Interface utilisateur

L'interface suit le design de l'image fournie :
- Formulaire dans une carte blanche avec coins arrondis
- Champs marqués avec `*` pour les obligatoires
- Boutons "Enregistrer" (bleu) et "Annuler" (blanc)
- Header avec titre "Ajouter une publicité"
- Scrollable avec tous les champs

## ✅ Checklist avant utilisation

- [ ] Vérifier que `PhotosUI` est importé
- [ ] Vérifier que `AuthenticationManager` est accessible
- [ ] Vérifier que `PubliciteDTO` a la bonne structure
- [ ] Ajouter les permissions dans `Info.plist` pour la galerie photo
- [ ] Tester l'upload d'image
- [ ] Tester chaque type (Réduction, Promo, Bon plan)
- [ ] Vérifier la validation des champs
- [ ] Tester l'enregistrement avec le backend

