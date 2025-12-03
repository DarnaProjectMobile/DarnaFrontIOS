# 🎨 Guide Visuel - Design des Écrans de Visites

## 📱 Aperçu des Améliorations

Ce document présente les améliorations visuelles apportées aux écrans de gestion des visites de l'application Darna.

---

## 1. VisitCardView - Carte de Visite Premium

### Caractéristiques Principales

#### Header Premium
```
┌─────────────────────────────────────────┐
│  ●  Visite Appartement Vue Mer          │
│ [●] [En attente]                        │
└─────────────────────────────────────────┘
```
- **Indicateur de Statut** : Cercle avec dégradé (48x48)
- **Icône Dynamique** : Change selon le statut
- **Badge de Statut** : Capsule colorée avec texte

#### Sections avec Icônes Circulaires

**1. Demandeur**
```
[●] DEMANDEUR
    Jean Dupont
```
- Icône : person.fill
- Dégradé : Bleu → Violet
- Cercle : 40x40

**2. Date & Heure**
```
[●] 15 Décembre 2025
    🕐 14:30
```
- Icône : calendar.badge.clock
- Dégradé : Orange → Rouge
- Cercle : 40x40

**3. Contact**
```
[●] +216 12 345 678
```
- Icône : phone.fill
- Dégradé : Vert → Teal
- Cercle : 40x40

**4. Notes (Optionnel)**
```
┌─────────────────────────────────┐
│ [●] NOTES                       │
│     Préfère visiter l'après-midi│
└─────────────────────────────────┘
```
- Fond gris subtil (opacity 0.05)
- Bordure arrondie (12pt)

#### Boutons d'Action

**Accepter/Refuser (Layout Spécial)**
```
┌──────────────┐  ┌──────────────┐
│ ✓ Accepter   │  │ ✗ Refuser    │
└──────────────┘  └──────────────┘
```
- Accepter : Dégradé vert avec ombre
- Refuser : Bordure rouge, fond transparent

**Actions Standard**
```
[✏️ Modifier] [✓ Effectuée] [⭐ Évaluer]
```
- Scroll horizontal
- Capsules avec fond semi-transparent
- Bordure colorée

---

## 2. VisitManagementView - Interface de Gestion

### Structure Hiérarchique

```
┌─────────────────────────────────────────┐
│                                         │
│           [●]  Icône Gradient           │
│                                         │
│      Gestion des visites                │
│   Réservez et suivez vos visites        │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ [Réserver] [Mes visites] [...]  │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  Filtres: [Toutes] [●] [●] [●]  │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  Carte de Visite 1              │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  Carte de Visite 2              │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

### Composants Détaillés

#### 1. Header Premium
- **Icône** : 70x70, dégradé animé
- **Titre** : 32pt bold, dégradé de texte
- **Sous-titre** : 15pt, couleur secondaire

#### 2. Segmented Control Moderne
```
┌────────────────────────────────────────┐
│ [📅 Réserver] [📋 Mes visites] [👥...] │
└────────────────────────────────────────┘
```
- **Sélectionné** : Dégradé + ombre colorée
- **Non sélectionné** : Glassmorphism
- **Animation** : Spring (0.4s)

#### 3. Filtres Modernes
```
[Toutes] [🕐 En attente] [✓ Acceptée] [✗ Refusée]
```
- **Sélectionné** : Dégradé + scale 1.05
- **Non sélectionné** : Fond glassmorphique
- **Icônes** : Intégrées dans chaque chip

---

## 3. États Spéciaux

### Loading State
```
    ┌─────┐
    │  ●  │  Spinner animé
    └─────┘
  Chargement...
```
- Cercle avec dégradé bleu → violet
- Animation de rotation continue
- Texte stylisé en dessous

### Empty State
```
    ┌─────┐
    │  📅  │  Icône dans cercle
    └─────┘
    
  Aucune visite pour l'instant
  Réservez votre première visite
