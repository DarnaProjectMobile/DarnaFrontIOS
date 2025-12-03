#!/bin/bash

# Script pour ajouter PropertySelectionView.swift au projet Xcode
# Ce fichier doit être ajouté manuellement via Xcode ou via ce script

echo "📁 Vérification des fichiers..."

PROJECT_DIR="/Users/appleesprit/Documents/uyosra/DarnaFrontIOS-Gestion_User"
NEW_FILE="$PROJECT_DIR/DarnaApp/Views/Components/PropertySelectionView.swift"

if [ -f "$NEW_FILE" ]; then
    echo "✅ PropertySelectionView.swift existe"
else
    echo "❌ PropertySelectionView.swift n'existe pas"
    exit 1
fi

echo ""
echo "🔨 Pour ajouter ce fichier au projet Xcode :"
echo ""
echo "1. Ouvrez DarnaApp.xcodeproj dans Xcode"
echo "2. Clic droit sur le dossier 'Views/Components' dans le Project Navigator"
echo "3. Sélectionnez 'Add Files to \"DarnaApp\"'"
echo "4. Naviguez vers : DarnaApp/Views/Components/"
echo "5. Sélectionnez PropertySelectionView.swift"
echo "6. Cochez 'Copy items if needed'"
echo "7. Assurez-vous que le target 'DarnaApp' est coché"
echo "8. Cliquez sur 'Add'"
echo ""
echo "Ou exécutez ce script pour ajouter automatiquement (risqué) :"
echo "  ruby add_file_to_xcode.rb"
echo ""
echo "✨ Une fois ajouté, rebuild le projet dans Xcode (Cmd+B)"
