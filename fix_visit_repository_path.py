#!/usr/bin/env python3
import re
import shutil

# Fichier du projet
project_file = "DarnaApp.xcodeproj/project.pbxproj"
backup_file = "DarnaApp.xcodeproj/project.pbxproj.backup2"

print("🔧 Correction du chemin de VisitRepository.swift...")

# Sauvegarder
shutil.copy(project_file, backup_file)
print(f"📋 Sauvegarde créée: {backup_file}")

# Lire le fichier
with open(project_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Chercher et corriger le mauvais chemin
# Le problème est probablement un sourceTree incorrect ou un path absolu
corrections = 0

# Pattern 1: Chercher les lignes avec VisitRepository.swift
lines = content.split('\n')
new_lines = []

for line in lines:
    if 'VisitRepository.swift' in line:
        print(f"📍 Ligne trouvée: {line.strip()}")
        
        # Si le chemin est incorrect (contient DarnaApp/VisitRepository.swift au lieu de Repository/VisitRepository.swift)
        if 'DarnaApp/VisitRepository.swift' in line and 'Repository' not in line:
            # Corriger le chemin
            new_line = line.replace('DarnaApp/VisitRepository.swift', 'Repository/VisitRepository.swift')
            print(f"✅ Corrigé en: {new_line.strip()}")
            new_lines.append(new_line)
            corrections += 1
        else:
            new_lines.append(line)
    else:
        new_lines.append(line)

content = '\n'.join(new_lines)

# Sauvegarder
if corrections > 0:
    with open(project_file, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"\n✨ {corrections} correction(s) appliquée(s)!")
else:
    print("\n⚠️  Aucune correction nécessaire avec ce pattern")
    print("Recherche d'autres patterns...")
    
    # Essayer de trouver toutes les références à VisitRepository
    with open(project_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    matches = re.findall(r'.*VisitRepository\.swift.*', content)
    print(f"\n📝 Toutes les lignes contenant VisitRepository.swift:")
    for i, match in enumerate(matches, 1):
        print(f"{i}. {match.strip()}")

print("\n🚨 IMPORTANT:")
print("   1. Fermez Xcode COMPLÈTEMENT (Cmd+Q)")
print("   2. Rouvrez DarnaApp.xcodeproj")
print("   3. Nettoyez: Cmd+Shift+K")
print("   4. Compilez: Cmd+B")
