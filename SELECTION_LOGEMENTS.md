# Sélection de logements dans l'app iOS

## Vue d'ensemble

L'application iOS dispose maintenant d'une interface améliorée pour la **sélection de logements** lorsqu'un client souhaite réserver une visite. Cette fonctionnalité offre une expérience visuelle riche similaire à l'application Android.

## Fonctionnalités

### 1. Sélection visuelle de logements
- **Liste déroulante interactive** : Affichage/masquage animé de la liste
- **Miniatures d'images** : Aperçu visuel de chaque propriété
- **Informations détaillées** : Titre, localisation, prix, et occupation
- **Indicateur de sélection** : Icône checkmark pour le logement sélectionné
- **Design moderne** : Interface card-based cohérente avec iOS

### 2. Formulaire de réservation amélioré
- **Section de sélection de logement** avec composant `PropertySelectionView`
- **Date et heure** : Sélecteurs intégrés pour planifier la visite
- **Informations de contact** : Numéro de téléphone et notes optionnelles
- **Bouton de confirmation** : Design moderne avec feedback visuel

## Utilisation dans l'app

### Pour un client :

1. **Accéder à la réservation de visite**
   - Naviguez vers "Réserver une visite" depuis l'écran principal

2. **Sélectionner un logement**
   - Tapez sur le bouton de sélection de logement
   - Parcourez la liste des logements disponibles
   - Tapez sur le logement de votre choix
   - La liste se ferme automatiquement après sélection

3. **Compléter la réservation**
   - Choisissez une date et une heure pour la visite
   - Entrez votre numéro de téléphone
   - Ajoutez des notes si nécessaire (optionnel)
   - Appuyez sur "Confirmer la visite"

## Ajouter des logements de test

Pour tester la fonctionnalité de sélection, vous pouvez ajouter des logements via l'API backend.

### Méthode 1 : Via curl (Terminal macOS)

```bash
# Définir l'URL du backend
BACKEND_URL="http://192.168.137.185:3007"

# Obtenir un token d'authentification (remplacez email/password)
TOKEN=$(curl -X POST "$BACKEND_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"votremail@example.com","password":"votrepassword"}' \
  | jq -r '.access_token')

# Ajouter un logement
curl -X POST "$BACKEND_URL/annonces" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Appartement 3 pièces",
    "description": "Appartement spacieux en centre ville, idéal pour colocation étudiante",
    "price": 650.0,
    "location": "Tunis Centre",
    "type": "Appartement",
    "nbrCollocateurMax": 3,
    "nbrCollocateurActuel": 1,
    "startDate": "2025-01-01T00:00:00.000Z",
    "endDate": "2025-12-31T23:59:59.000Z",
    "images": ["https://example.com/image1.jpg"]
  }'
```

### Méthode 2 : Via Postman/Insomnia

1. **Authentification**
   - POST `http://192.168.137.185:3007/auth/login`
   - Body : `{"email":"user@example.com","password":"password"}`
   - Récupérez le `access_token`

2. **Créer une annonce**
   - POST `http://192.168.137.185:3007/annonces`
   - Header : `Authorization: Bearer [votre_token]`
   - Body (exemple) :
   ```json
   {
     "title": "Studio meublé",
     "description": "Studio moderne proche des universités",
     "price": 450.0,
     "location": "Ariana",
     "type": "Studio",
     "nbrCollocateurMax": 1,
     "nbrCollocateurActuel": 0,
     "startDate": "2025-01-01T00:00:00.000Z",
     "endDate": "2025-12-31T23:59:59.000Z",
     "images": []
   }
   ```

### Méthode 3 : Script Node.js

Créez un fichier `add-properties-ios.js` :

