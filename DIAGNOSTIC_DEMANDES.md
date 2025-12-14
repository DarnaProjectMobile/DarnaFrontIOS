# 🔍 Diagnostic : Les demandes ne s'affichent pas

**Date:** 2025-12-05  
**Problème:** Les demandes de visite ne s'affichent pas dans `CollocatorVisitsView`

## 📊 Flux de chargement des données

### 1. Vue : CollocatorVisitsView
```swift
.task {
    await viewModel.loadInitialData()
}
```

### 2. ViewModel : VisitViewModel
```swift
func loadInitialData() async {
    await withTaskGroup(of: Void.self) { group in
        group.addTask { await self.refreshMyVisits() }
        group.addTask { await self.refreshCollocatorVisits() }  // ← Charge les demandes
    }
}

func refreshCollocatorVisits(force: Bool = false) async {
    guard !isLoading || force else { return }
    isLoading = true
    defer { isLoading = false }
    
    print("🔄 Refreshing Collocator Visits...")
    
    do {
        collocatorVisits = try await repository.loadCollocatorVisits()
        print("✅ \(collocatorVisits.count) visites collocator chargées depuis le repository.")
    } catch {
        print("❌ Erreur refreshCollocatorVisits: \(error)")
        handle(error, silentOnForbidden: true)
    }
}
```

### 3. Repository : VisitRepository
```swift
func loadCollocatorVisits() async throws -> [Visit] {
    try await api.fetchCollocatorVisits()
}
```

### 4. API : VisitAPIService
```swift
func fetchCollocatorVisits() async throws -> [Visit] {
    try await get(endpoint: "/visite/my-logements-visites")
}
```

### 5. Endpoint Backend
**URL complète:** `http://172.18.5.91:3007/visite/my-logements-visites`  
**Méthode:** GET  
**Headers:** Authorization: Bearer {token}

## 🔍 Points de vérification

### 1. ✅ Code vérifié
- `CollocatorVisitsView` appelle bien `loadInitialData()`
- `VisitViewModel` charge bien les visites du collocateur
- `VisitRepository` fait bien l'appel API
- `VisitAPIService` utilise le bon endpoint

### 2. ⚠️ Points à vérifier

#### A. Backend accessible ?
- Le serveur `172.18.5.91:3007` est-il accessible ?
- L'endpoint `/visite/my-logements-visites` existe-t-il ?

#### B. Authentification
- Le token JWT est-il valide ?
- L'utilisateur est-il bien un collocateur ?

#### C. Données
- Y a-t-il des demandes de visite dans la base de données ?
- Les demandes sont-elles liées aux logements du collocateur ?

#### D. Logs
Vérifier les logs dans la console Xcode :
```
🔄 Refreshing Collocator Visits...
✅ X visites collocator chargées depuis le repository.
```

Si erreur :
```
❌ Erreur refreshCollocatorVisits: [error details]
```

## 🛠️ Solutions possibles

### Solution 1 : Vérifier les logs
Regarder la console Xcode pour voir :
- Si l'appel API est fait
- S'il y a une erreur
- Combien de visites sont retournées

### Solution 2 : Vérifier l'endpoint backend
Tester l'endpoint avec curl :
```bash
curl -X GET "http://172.18.5.91:3007/visite/my-logements-visites" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Solution 3 : Vérifier le rôle utilisateur
S'assurer que l'utilisateur connecté a le rôle "collocator" ou "colocataire"

### Solution 4 : Ajouter des logs de debug
Modifier `VisitAPIService.swift` pour logger la requête :
```swift
func fetchCollocatorVisits() async throws -> [Visit] {
    print("📡 Fetching collocator visits from: \(baseURL)/visite/my-logements-visites")
    let visits: [Visit] = try await get(endpoint: "/visite/my-logements-visites")
    print("📥 Received \(visits.count) collocator visits")
    return visits
}
```

### Solution 5 : Vérifier les données de test
S'assurer qu'il y a des demandes de visite dans la base de données :
- Un client doit avoir réservé une visite
- La visite doit être pour un logement du collocateur connecté

## 📝 Checklist de diagnostic

- [ ] Vérifier les logs dans la console Xcode
- [ ] Vérifier que le serveur `172.18.5.91:3007` est accessible
- [ ] Vérifier que l'utilisateur est bien un collocateur
- [ ] Vérifier qu'il y a des demandes de visite dans la BD
- [ ] Tester l'endpoint avec curl/Postman
- [ ] Vérifier le token JWT
- [ ] Ajouter des logs de debug si nécessaire

## 🎯 Prochaines étapes

1. **Regarder les logs** dans la console Xcode
2. **Vérifier les données** dans la base de données
3. **Tester l'endpoint** directement avec curl
4. **Ajouter des logs** pour tracer le problème

Une fois que vous aurez les logs, nous pourrons identifier exactement où se situe le problème !
