# 🌐 Configuration du serveur backend - Mise à jour

**Date:** 2025-12-05  
**Statut:** ✅ Complété avec succès

## 🎯 Objectif

Mettre à jour l'adresse du serveur backend vers `172.18.5.91:3007` **uniquement pour les services d'authentification et de visites**.

## ✅ Modifications effectuées

### 1. **NetworkService.swift** - Service d'authentification
**Fichier:** `/DarnaApp/Services/NetworkService.swift`

**Changement:**
```swift
private let baseURL = "http://172.18.5.91:3007"
```

**Endpoints affectés:**
- `/auth/login` - Connexion
- `/auth/register` - Inscription
- `/auth/logout` - Déconnexion

---

### 2. **VisitAPIService.swift** - Service des visites
**Fichier:** `/DarnaApp/Network/VisitAPIService.swift`

**Changement:**
```swift
private let baseURL = "http://172.18.5.91:3007"
```

**Endpoints affectés:**
- `/visite/my-visites` - Mes visites
- `/visite/my-logements-visites` - Visites de mes logements
- `/visite` - Création de visite
- `/visite/:id` - Mise à jour/suppression de visite
- `/visite/:id/cancel` - Annulation de visite
- `/visite/:id/accept` - Acceptation de visite
- `/visite/:id/reject` - Rejet de visite
- `/visite/:id/validate` - Validation de visite
- `/visite/:id/review` - Soumission d'avis
- `/visite/:id/reviews` - Récupération des avis
- `/reviews/me/feedbacks` - Avis reçus

---

## 🚫 Fichiers NON modifiés (conservent leurs adresses d'origine)

### PropertyService.swift
- **Adresse conservée:** `http://172.18.12.144:3000`
- Gère les annonces de logements

### PubliciteService.swift
- **Adresse conservée:** `http://192.168.80.242:3007/api/publicites`
- Gère les publicités

### PaymentService.swift
- **Adresse conservée:** `http://192.168.80.242:3007`
- Gère les paiements Stripe

---

## 🔧 Compilation

**Résultat:** ✅ **BUILD SUCCEEDED**

La compilation a été testée et réussie sans erreurs ni warnings.

---

## 📝 Résumé

### Adresses IP par service

| Service | Adresse IP | Port | Modifié |
|---------|-----------|------|---------|
| **NetworkService** (Auth) | `172.18.5.91` | `3007` | ✅ OUI |
| **VisitAPIService** (Visites) | `172.18.5.91` | `3007` | ✅ OUI |
| PropertyService (Annonces) | `172.18.12.144` | `3000` | ❌ NON |
| PubliciteService (Publicités) | `192.168.80.242` | `3007` | ❌ NON |
| PaymentService (Paiements) | `192.168.80.242` | `3007` | ❌ NON |

---

## 🎉 Résultat

L'application utilise maintenant le serveur `172.18.5.91:3007` pour :
- ✅ L'authentification (login, register, logout)
- ✅ Toutes les fonctionnalités de visites et d'évaluations

Les autres services (annonces, publicités, paiements) conservent leurs adresses d'origine.
