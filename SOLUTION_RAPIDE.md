# 🚨 PROBLÈME IDENTIFIÉ : Backend non accessible

## Le problème

Quand vous cliquez sur "Choisir un logement", la liste est **vide** car :

❌ **Le backend n'est PAS accessible** à l'adresse `http://192.168.137.185:3007`

---

## ✅ Solution RAPIDE (3 étapes)

### Étape 1 : Démarrer le backend

```bash
# 1. Ouvrir un nouveau Terminal
# 2. Aller dans le dossier du backend
cd /Users/appleesprit/Documents/uyosra/[NOM_DU_DOSSIER_BACKEND]

# 3. Démarrer le serveur
npm start
```

Vous devriez voir :
```
> Server running on http://0.0.0.0:3007
✅ Connected to MongoDB
```

---

### Étape 2 : Vérifier la connexion

Dans un **nouveau Terminal** :
```bash
curl http://192.168.137.185:3007/annonces
```

✅ **Si ça marche** : Vous voyez `[]` ou une liste JSON  
❌ **Si erreur** : Passez à l'Étape 3

---

### Étape 3 : Ajouter des logements de test

```bash
# Dans le Terminal, depuis le dossier iOS
cd /Users/appleesprit/Documents/uyosra/DarnaFrontIOS-Gestion_User

# Rendre le script exécutable
chmod +x ajouter_logements_test.sh

# Lancer le script
./ajouter_logements_test.sh
```

Le script va :
1. Vous demander votre **email** et **mot de passe**
2. Ajouter **5 logements de test** automatiquement
3. Confirmer le succès

---

## 🔄 Après avoir démarré le backend

### Dans l'app iOS :

1. **Relancer l'app** (Stop puis Run dans Xcode)
2. Aller dans **"Réserver une visite"**
3. Cliquer sur **"Choisir un logement"**
4. **La liste devrait maintenant s'afficher !** 🎉

---

## 🆘 Si le backend ne démarre pas

### Option A : Trouver le bon dossier

```bash
# Chercher le dossier backend
find ~/Documents -name "package.json" -path "*/backend/*" 2>/dev/null

# Ou chercher par nom
ls ~/Documents/uyosra/
```

Cherchez un dossier comme :
- `DarnaBackend`
- `backend`
- `server`
- `darna-api`

### Option B : Vérifier les dépendances

```bash
cd /path/to/backend

# Installer les dépendances
npm install

# Démarrer
npm start
```

### Option C : Vérifier MongoDB

Le backend a besoin de MongoDB qui tourne :

```bash
# Vérifier si MongoDB est démarré
ps aux | grep mongod

# Si pas démarré, le lancer:
# Sur macOS avec brew:
brew services start mongodb-community

# Ou manuellement:
mongod --dbpath /path/to/data
```

---

## 🎯 Checklist complète

Cochez au fur et à mesure :

- [ ] MongoDB est démarré
- [ ] Backend est démarré (npm start)
- [ ] Backend écoute sur le port 3007
- [ ] `curl http://192.168.137.185:3007/annonces` fonctionne
- [ ] Script `ajouter_logements_test.sh` a ajouté des logements
- [ ] App iOS est relancée
- [ ] La liste de logements s'affiche ! ✅

---

## 📸 Résultat attendu

Après ces étapes, quand vous cliquez sur "Choisir un logement" dans l'app iOS, vous devriez voir :

```
┌──────────────────────────────────┐
│ 🏠 Choisir un logement      ✓   │
│ ┌────────────────────────────┐  │
│ │ Appartement 3 pièces... 🔼│  │
│ └────────────────────────────┘  │
│                                  │
│ ┌────────────────────────────┐  │
│ │ [📷] Appartement 3 pièces  │  │
│ │      📍 Tunis Centre-Ville │  │
│ │      💰 650 DT  👥 1/3     │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ [📷] Studio meublé Ariana  │  │
│ │      📍 Ariana             │  │
│ │      💰 450 DT  👥 0/1     │  │
│ └────────────────────────────┘  │
│ ┌────────────────────────────┐  │
│ │ [📷] Chambre T4 La Marsa   │  │
│ │      📍 La Marsa           │  │
│ │      💰 380 DT  👥 2/4     │  │
│ └────────────────────────────┘  │
└──────────────────────────────────┘
```

---

## 💡 Commandes rapides

```bash
# 1. Démarrer backend
cd ~/Documents/uyosra/[BACKEND_FOLDER] && npm start

# 2. Dans un autre Terminal, tester
curl http://192.168.137.185:3007/annonces

# 3. Ajouter des logements
cd ~/Documents/uyosra/DarnaFrontIOS-Gestion_User
./ajouter_logements_test.sh

# 4. Dans Xcode, relancer l'app (⌘R)
```

---

**C'est tout ! Votre liste de logements devrait maintenant fonctionner ! 🚀**

Si vous avez encore des problèmes, consultez le fichier **DEPANNAGE_LOGEMENTS.md** pour plus de détails.
