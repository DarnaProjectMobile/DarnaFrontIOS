# 🔧 Dépannage - Erreurs de Compilation

## Date: 2025-12-05 13:11

## ✅ Vérifications Effectuées

- ✅ Tous les fichiers Visit sont présents dans le projet
- ✅ Tous les fichiers sont dans la phase de compilation
- ✅ La structure du projet est correcte

## 🔍 Erreurs Possibles et Solutions

### 1. Erreur de Signature (NORMALE)
**Erreur**: "Signing for DarnaApp requires a development team"

**Solution**:
1. Ouvrir le projet dans Xcode
2. Sélectionner le projet DarnaApp dans le navigateur
3. Sélectionner la target DarnaApp
4. Aller dans Signing & Capabilities
5. Sélectionner votre équipe de développement

### 2. Erreur "Cannot find type 'Visit' in scope"
**Cause**: Le fichier Visit.swift n'est pas compilé en premier

**Solution**:
1. Dans Xcode, aller dans Build Phases
2. Vérifier que Visit.swift est dans "Compile Sources"
3. Déplacer Visit.swift en HAUT de la liste (glisser-déposer)
4. Nettoyer: Cmd+Shift+K
5. Compiler: Cmd+B

### 3. Erreur "Cannot find 'ServerConfig' in scope"
**Cause**: Les fichiers de visite utilisent ServerConfig qui doit exister

**Solution**:
Vérifier que ServerConfig.swift existe et contient:
```swift
struct ServerConfig {
    static let baseURL = "http://VOTRE_IP:3000"
}
```

### 4. Erreur "Cannot find 'PropertyViewModel' in scope"
**Cause**: VisitReservationView utilise PropertyViewModel

**Solution**:
Vérifier que PropertyViewModel.swift existe dans le projet

### 5. Erreur de Build Failed sans détails
**Solution**:
1. Nettoyer le build folder: Cmd+Shift+Option+K
2. Supprimer DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/DarnaApp-*
   ```
3. Relancer Xcode
4. Compiler à nouveau

## 📝 Pour Obtenir Plus d'Aide

**Merci de me fournir**:
1. Le message d'erreur EXACT de Xcode
2. Le nom du fichier où l'erreur se produit
3. Le numéro de ligne de l'erreur
4. Une capture d'écran si possible

## 🔧 Commandes de Diagnostic

### Vérifier les fichiers dans le projet
```bash
cd "/Users/appleesprit/Downloads/yosra abdelkader ios/DarnaApp finam"
find DarnaApp -name "*Visit*.swift" -type f
```

### Vérifier ServerConfig
```bash
find DarnaApp -name "ServerConfig.swift" -type f
cat DarnaApp/Config/ServerConfig.swift 2>/dev/null || echo "ServerConfig.swift non trouvé"
```

### Vérifier PropertyViewModel
```bash
find DarnaApp -name "PropertyViewModel.swift" -type f
```

### Nettoyer et Recompiler
```bash
xcodebuild -project DarnaApp.xcodeproj -scheme DarnaApp clean
```

## 📞 Prochaines Étapes

1. **Ouvrez Xcode**
2. **Essayez de compiler** (Cmd+B)
3. **Copiez l'erreur exacte** que vous voyez
4. **Envoyez-moi l'erreur** pour que je puisse vous aider

Je suis prêt à vous aider dès que vous me donnerez les détails de l'erreur! 🚀
