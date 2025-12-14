# Fix Backend - Suppression de Publicité (HTTP 500)

## Problème identifié
Le serveur backend renvoie une erreur 500 lors de la suppression d'une publicité.
Message : `{"statusCode":500,"message":"Internal server error"}`

## Solution

### 1. Trouver le fichier de route DELETE

Cherchez dans votre backend le fichier qui contient la route DELETE pour les publicités.

**Commande pour trouver le fichier :**
```bash
cd /path/to/your/backend
grep -r "router.delete.*publicites" .
# ou
grep -r "DELETE.*publicites" .
```

### 2. Exemple de code backend à corriger

Voici comment devrait être la route DELETE :

```javascript
// Dans routes/publicites.js ou controllers/publiciteController.js

router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    
    console.log('🗑️ Tentative de suppression de la publicité:', id);
    
    // Vérifier que la publicité existe
    const publicite = await Publicite.findById(id);
    
    if (!publicite) {
      console.log('❌ Publicité non trouvée:', id);
      return res.status(404).json({ 
        statusCode: 404,
        message: 'Publicité introuvable' 
      });
    }
    
    // Vérifier les permissions (si l'utilisateur est le sponsor ou admin)
    if (req.user.role !== 'admin' && publicite.sponsorId?.toString() !== req.user.id) {
      console.log('❌ Permission refusée pour:', req.user.id);
      return res.status(403).json({ 
        statusCode: 403,
        message: 'Non autorisé à supprimer cette publicité' 
      });
    }
    
    // Supprimer la publicité
    await Publicite.findByIdAndDelete(id);
    
    console.log('✅ Publicité supprimée:', id);
    
    res.status(200).json({ 
      statusCode: 200,
      message: 'Publicité supprimée avec succès',
      data: { id }
    });
    
  } catch (error) {
    console.error('❌ Erreur lors de la suppression:', error);
    console.error('Stack trace:', error.stack);
    
    res.status(500).json({ 
      statusCode: 500,
      message: 'Erreur serveur lors de la suppression',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});
```

### 3. Problèmes courants et solutions

#### A. Erreur de validation Mongoose

**Problème :** ID invalide
```javascript
// Ajouter une validation de l'ID
const mongoose = require('mongoose');

if (!mongoose.Types.ObjectId.isValid(id)) {
  return res.status(400).json({ 
    statusCode: 400,
    message: 'ID de publicité invalide' 
  });
}
```

#### B. Contraintes de clé étrangère

**Problème :** La publicité est référencée dans d'autres collections

**Solution 1 - Cascade Delete :**
```javascript
// Supprimer les références avant de supprimer la publicité
await Order.deleteMany({ publiciteId: id });
await UserFavorite.deleteMany({ publiciteId: id });
await Publicite.findByIdAndDelete(id);
```

**Solution 2 - Soft Delete (recommandé) :**
```javascript
// Au lieu de supprimer, marquer comme supprimé
await Publicite.findByIdAndUpdate(id, { 
  isDeleted: true,
  deletedAt: new Date()
});

// Puis dans les requêtes GET, filtrer les publicités supprimées
const publicites = await Publicite.find({ isDeleted: { $ne: true } });
```

#### C. Middleware d'authentification manquant

**Problème :** `req.user` est undefined

**Solution :**
```javascript
// Vérifier que le middleware d'authentification est bien appliqué
router.delete('/:id', authenticateToken, async (req, res) => {
  if (!req.user) {
    return res.status(401).json({ 
      statusCode: 401,
      message: 'Non authentifié' 
    });
  }
  // ... reste du code
});
```

### 4. Ajouter le schéma Soft Delete (optionnel mais recommandé)

Dans votre modèle Publicite :

```javascript
const publiciteSchema = new mongoose.Schema({
  // ... vos champs existants
  
  isDeleted: {
    type: Boolean,
    default: false
  },
  deletedAt: {
    type: Date,
    default: null
  }
}, { timestamps: true });

// Middleware pour exclure les publicités supprimées par défaut
publiciteSchema.pre(/^find/, function(next) {
  // Ne pas appliquer le filtre si on cherche explicitement les supprimés
  if (!this.getOptions().includeDeleted) {
    this.where({ isDeleted: { $ne: true } });
  }
  next();
});

module.exports = mongoose.model('Publicite', publiciteSchema);
```

### 5. Tester la correction

1. **Redémarrez votre serveur backend**
   ```bash
   # Si vous utilisez nodemon
   npm run dev
   
   # Si vous utilisez PM2
   pm2 restart all
   ```

2. **Vérifiez les logs du serveur** pendant que vous tentez de supprimer

3. **Testez depuis l'app iOS**

### 6. Debug supplémentaire

Si l'erreur persiste, ajoutez ces logs temporaires :

```javascript
router.delete('/:id', authenticateToken, async (req, res) => {
  console.log('=== DEBUG DELETE ===');
  console.log('ID reçu:', req.params.id);
  console.log('User:', req.user);
  console.log('Headers:', req.headers);
  
  try {
    const publicite = await Publicite.findById(req.params.id);
    console.log('Publicité trouvée:', publicite);
    
    // ... reste du code
  } catch (error) {
    console.log('Type d\'erreur:', error.name);
    console.log('Message d\'erreur:', error.message);
    console.log('Stack:', error.stack);
    // ...
  }
});
```

## Checklist de vérification

- [ ] La route DELETE existe et est correctement définie
- [ ] Le middleware d'authentification est appliqué
- [ ] L'ID de la publicité est valide (format MongoDB ObjectId)
- [ ] Les permissions sont vérifiées (sponsor ou admin)
- [ ] Les contraintes de base de données sont gérées
- [ ] Les logs détaillés sont activés
- [ ] Le serveur a été redémarré après les modifications

## Besoin d'aide ?

Si le problème persiste :
1. Copiez les logs complets du serveur backend
2. Partagez le code de votre route DELETE
3. Indiquez quelle base de données vous utilisez (MongoDB, PostgreSQL, etc.)
