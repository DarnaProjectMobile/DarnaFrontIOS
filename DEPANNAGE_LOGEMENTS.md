# 🔧 Guide de dépannage - Liste de logements vide

## Problème : "Aucun logement disponible" dans la liste déroulante

Quand vous cliquez sur "Choisir un logement", la liste est vide. Voici comment résoudre ce problème.

---

## ✅ Solutions rapides

### Solution 1 : Ajouter des logements de test (RECOMMANDÉ)

**Terminal (macOS)** :
```bash
# Aller dans le dossier du projet
cd /Users/appleesprit/Documents/uyosra/DarnaFrontIOS-Gestion_User

# Rendre le script exécutable
chmod +x ajouter_logements_test.sh

# Lancer le script
./ajouter_logements_test.sh
```

Le script va :
1. Vous demander vos identifiants (email/password)
2. Se connecter au backend
3. Ajouter 5 logements de test
4. Confirmer le succès

**Résultat attendu** :
```
🏠 Script d'ajout de logements de test pour iOS
================================================

📡 Backend URL: http://192.168.137.185:3007

🔐 Veuillez entrer vos identifiants:
Email: votre@email.com
Mot de passe: ********

🔑 Connexion au backend...
✅ Connecté avec succès!

📦 Ajout des logements de test...

➕ Ajout de: Appartement 3 pièces Centre Ville...
   ✅ Créé avec ID: 67a8b9c0d1e2f3g4h5i6j7k8

➕ Ajout de: Studio meublé Ariana...
   ✅ Créé avec ID: 67a8b9c0d1e2f3g4h5i6j7k9

[...]

✨ Terminé!
```

---

### Solution 2 : Vérifier le backend

**1. Le backend est-il démarré ?**
```bash
# Tester la connexion
curl http://192.168.137.185:3007/annonces

# Si ça marche, vous devriez voir du JSON
# Sinon, erreur de connexion
```

**2. Démarrer le backend si nécessaire** :
```bash
# Aller dans le dossier backend
cd /path/to/backend

# Démarrer le serveur
npm start
# ou
node server.js
```

**3. Vérifier l'IP du backend** :

Ouvrir `DarnaApp/Resources/ServerConfig.swift` :
```swift
enum ServerConfig {
    private static let host = "192.168.137.185"  // ← Cette IP est correcte ?
    private static let port = 3007
    
    static var baseURL: String {
        "http://\(host):\(port)"
    }
}
```

Pour trouver la bonne IP :
```bash
# Sur macOS
ifconfig | grep "inet "

# Cherchez l'IP qui commence par 192.168.x.x
```

---

### Solution 3 : Ajouter via curl directement

```bash
# 1. Obtenir un token
TOKEN=$(curl -X POST "http://192.168.137.185:3007/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"votre@email.com","password":"votrepassword"}' \
  | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

# 2. Afficher le token pour vérifier
echo "Token: $TOKEN"

# 3. Ajouter un logement
curl -X POST "http://192.168.137.185:3007/annonces" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Appartement test",
    "description": "Un appartement pour tester",
    "price": 500,
    "location": "Tunis",
    "type": "Appartement",
    "nbrCollocateurMax": 2,
    "nbrCollocateurActuel": 0,
    "startDate": "2025-01-01T00:00:00.000Z",
    "endDate": "2025-12-31T23:59:59.000Z",
    "images": []
  }'
```

---

### Solution 4 : Vérifier dans MongoDB directement

Si vous avez accès à MongoDB :

```bash
# Se connecter à MongoDB
mongosh

# Utiliser la bonne base de données
use darna  # ou le nom de votre DB

# Lister les annonces
db.annonces.find()

# Compter les annonces
db.annonces.count()
```

---

## 🔍 Diagnostics

### Test 1 : Backend accessible ?
```bash
curl http://192.168.137.185:3007/health
# ou
curl http://192.168.137.185:3007/
```

