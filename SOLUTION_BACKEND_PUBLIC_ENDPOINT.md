# 🔧 SOLUTION: Rendre l'Endpoint /annonces Public dans le Backend

## 🎯 Problème
L'endpoint `/annonces` du backend NestJS exige une authentification (retourne 401 Unauthorized), ce qui empêche l'application iOS de charger les logements pour les utilisateurs non connectés.

## ✅ Solution Backend (NestJS)

### Étape 1: Localiser le Controller des Annonces
Trouvez le fichier du controller des annonces, probablement:
```
backend/src/annonces/annonces.controller.ts
```

### Étape 2: Rendre la Méthode GET Publique

**AVANT** (avec authentification requise):
```typescript
import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('annonces')
@UseGuards(JwtAuthGuard)  // ← Ceci force l'auth sur TOUTES les routes
export class AnnoncesController {
  
  @Get()
  async findAll() {
    return this.annoncesService.findAll();
  }
  
  // ... autres méthodes
}
```

**APRÈS** (lecture publique, écriture protégée):
```typescript
import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Public } from '../auth/public.decorator'; // ← Importer le décorateur Public

@Controller('annonces')
@UseGuards(JwtAuthGuard)  // Auth par défaut sur toutes les routes
export class AnnoncesController {
  
  @Get()
  @Public()  // ← Ajouter ce décorateur pour rendre cette route publique
  async findAll() {
    return this.annoncesService.findAll();
  }
  
  @Get(':id')
  @Public()  // ← Aussi public pour voir les détails d'une annonce
  async findOne(@Param('id') id: string) {
    return this.annoncesService.findOne(id);
  }
  
  @Post()
  // ← Pas de @Public(), donc cette route reste protégée
  async create(@Body() createAnnonceDto: CreateAnnonceDto) {
    return this.annoncesService.create(createAnnonceDto);
  }
  
  // ... autres méthodes restent protégées
}
```

### Étape 3: Créer le Décorateur @Public() (si pas déjà existant)

Créez le fichier `backend/src/auth/public.decorator.ts`:
```typescript
import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
```

### Étape 4: Modifier le JwtAuthGuard pour Respecter @Public()

Dans `backend/src/auth/jwt-auth.guard.ts`:
```typescript
import { ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { IS_PUBLIC_KEY } from './public.decorator';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    // Vérifier si la route est marquée comme publique
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    
    // Si c'est public, autoriser l'accès sans vérifier le token
    if (isPublic) {
      return true;
    }
    
    // Sinon, vérifier le token JWT normalement
    return super.canActivate(context);
  }
}
```

### Étape 5: Redémarrer le Backend
```bash
cd backend
npm run start:dev
```

## 🧪 Test de la Solution

### Test 1: Vérifier que l'endpoint est maintenant public
```bash
curl http://192.168.137.185:3007/annonces
```

**Résultat attendu**: 
- ✅ Status 200 OK
- ✅ Liste des annonces en JSON
- ❌ PAS de message "Unauthorized"

### Test 2: Vérifier que les autres endpoints restent protégés
```bash
# Essayer de créer une annonce sans token (doit échouer)
curl -X POST http://192.168.137.185:3007/annonces \
  -H "Content-Type: application/json" \
  -d '{"title":"Test"}'
```

**Résultat attendu**: 
- ✅ Status 401 Unauthorized (c'est normal, la création doit rester protégée)

## 📱 Résultat dans l'Application iOS

Après cette modification backend, l'application iOS pourra:
1. ✅ Charger les logements **sans** que l'utilisateur soit connecté
2. ✅ Afficher la liste complète des annonces depuis le backend
3. ✅ Utiliser les données réelles au lieu du fallback de démonstration

### Logs Attendus dans Xcode
```
📡 Fetching properties from: http://192.168.137.185:3007/annonces
📊 Response status: 200
✅ Successfully fetched X properties from backend
```

## 🔐 Sécurité

Cette approche est **sécurisée** car:
- ✅ La **lecture** des annonces est publique (normal pour une marketplace)
- ✅ La **création/modification/suppression** reste protégée par authentification
- ✅ Les données sensibles des utilisateurs ne sont pas exposées
- ✅ Seules les informations publiques des annonces sont visibles

## 🎯 Endpoints Recommandés comme Publics
```typescript
@Get()           // Liste toutes les annonces
@Public()

@Get(':id')      // Détails d'une annonce
@Public()
```

## 🔒 Endpoints qui DOIVENT Rester Protégés
```typescript
@Post()          // Créer une annonce (auth requise)
@Patch(':id')    // Modifier une annonce (auth requise)
@Delete(':id')   // Supprimer une annonce (auth requise)
@Post(':id/book') // Réserver un logement (auth requise)
```

## ✅ Checklist de Vérification

- [ ] Décorateur `@Public()` créé
- [ ] `JwtAuthGuard` modifié pour respecter `@Public()`
- [ ] Route `GET /annonces` marquée comme `@Public()`
- [ ] Route `GET /annonces/:id` marquée comme `@Public()`
- [ ] Backend redémarré
- [ ] Test curl réussi (200 OK)
- [ ] Application iOS teste et charge les données

---

**Note**: Si vous n'avez pas accès au code backend, contactez le développeur backend avec ce document pour qu'il applique ces modifications.
