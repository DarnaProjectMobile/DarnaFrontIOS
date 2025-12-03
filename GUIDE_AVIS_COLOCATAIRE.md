# Guide du Système d'Avis Colocataire (iOS)

Ce guide documente le fonctionnement du système d'affichage des avis reçus pour les colocataires dans l'application iOS, aligné sur la version Android.

## 1. Vue d'ensemble

Les colocataires peuvent désormais consulter les avis laissés par les visiteurs (clients) de deux manières :
1.  **Onglet "Avis reçus"** : Une liste centralisée de tous les avis reçus.
2.  **Bouton "Voir l'avis"** : Une action directe sur une carte de visite spécifique.

## 2. Fonctionnalités

### A. Onglet "Avis reçus"

*   **Accès** : Dans `VisitManagementView`, un nouvel onglet "Avis reçus" est disponible (visible uniquement si le rôle de l'utilisateur est "colocataire").
*   **Contenu** : Affiche une liste de cartes d'avis (`ReviewCard`).
*   **Design** :
    *   Liste défilante moderne.
    *   État vide illustré si aucun avis n'est disponible.
    *   Chargement asynchrone des avis.

### B. Action "Voir l'avis" sur la Carte de Visite

*   **Condition** : Le bouton apparaît sur une `VisitCardView` si :
    *   L'utilisateur est un colocataire.
    *   La visite possède un `reviewId` (c'est-à-dire qu'elle a été évaluée).
*   **Interaction** :
    *   L'utilisateur appuie sur l'icône étoile ("Voir l'avis").
    *   Une feuille modale (`sheet`) s'ouvre affichant le détail de l'avis.
*   **Technique** :
    *   L'action déclenche `onSeeReview`.
    *   Le `VisitViewModel` charge l'avis correspondant (s'il n'est pas déjà en cache) et met à jour `selectedReview`.

## 3. Architecture Technique

### Modèles (`Visit.swift`)
*   `VisitReview` : Structure de données contenant les notes (globale, propreté, localisation, etc.) et le commentaire.
*   `Visit` : Contient un champ `reviewId` optionnel qui lie la visite à son avis.

### Vue (`ReviewsListView.swift`)
*   Composant réutilisable affichant une liste d'avis.
*   Contient le sous-composant `ReviewCard` qui affiche :
    *   La note globale (étoile).
    *   La date.
    *   Les notes détaillées (Propreté, Accueil, etc.).
    *   Le commentaire textuel.

### ViewModel (`VisitViewModel.swift`)
*   `receivedReviews` : Tableau `@Published` stockant les avis reçus.
*   `loadReceivedReviews()` : Méthode qui récupère les visites du colocataire, filtre celles avec un avis, et charge les détails des avis via l'API.

### Vue Principale (`VisitManagementView.swift`)
*   Gère l'état `selectedReview` pour l'affichage modal.
*   Intègre `ReviewsListView` dans le `switch` des sections.
*   Passe la closure `onSeeReview` à `VisitCardView`.

## 4. Alignement Android

Cette implémentation reproduit fidèlement l'expérience Android :
*   **Visibilité** : Les avis sont facilement accessibles.
*   **Transparence** : Le colocataire voit exactement ce que le client a pensé.
*   **Design** : Utilisation d'icônes et de codes couleurs familiers (étoile jaune/orange).

## 5. Maintenance

Pour modifier le design des cartes d'avis, éditez `DarnaApp/Views/Components/ReviewsListView.swift`.
Pour changer la logique de chargement, éditez `DarnaApp/ViewModels/VisitViewModel.swift`.
