# Configuration Backend - Mise à jour IP

## ✅ Modification effectuée

**Date** : 3 décembre 2025, 11:25  
**Fichier modifié** : `DarnaApp/Resources/ServerConfig.swift`

## 📡 Nouvelle configuration

```swift
private static let host = "192.168.137.223"
private static let port = 3007
```

**URL complète du backend** : `http://192.168.137.223:3007`

## 🔍 Vérifications à effectuer

Avant de lancer l'application, assurez-vous que :

1. ✅ **Le serveur backend est démarré** sur la machine `192.168.137.223`
2. ✅ **Le port 3007 est ouvert** et accessible
3. ✅ **Votre appareil/simulateur peut accéder** au réseau `192.168.137.x`
4. ✅ **Le serveur Nest répond** aux requêtes HTTP

## 🧪 Test de connexion

Vous pouvez tester la connexion au backend avec cette commande :

```bash
curl http://192.168.137.223:3007/health
```

Ou pour tester un endpoint spécifique (exemple : logements) :

```bash
curl http://192.168.137.223:3007/logements
```

## 📱 Endpoints utilisés par l'application

L'application se connectera automatiquement aux endpoints suivants :

- **Authentification** : `http://192.168.137.223:3007/auth/*`
- **Logements** : `http://192.168.137.223:3007/logements/*`
- **Visites** : `http://192.168.137.223:3007/visites/*`
- **Utilisateurs** : `http://192.168.137.223:3007/users/*`
- **Avis** : `http://192.168.137.223:3007/reviews/*`

## 🔧 Dépannage

### Si la connexion échoue :

1. **Vérifiez que le serveur est accessible** :
   ```bash
   ping 192.168.137.223
   ```

2. **Vérifiez que le port est ouvert** :
   ```bash
   nc -zv 192.168.137.223 3007
   ```

3. **Consultez les logs du serveur** pour voir les requêtes entrantes

4. **Vérifiez le firewall** de la machine hébergeant le backend

### Erreurs courantes :

- **"Could not connect to the server"** → Le serveur n'est pas démarré ou l'IP est incorrecte
- **"Connection timeout"** → Problème réseau ou firewall bloquant
- **"404 Not Found"** → L'endpoint n'existe pas sur le serveur
- **"500 Internal Server Error"** → Erreur côté serveur, consultez les logs backend

## 📝 Notes

- Cette configuration utilise **HTTP** (non sécurisé). Pour la production, utilisez **HTTPS**
- L'adresse IP `192.168.137.223` est une adresse **locale/privée**
- Assurez-vous que votre appareil iOS et le serveur sont sur le **même réseau**

## 🔄 Pour changer l'IP à nouveau

Modifiez simplement la ligne 12 du fichier `ServerConfig.swift` :

```swift
private static let host = "NOUVELLE_IP_ICI"
```

---

**Configuration appliquée avec succès ! 🎉**