✅ **Succès** : Vous voyez une réponse du serveur  
❌ **Échec** : "Connection refused" → Le backend n'est pas démarré

### Test 2 : Endpoint annonces accessible ?
```bash
curl http://192.168.137.185:3007/annonces
```

✅ **Succès** : Vous voyez `[]` (vide) ou une liste JSON  
❌ **Échec** : Erreur 404 → L'endpoint n'existe pas

### Test 3 : Authentification fonctionne ?
```bash
curl -X POST "http://192.168.137.185:3007/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
```

✅ **Succès** : Vous recevez un `access_token`  
❌ **Échec** : Erreur 401 → Identifiants incorrects

---

## 📱 Vérifications iOS

### 1. Vérifier les logs Xcode

1. Lancer l'app dans Xcode
2. Ouvrir la console (⌘Y)
3. Chercher les erreurs réseau :
   - "Failed to load properties"
   - "Network error"
   - "Invalid URL"

### 2. Ajouter du debug

Dans `VisitReservationView.swift`, modifier `loadPropertiesIfNeeded` :

```swift
private func loadPropertiesIfNeeded(force: Bool = false) async {
    guard properties.isEmpty || force else { return }
    isLoadingProperties = true
    defer { isLoadingProperties = false }
    do {
        print("🔍 Fetching properties from: \(ServerConfig.baseURL)/annonces")
        properties = try await PropertyService.shared.fetchProperties()
        print("✅ Loaded \(properties.count) properties")
        propertyLoadError = nil
    } catch {
        print("❌ Error loading properties: \(error)")
        propertyLoadError = error.localizedDescription
    }
}
```

### 3. Forcer le rechargement

Ajouter un bouton de refresh dans la vue :

```swift
Button("Recharger") {
    loadProperties()
}
```

---

## 🎯 Checklist complète

- [ ] Backend est démarré
- [ ] IP du backend est correcte dans `ServerConfig.swift`
- [ ] L'app peut se connecter au backend (test curl)
- [ ] Il y a des logements dans la DB (via script ou manuellement)
- [ ] L'utilisateur est authentifié
- [ ] Les logs Xcode ne montrent pas d'erreurs
- [ ] Pull-to-refresh dans l'app iOS fonctionne

---

## 🆘 Cas particuliers

### Erreur : "Cannot connect to backend"

**Causes possibles** :
1. Backend pas démarré
2. IP incorrecte
3. Pare-feu bloque la connexion
4. Différent réseau WiFi

**Solution** :
```bash
# Vérifier que le backend écoute bien sur toutes les interfaces
# Dans server.js ou app.js :
app.listen(3007, '0.0.0.0', () => {
    console.log('Server running on http://0.0.0.0:3007');
});
```

### Erreur : "Unauthorized"

**Cause** : Pas de token ou token expiré

**Solution** :
1. Se déconnecter de l'app
2. Se reconnecter
3. Réessayer

### Logements affichés sur Android mais pas iOS

**Cause** : Cache ou différence d'endpoints

**Solution** :
```bash
# Vérifier l'endpoint exactement
# Android : Check HomeViewModel.kt
# iOS : Check PropertyService.swift

# Ils doivent tous deux utiliser /annonces
```

---

## 📞 Support

Si le problème persiste après toutes ces étapes :

1. **Vérifiez les logs backend** :
   ```bash
   # Logs du serveur devraient montrer les requêtes
   ```

2. **Utilisez Postman** pour tester l'API :
   - GET `http://192.168.137.185:3007/annonces`
   - Doit retourner les annonces

3. **Comparez avec Android** :
   - Si Android fonctionne, comparez les appels réseau

---

## ✅ Après avoir ajouté des logements

1. **Relancer l'app iOS**
2. Aller dans **"Réserver une visite"**
3. Cliquer sur **"Choisir un logement"**
4. **Voir les logements** apparaître dans la liste déroulante ! 🎉

---

**Dernière mise à jour** : 28 novembre 2025  
**Version** : 1.0  
**Problème traité** : Liste de logements vide
