#!/usr/bin/env python3
import re
import shutil
from pathlib import Path

# Faire une sauvegarde
project_file = "DarnaApp.xcodeproj/project.pbxproj"
backup_file = "DarnaApp.xcodeproj/project.pbxproj.backup"

print("🔧 Correction des chemins de fichiers dans project.pbxproj...")
print(f"📋 Sauvegarde: {backup_file}")

# Sauvegarder
shutil.copy(project_file, backup_file)

# Lire le fichier
with open(project_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Corrections à appliquer
corrections = {
    'path = DarnaApp/Models/Visit.swift': 'path = Visit.swift',
    'path = DarnaApp/Network/VisitAPIService.swift': 'path = VisitAPIService.swift',
    'path = DarnaApp/Repository/VisitRepository.swift': 'path = VisitRepository.swift',
    'path = DarnaApp/ViewModels/VisitViewModel.swift': 'path = VisitViewModel.swift',
    'path = DarnaApp/Views/Components/VisitCardView.swift': 'path = VisitCardView.swift',
    'path = DarnaApp/Views/Screens/CollocatorVisitsView.swift': 'path = CollocatorVisitsView.swift',
    'path = DarnaApp/Views/Screens/VisitEditSheet.swift': 'path = VisitEditSheet.swift',
    'path = DarnaApp/Views/Screens/VisitManagementView.swift': 'path = VisitManagementView.swift',
    'path = DarnaApp/Views/Screens/VisitReservationView.swift': 'path = VisitReservationView.swift',
    'path = DarnaApp/Views/Screens/VisitReviewSheet.swift': 'path = VisitReviewSheet.swift',
    'path = DarnaApp/Resources/ServerConfig.swift': 'path = ServerConfig.swift',
}

# Appliquer les corrections
original_content = content
for old, new in corrections.items():
    if old in content:
        content = content.replace(old, new)
        print(f"✅ Corrigé: {old} → {new}")

# Sauvegarder
if content != original_content:
    with open(project_file, 'w', encoding='utf-8') as f:
        f.write(content)
    print("\n✨ Corrections appliquées avec succès!")
else:
    print("\n⚠️  Aucune correction nécessaire")

print("\n🚨 IMPORTANT:")
print("   1. Fermez Xcode COMPLÈTEMENT (Cmd+Q)")
print("   2. Rouvrez DarnaApp.xcodeproj")
print("   3. Nettoyez: Cmd+Shift+K")
print("   4. Compilez: Cmd+B")
