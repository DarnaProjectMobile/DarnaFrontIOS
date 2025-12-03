#!/bin/bash

# Script pour ajouter les nouveaux fichiers au projet Xcode

echo "📁 Vérification des fichiers..."

PROJECT_DIR="/Users/appleesprit/Documents/uyosra/DarnaFrontIOS-Gestion_User"
FILE1="$PROJECT_DIR/DarnaApp/Views/Components/PropertySelectionView.swift"
FILE2="$PROJECT_DIR/DarnaApp/Models/Property+Init.swift"

echo "🔨 Pour ajouter ces fichiers au projet Xcode :"
echo ""
echo "1. Ouvrez DarnaApp.xcodeproj dans Xcode"
echo "2. Clic droit sur le dossier 'Views/Components' -> 'Add Files...'"
echo "   - Sélectionnez: PropertySelectionView.swift"
echo ""
echo "3. Clic droit sur le dossier 'Models' -> 'Add Files...'"
echo "   - Sélectionnez: Property+Init.swift"
echo ""
echo "⚠️ IMPORTANT : Assurez-vous de cocher 'Copy items if needed' et le target 'DarnaApp'"
echo ""
echo "✨ Une fois ajoutés, rebuild le projet (Cmd+B)"
