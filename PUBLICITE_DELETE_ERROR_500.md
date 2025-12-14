# Résolution du problème HTTP 500 lors de la suppression de publicité

## Problème
Erreur HTTP 500 lors de la tentative de suppression d'une publicité.

## Cause probable
L'erreur HTTP 500 (Internal Server Error) provient du serveur backend. Les causes les plus courantes sont :

1. **Contraintes de base de données** : La publicité est peut-être liée à d'autres données (commandes, utilisateurs, etc.) et le serveur ne peut pas la supprimer à cause de contraintes de clé étrangère.

2. **Erreur dans le code backend** : Le serveur rencontre une exception non gérée lors du traitement de la requête DELETE.

3. **Permissions insuffisantes** : L'utilisateur n'a peut-être pas les droits nécessaires pour supprimer cette publicité.

## Solutions appliquées côté iOS

### 1. Amélioration des logs
- Ajout de logs détaillés dans `PubliciteService.swift` pour afficher le corps de la réponse d'erreur du serveur
- Cela permet de voir exactement quel message d'erreur le serveur renvoie

### 2. Amélioration des messages d'erreur
- Messages d'erreur plus explicites pour l'utilisateur :
  - HTTP 500 : "Erreur serveur (500): Le serveur a rencontré une erreur. Vérifiez que la publicité n'est pas liée à d'autres données."
  - HTTP 404 : "Publicité introuvable (404)"
  - HTTP 401 : "Non autorisé (401): Veuillez vous reconnecter"

## Actions à effectuer côté backend

Pour résoudre définitivement le problème, vous devez vérifier le code backend :

### 1. Vérifier les logs du serveur
Consultez les logs du serveur Node.js pour voir l'erreur exacte :
```bash
# Si vous utilisez PM2
pm2 logs

# Si vous lancez directement avec node
# Vérifiez la console où le serveur tourne
```

### 2. Vérifier la route DELETE
Dans votre backend (probablement dans `routes/publicites.js` ou similaire), vérifiez :

```javascript
// Exemple de ce qui pourrait causer l'erreur
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Vérifier que la publicité existe
    const publicite = await Publicite.findById(id);
    if (!publicite) {
      return res.status(404).json({ message: 'Publicité introuvable' });
    }
    
    // Vérifier les permissions
    if (publicite.sponsorId !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Non autorisé' });
    }
    
    // Supprimer la publicité
    await Publicite.findByIdAndDelete(id);
    
    res.status(200).json({ message: 'Publicité supprimée' });
  } catch (error) {
    console.error('Erreur lors de la suppression:', error);
    res.status(500).json({ 
      message: 'Erreur serveur', 
      error: error.message // IMPORTANT: Afficher l'erreur pour debug
    });
  }
});
```

### 3. Vérifier les contraintes de base de données
Si vous utilisez MongoDB avec Mongoose, vérifiez les hooks `pre('remove')` ou les références :

```javascript
// Si d'autres collections référencent cette publicité
publiciteSchema.pre('remove', async function(next) {
  try {
    // Supprimer les références dans d'autres collections
    await Order.deleteMany({ publiciteId: this._id });
    await UserFavorite.deleteMany({ publiciteId: this._id });
    next();
  } catch (error) {
    next(error);
  }
});
```

### 4. Solution temporaire : Soft Delete
Au lieu de supprimer physiquement la publicité, vous pouvez la marquer comme supprimée :

```javascript
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    await Publicite.findByIdAndUpdate(id, { 
      isDeleted: true,
      deletedAt: new Date()
    });
    
    res.status(200).json({ message: 'Publicité supprimée' });
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
});
```

## Test après modifications

1. **Relancez l'application iOS**
2. **Tentez de supprimer une publicité**
3. **Vérifiez les logs dans Xcode** :
   - Ouvrez la console (⌘ + Shift + Y)
   - Cherchez les messages commençant par "🌐 DELETE" et "❌ Erreur serveur DELETE"
   - Le message d'erreur du serveur devrait maintenant s'afficher

4. **Corrigez le backend** en fonction de l'erreur affichée

## Fichiers modifiés

- ✅ `/DarnaApp/Network/PubliciteService.swift` - Ajout de logs détaillés
- ✅ `/DarnaApp/ViewModels/PubliciteViewModel.swift` - Messages d'erreur améliorés

## Prochaines étapes

1. Lancez l'app et tentez de supprimer une publicité
2. Notez le message d'erreur exact affiché dans les logs Xcode
3. Partagez ce message pour que je puisse vous aider à corriger le backend