```
- Icône circulaire avec dégradé gris
- Message centré
- Fond glassmorphique

---

## 4. Palette de Couleurs

### Dégradés Principaux

**Réserver**
```
#3366FF ──→ #6633E6
(Bleu)      (Violet)
```

**Mes Visites**
```
#FF9500 ──→ #FF3B30
(Orange)    (Rouge)
```

**Espace Colocataire**
```
#AF52DE ──→ #FF2D55
(Violet)    (Rose)
```

### Statuts

| Statut    | Couleur | Icône              |
|-----------|---------|-------------------|
| Pending   | Orange  | clock.fill        |
| Accepted  | Vert    | checkmark.circle  |
| Rejected  | Rouge   | xmark.circle      |
| Cancelled | Gris    | slash.circle      |
| Completed | Vert    | checkmark.seal    |

---

## 5. Animations

### Types d'Animations

**1. Spring Animation**
```swift
.spring(response: 0.3-0.5, dampingFraction: 0.7)
```
- Utilisée pour : Sélections, transitions
- Effet : Naturel et fluide

**2. Linear Animation**
```swift
.linear(duration: 1).repeatForever()
```
- Utilisée pour : Spinner de chargement
- Effet : Rotation continue

**3. EaseInOut Animation**
```swift
.easeInOut(duration: 4).repeatForever(autoreverses: true)
```
- Utilisée pour : Background animé
- Effet : Dégradé qui pulse

### Transitions

**Changement de Section**
```
Section A ──→ Section B
  (slide left + fade out) → (slide right + fade in)
```

**Apparition de Carte**
```
Carte
  scale(0.8) + opacity(0) → scale(1.0) + opacity(1)
```

---

## 6. Espacements & Dimensions

### Padding
- **Cards** : 20pt
- **Sections** : 16-24pt
- **Chips** : 16pt horizontal, 10pt vertical

### Corner Radius
- **Cards** : 20-24pt
- **Buttons** : 12-16pt
- **Chips** : Capsule (hauteur/2)

### Ombres
- **Cards** : radius 20, opacity 0.15
- **Buttons** : radius 10, opacity 0.3
- **Header Icon** : radius 20, opacity 0.4

---

## 7. Typographie

### Hiérarchie

| Élément       | Taille | Poids  | Couleur      |
|---------------|--------|--------|--------------|
| Titre H1      | 32pt   | Bold   | Dégradé      |
| Titre H2      | 18pt   | Bold   | Primary      |
| Sous-titre    | 15pt   | Medium | Secondary    |
| Label         | 11-13pt| Bold   | Secondary    |
| Corps         | 14-15pt| Regular| Primary      |

### Styles Spéciaux
- **UPPERCASE** : Labels avec tracking 0.5
- **Dégradés** : Titres principaux
- **Bold** : Actions et éléments importants

---

## 8. Accessibilité

### Contraste
- ✅ Texte sur fond clair : ratio 4.5:1 minimum
- ✅ Icônes : Taille 16pt minimum
- ✅ Zones de toucher : 44x44pt minimum

### Feedback Visuel
- ✅ États hover/pressed
- ✅ Animations de confirmation
- ✅ Indicateurs de statut colorés

---

## 9. Responsive Design

### Adaptations
- **Petits écrans** : Scroll horizontal pour actions
- **Grands écrans** : Espacement optimisé
- **Orientation** : Layout adaptatif

---

## 10. Checklist de Qualité

### Design
- ✅ Hiérarchie visuelle claire
- ✅ Couleurs harmonieuses
- ✅ Espacements cohérents
- ✅ Typographie raffinée
- ✅ Icônes significatives

### Animations
- ✅ Transitions fluides
- ✅ Feedback immédiat
- ✅ Performance optimisée

### UX
- ✅ Navigation intuitive
- ✅ États visuels clairs
- ✅ Messages informatifs
- ✅ Actions accessibles

---

**Créé le** : 29 Novembre 2025  
**Version** : 2.0 Premium Design  
**Plateforme** : iOS 16+