```javascript
const logements = [
  {
    title: "Appartement 3 pièces Centre Ville",
    description: "Spacieux appartement en plein centre, idéal pour colocation",
    price: 650,
    location: "Tunis Centre",
    type: "Appartement",
    nbrCollocateurMax: 3,
    nbrCollocateurActuel: 1,
    startDate: "2025-01-01T00:00:00.000Z",
    endDate: "2025-12-31T23:59:59.000Z",
    images: []
  },
  {
    title: "Studio meublé",
    description: "Studio entièrement équipé, proche transports",
    price: 450,
    location: "Ariana",
    type: "Studio",
    nbrCollocateurMax: 1,
    nbrCollocateurActuel: 0,
    startDate: "2025-01-01T00:00:00.000Z",
    endDate: "2025-12-31T23:59:59.000Z",
    images: []
  },
  {
    title: "Chambre dans T4",
    description: "Chambre dans un grand appartement partagé",
    price: 380,
    location: "La Marsa",
    type: "Chambre",
    nbrCollocateurMax: 4,
    nbrCollocateurActuel: 2,
    startDate: "2025-01-01T00:00:00.000Z",
    endDate: "2025-12-31T23:59:59.000Z",
    images: []
  }
];

const BACKEND_URL = process.env.BACKEND_URL || "http://192.168.137.185:3007";

async function login() {
  const response = await fetch(`${BACKEND_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: "user@example.com",  // Changez ces valeurs
      password: "password"
    })
  });
  const data = await response.json();
  return data.access_token;
}

async function createProperty(token, property) {
  const response = await fetch(`${BACKEND_URL}/annonces`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(property)
  });
  return await response.json();
}

async function main() {
  console.log('🔐 Connexion au backend...');
  const token = await login();
  
  console.log('✅ Connecté ! Ajout des logements...\n');
  
  for (const logement of logements) {
    console.log(`➕ Ajout de: ${logement.title}`);
    try {
      const result = await createProperty(token, logement);
      console.log(`   ✅ Créé avec ID: ${result._id}\n`);
    } catch (error) {
      console.log(`   ❌ Erreur: ${error.message}\n`);
    }
  }
  
  console.log('✨ Terminé !');
}

main().catch(console.error);
```

Exécutez avec : `node add-properties-ios.js`

## Architecture technique

### Composants clés

1. **PropertySelectionView** (`PropertySelectionView.swift`)
   - Composant réutilisable de sélection de propriétés
   - Interface expandable/collapsible
   - Affichage riche avec images et métadonnées

2. **VisitReservationView** (`VisitReservationView.swift`)
   - Vue principale pour réserver une visite
   - Intègre PropertySelectionView
   - Gère le formulaire complet de réservation

3. **PropertyService** (`PropertyService.swift`)
   - Service réseau pour récupérer les annonces
   - Endpoint : `GET /annonces`

### Flux de données

```
PropertyService.fetchProperties()
         ↓
   [Property] array
         ↓
PropertySelectionView
         ↓
   selectedPropertyId ↔ ViewModel
         ↓
 Submit reservation
```

## Différences avec Android

| Fonctionnalité | Android | iOS |
|----------------|---------|-----|
| Composant | ExposedDropdownMenu | PropertySelectionView |
| Style | Material Design | iOS Native |
| Animation | Material motion | SwiftUI animations |
| Layout | Jetpack Compose | SwiftUI |

## Notes de configuration

### Adresse IP du backend

L'URL du backend est configurée dans `DarnaApp/Resources/ServerConfig.swift` :

```swift
enum ServerConfig {
    private static let host = "192.168.137.185"  // ← Modifier ici
    private static let port = 3007
    
    static var baseURL: String {
        "http://\(host):\(port)"
    }
}
```

**Important** : Si vous changez de réseau WiFi, mettez à jour cette IP.

## Dépannage

### Aucun logement ne s'affiche

1. Vérifiez que le backend est accessible :
   ```bash
   curl http://192.168.137.185:3007/annonces
   ```

2. Vérifiez l'adresse IP dans `ServerConfig.swift`

3. Consultez les logs Xcode pour les erreurs réseau

### Erreur "Cannot find PropertySelectionView"

Assurez-vous que le fichier `PropertySelectionView.swift` est :
- Présent dans le projet
- Ajouté au target de build
- Correctement importé

Pour ajouter au projet :
1. Ouvrez Xcode
2. Clic droit sur le dossier `Views/Components`
3. Add Files to "DarnaApp"
4. Sélectionnez `PropertySelectionView.swift`
5. Cochez "Copy items if needed" et le target approprié

## Évolutions futures

- [ ] Filtres de recherche (prix, localisation, type)
- [ ] Favoris sur les logements
- [ ] Vue carte pour localisation géographique
- [ ] Images multiples avec carousel
- [ ] Disponibilité en temps réel

---

Pour toute question, référez-vous à la documentation Android (`DarnaFrontAndroid-main/ajouter_logements.md`) ou consultez le code source.
