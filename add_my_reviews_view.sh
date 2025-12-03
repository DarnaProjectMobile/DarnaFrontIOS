#!/bin/bash

# Script pour ajouter MyReviewsView.swift au projet Xcode
# Usage: ./add_my_reviews_view.sh

set -e

PROJECT_DIR="/Users/appleesprit/Documents/uyosra/DarnaFrontIOS-Gestion_User"
PBXPROJ="$PROJECT_DIR/DarnaApp.xcodeproj/project.pbxproj"

echo "🔧 Ajout de MyReviewsView.swift au projet Xcode..."

# Vérifier que le fichier existe
if [ ! -f "$PROJECT_DIR/DarnaApp/Views/Screens/MyReviewsView.swift" ]; then
    echo "❌ Erreur: MyReviewsView.swift n'existe pas"
    exit 1
fi

# Vérifier que le projet existe
if [ ! -f "$PBXPROJ" ]; then
    echo "❌ Erreur: project.pbxproj n'existe pas"
    exit 1
fi

# Générer un UUID unique pour le fichier
FILE_UUID=$(uuidgen | tr '[:lower:]' '[:upper:]' | tr -d '-' | cut -c1-24)
BUILD_UUID=$(uuidgen | tr '[:lower:]' '[:upper:]' | tr -d '-' | cut -c1-24)

echo "📝 UUID généré pour le fichier: $FILE_UUID"
echo "📝 UUID généré pour le build: $BUILD_UUID"

# Créer une sauvegarde
cp "$PBXPROJ" "$PBXPROJ.backup_myreviews_$(date +%Y%m%d_%H%M%S)"

# Ajouter la référence du fichier dans PBXFileReference
perl -i -pe "s|(\/\* End PBXFileReference section \*\/)|		$FILE_UUID /* MyReviewsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MyReviewsView.swift; sourceTree = \"<group>\"; };\n\$1|" "$PBXPROJ"

# Ajouter le fichier au groupe Screens
perl -i -pe "s|(\/\* VisitManagementView\.swift \*\/,)|\$1\n				$FILE_UUID /* MyReviewsView.swift */,|" "$PBXPROJ"

# Ajouter le fichier à PBXBuildFile
perl -i -pe "s|(\/\* End PBXBuildFile section \*\/)|		$BUILD_UUID /* MyReviewsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $FILE_UUID /* MyReviewsView.swift */; };\n\$1|" "$PBXPROJ"

# Ajouter le fichier à PBXSourcesBuildPhase
perl -i -pe "s|(\/\* VisitManagementView\.swift in Sources \*\/,)|\$1\n				$BUILD_UUID /* MyReviewsView.swift in Sources */,|" "$PBXPROJ"

echo "✅ MyReviewsView.swift ajouté avec succès au projet !"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Ouvrez le projet dans Xcode"
echo "2. Vérifiez que MyReviewsView.swift apparaît dans Views/Screens"
echo "3. Compilez le projet pour vérifier qu'il n'y a pas d'erreurs"
echo ""
echo "💾 Une sauvegarde a été créée : $PBXPROJ.backup_myreviews_*"
