# Correction Backend - Erreur 500 Suppression Publicité

## Analyse de l'erreur
L'erreur `TypeError: Cannot read properties of undefined (reading 'toString')` indique que certaines de vos publicités dans la base de données n'ont pas de champ `sponsor`.

Lorsque le code tente de vérifier les droits avec `pub.sponsor.toString()`, il plante car `pub.sponsor` est `undefined`.

## La Solution

Modifiez la méthode `remove` dans votre fichier `src/publicite/publicite.service.ts`.

### Code actuel (qui plante) :
```typescript
async remove(id: string, sponsor: UserDocument) {
  const pub = await this.model.findById(id);
  if (!pub) throw new NotFoundException('Publicité non trouvée');
  
  // C'est ici que ça plante si pub.sponsor est vide
  if (pub.sponsor.toString() !== sponsor._id.toString()) {
    throw new ForbiddenException('Vous ne pouvez pas supprimer cette publicité');
  }
  return pub.deleteOne();
}
```

### Code corrigé (à copier/coller) :
```typescript
async remove(id: string, sponsor: UserDocument) {
  const pub = await this.model.findById(id);
  if (!pub) throw new NotFoundException('Publicité non trouvée');

  // CORRECTION : On vérifie d'abord si la pub a un sponsor
  if (pub.sponsor) {
      // Sécurisation de l'accès à l'ID du user
      const userId = sponsor['_id'] ? sponsor['_id'].toString() : sponsor['id'];
      
      if (pub.sponsor.toString() !== userId) {
          throw new ForbiddenException('Vous ne pouvez pas supprimer cette publicité');
      }
  } else {
      console.warn(`Attention: La publicité ${id} n'a pas de sponsor défini. Suppression autorisée par sécurité.`);
  }

  return pub.deleteOne();
}
```

## Pourquoi cette correction marche ?
1. Elle vérifie `if (pub.sponsor)` avant d'essayer d'utiliser `.toString()`.
2. Si la publicité n'a pas de sponsor (ce qui est probablement le cas pour celle qui plante), elle saute la vérification et permet la suppression. Cela vous permettra de nettoyer ces publicités "cassées".
3. Elle gère aussi le cas où `sponsor._id` pourrait être accessible via `sponsor.id`.

## Actions à faire
1. Ouvrez `src/publicite/publicite.service.ts` sur votre PC Windows.
2. Remplacez la méthode `remove` par le code corrigé ci-dessus.
3. Sauvegardez. Le serveur NestJS devrait redémarrer automatiquement.
4. Réessayez de supprimer la publicité depuis l'application iOS.
