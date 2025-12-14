# 🔍 Diagnostic : Erreur 403 + Crash sur "Demandes"

**Date:** 2025-12-05  
**Problème:** L'application crash quand on clique sur "Demandes" et affiche une erreur 403

## ❌ Erreur 403 - Forbidden

### Qu'est-ce que l'erreur 403 ?
L'erreur **403 Forbidden** signifie que le serveur **refuse l'accès** à la ressource demandée. L'utilisateur est authentifié, mais n'a **pas les permissions** nécessaires.

### Endpoint concerné
**URL:** `http://172.18.5.91:3007/visite/my-logements-visites`  
**Méthode:** GET  
**Headers:** Authorization: Bearer {token}

## 🔍 Causes possibles

### 1. ⚠️ Rôle utilisateur incorrect (PLUS PROBABLE)

**Problème:** L'utilisateur connecté n'a pas le rôle "collocateur" côté backend.

**Vérification:**
```swift
// Dans CollocatorDashboardView ou MainAppView
if let role = authManager.currentUser?.role?.lowercased() {
    print("🔐 Rôle utilisateur: \(role)")
}
```

**Solutions:**
- Vérifier que l'utilisateur a le rôle `"collocator"` ou `"colocataire"` dans la base de données
- Se connecter avec un compte collocateur valide
- Vérifier que le backend retourne bien le rôle dans la réponse de login

### 2. 🔑 Token JWT invalide ou expiré

**Problème:** Le token d'authentification n'est plus valide.

**Vérification:**
```swift
// Dans NetworkService ou VisitAPIService
if let token = authManager.token {
    print("🔑 Token: \(token.prefix(20))...")
} else {
    print("❌ Pas de token!")
}
```

**Solutions:**
- Se déconnecter et se reconnecter
- Vérifier que le token est bien sauvegardé dans le Keychain
- Vérifier la date d'expiration du token

### 3. 🔒 Permissions backend

**Problème:** L'endpoint `/visite/my-logements-visites` nécessite des permissions spéciales.

**Vérification backend:**
```javascript
// Côté backend (Node.js/Express)
router.get('/my-logements-visites', 
    authenticateToken,  // ✅ Vérifie le token
    checkRole(['collocator', 'colocataire']),  // ⚠️ Vérifie le rôle
    async (req, res) => { ... }
);
```

**Solutions:**
- Vérifier que l'endpoint accepte le rôle de l'utilisateur
- Vérifier les middlewares d'authentification côté backend
- Vérifier les logs du serveur backend

### 4. 🏠 Pas de logements associés

**Problème:** Le collocateur n'a pas de logements dans la base de données.

**Vérification:**
- Le collocateur doit avoir au moins un logement créé
- Les visites doivent être liées aux logements du collocateur

## 🛠️ Solutions appliquées

### 1. ✅ Affichage de l'erreur 403
**Avant:** `handle(error, silentOnForbidden: true)` - L'erreur était masquée  
**Après:** `handle(error, silentOnForbidden: false)` - L'erreur est affichée

Maintenant, quand vous cliquez sur "Demandes", vous devriez voir un message d'erreur au lieu d'un crash silencieux.

### 2. 📝 Logs de diagnostic
Les logs suivants sont affichés dans la console :
```
🔄 Refreshing Collocator Visits...
❌ Erreur refreshCollocatorVisits: [détails de l'erreur]
```

## 🎯 Prochaines étapes pour résoudre

### Étape 1 : Vérifier le rôle utilisateur

**Dans Xcode, console:**
```
🔐 Rôle utilisateur: [role]
```

Si le rôle n'est pas `"collocator"` ou `"colocataire"`, c'est le problème !

### Étape 2 : Vérifier le token

**Dans Xcode, console:**
```
🔑 Token: eyJhbGciOiJIUzI1NiIs...
```

Si pas de token, se reconnecter.

### Étape 3 : Vérifier le backend

**Tester l'endpoint avec curl:**
```bash
curl -X GET "http://172.18.5.91:3007/visite/my-logements-visites" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -v
```

**Réponse attendue:**
- ✅ 200 OK + liste des visites
- ❌ 403 Forbidden → Problème de permissions

### Étape 4 : Vérifier la base de données

**Requêtes SQL à exécuter:**
```sql
-- Vérifier le rôle de l'utilisateur
SELECT id, username, role FROM users WHERE id = 'USER_ID';

-- Vérifier les logements du collocateur
SELECT * FROM properties WHERE userId = 'USER_ID';

-- Vérifier les visites pour les logements du collocateur
SELECT v.* FROM visits v
JOIN properties p ON v.logementId = p.id
WHERE p.userId = 'USER_ID';
```

## 📋 Checklist de diagnostic

- [ ] Vérifier le rôle de l'utilisateur dans la console Xcode
- [ ] Vérifier que le token JWT existe
- [ ] Se déconnecter et se reconnecter
- [ ] Tester l'endpoint avec curl/Postman
- [ ] Vérifier les logs du serveur backend
- [ ] Vérifier que le collocateur a des logements dans la BD
- [ ] Vérifier qu'il y a des visites pour ces logements

## 💡 Solution rapide

**Si vous voulez tester rapidement:**

1. **Créer un compte collocateur** avec le bon rôle dans la base de données
2. **Créer au moins un logement** pour ce collocateur
3. **Créer une visite** pour ce logement (avec un compte client)
4. **Se connecter** avec le compte collocateur
5. **Cliquer sur "Demandes"** → Devrait afficher la visite

## 🎉 Résultat attendu

Une fois le problème résolu, vous devriez voir :
```
🔄 Refreshing Collocator Visits...
✅ X visites collocator chargées depuis le repository.
```

Et la liste des demandes de visite s'affichera correctement ! 🚀
