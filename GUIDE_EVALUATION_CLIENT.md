# 🌟 Guide du Système d'Évaluation Client

## 📍 Où trouver la page d'évaluation ?

L'interface d'évaluation n'est pas une page isolée dans le menu, mais une **feuille modale contextuelle** qui s'ouvre automatiquement au bon moment.

### 🔄 Le Flux Client

1.  **Accès** : Le client va dans l'onglet **"Mes visites"** de l'écran "Gestion des visites".
2.  **Validation** : Sur une visite confirmée, il clique sur le bouton **"Effectuée"** (icône ✅).
3.  **Apparition** : Une fois la visite validée, un nouveau bouton **"Évaluer"** (icône ⭐) apparaît sur la carte de la visite.
4.  **Action** : En cliquant sur "Évaluer", la page d'évaluation (`VisitReviewSheet`) s'ouvre.

---

## 📱 L'Interface d'Évaluation (`VisitReviewSheet`)

C'est une interface moderne et simplifiée qui permet de noter 4 critères :

1.  **Accueil du colocataire** (Personne)
2.  **Propreté** (Étincelles)
3.  **Emplacement** (Localisation)
4.  **Conformité** (Sceau)

Chaque critère est noté de 1 à 5 étoiles. Un commentaire optionnel peut être ajouté.

### 🎨 Design
- **Style** : Épuré, fond blanc, sans animations excessives (pour la stabilité).
- **Interaction** : Sélection directe des étoiles.
- **Validation** : Bouton "Envoyer l'évaluation" qui enregistre tout dans la base de données.

---

## 🔍 Conditions Techniques

Pour que le bouton "Évaluer" apparaisse, la visite doit respecter ces conditions (dans le code `Visit.swift`) :

```swift
var canRate: Bool {
    // La visite doit être validée OU terminée
    // ET ne pas avoir déjà été évaluée
    (validated == true || status == .completed || status == .validated) && reviewId == nil
}
```
