# Configuration Backend - DarnaApp

## ✅ Configuration Actuelle

### Serveur Backend
- **Adresse IP**: `192.168.137.185`
- **Port**: `3007`
- **URL complète**: `http://192.168.137.185:3007`

### Configuration dans le Code
Le fichier de configuration centralisé se trouve dans :
```
DarnaApp/Resources/ServerConfig.swift
```

## 📡 Services Configurés

Tous les services API utilisent maintenant `ServerConfig.baseURL` :

1. **NetworkService** (Auth)
   - Login: `/auth/login`
   - Register: `/auth/register`
   - Logout: `/auth/logout`

2. **PropertyService** (Annonces)
   - Base URL: `/annonces`
   - Endpoints : fetch, create, update, delete, book

3. **VisitAPIService** (Visites)
   - Endpoints configurés dynamiquement

4. **PubliciteService** (Publicités)
   - Base URL: `/publicite`
   - Endpoints : fetch, create, update, delete

5. **AdAPIService** (Annonces sponsorisées)
   - Base URL: `/api/ads`
   - Actuellement en mode MOCK (données statiques)

## 🔄 Pour Changer l'Adresse du Serveur

Modifiez uniquement le fichier `ServerConfig.swift` :

```swift
private static let host = "192.168.137.185"  // ← Changez ici
private static let port = 3007                // ← Changez ici si besoin
```

Tous les services utiliseront automatiquement la nouvelle configuration.

## ✅ Build Status
- **Dernière compilation**: ✅ BUILD SUCCEEDED
- **Date**: 28 novembre 2025
- **Toutes les erreurs résolues**:
  - ✅ Repository path corrigé
  - ✅ PropertyBookingsView ajouté au projet
  - ✅ FavoritesView, MyReservationsView, AcceptedClientsView ajoutés
  - ✅ Image asset extension corrigée
  - ✅ Warning var→let corrigé dans AdAPIService

## 🚀 L'application est prête à être déployée !
