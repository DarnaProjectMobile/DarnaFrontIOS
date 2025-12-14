# 🔧 RÉSOLUTION PROBLÈME BACKEND - Route Login

## Problème Identifié

**Erreur**: `404 Cannot POST /api/auth/login`

**Cause**: La route `/api/auth/login` n'existe pas sur le backend.

## 🧪 Test des Routes Possibles

### Option 1: Tester avec `/auth/login` (sans `/api`)

**Fichier**: `DarnaApp/Services/NetworkService.swift`  
**Ligne 45-46**:

```swift
// Actuel (ne fonctionne pas):
let loginURL = "\(baseURL)/api/auth/login"

// À tester:
let loginURL = "\(baseURL)/auth/login"
```

### Option 2: Vérifier les Routes du Backend

Si vous avez accès au code backend, vérifiez les routes dans:
- `src/auth/auth.controller.ts` (NestJS)
- `routes/auth.js` (Express)
- Ou le fichier équivalent

Cherchez la définition de la route de login:
```typescript
// Exemple NestJS:
@Post('login')  // → /auth/login
// ou
@Post('/api/auth/login')  // → /api/auth/login
```

### Option 3: Tester avec cURL

Testez depuis le terminal pour voir quelle route fonctionne:

```bash
# Test 1: Avec /api
curl -X POST http://192.168.137.177:3007/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'

# Test 2: Sans /api
curl -X POST http://192.168.137.177:3007/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'

# Test 3: Direct
curl -X POST http://192.168.137.177:3007/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
```

## 🔧 Solution Rapide

Si la route est `/auth/login` (sans `/api`), modifiez:

**NetworkService.swift, ligne 46**:
```swift
// Remplacer:
let loginURL = "\(baseURL)/api/auth/login"

// Par:
let loginURL = "\(baseURL)/auth/login"
```

Puis:
1. Arrêtez l'app (`Cmd + .`)
2. Recompilez (`Cmd + B`)
3. Relancez (`Cmd + R`)

## 📝 Autres Routes à Vérifier

Si vous changez la route de login, vérifiez aussi:

### Registration (ligne ~115):
```swift
let registerURL = "\(baseURL)/api/auth/register"
// Peut-être: "\(baseURL)/auth/register"
```

### Logout (ligne ~180):
```swift
let logoutURL = "\(baseURL)/api/auth/logout"
// Peut-être: "\(baseURL)/auth/logout"
```

## ✅ Après Correction

Une fois la bonne route configurée, vous devriez voir:
```
🔐 Tentative de connexion à: http://192.168.137.177:3007/auth/login
📤 Envoi de la requête de login...
📥 Réponse reçue du serveur
📊 Code de statut HTTP: 200
✅ Connexion réussie: [username]
```

---

**Dites-moi quelle est la bonne route et je ferai la modification!**
