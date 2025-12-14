#!/usr/bin/env ruby
require 'xcodeproj'

# Ouvrir le projet
project_path = 'DarnaApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Trouver la target principale
main_target = project.targets.first

# Trouver le groupe DarnaApp
main_group = project.main_group.find_subpath('DarnaApp', true)

# Fichiers à ajouter avec leurs chemins relatifs
files_to_add = [
  # Models
  { path: 'DarnaApp/Models/Visit.swift', group_path: 'Models' },
  
  # Network
  { path: 'DarnaApp/Network/VisitAPIService.swift', group_path: 'Network' },
  
  # Repository
  { path: 'DarnaApp/Repository/VisitRepository.swift', group_path: 'Repository' },
  
  # ViewModels
  { path: 'DarnaApp/ViewModels/VisitViewModel.swift', group_path: 'ViewModels' },
  
  # Views/Components
  { path: 'DarnaApp/Views/Components/VisitCardView.swift', group_path: 'Views/Components' },
  
  # Views/Screens
  { path: 'DarnaApp/Views/Screens/CollocatorVisitsView.swift', group_path: 'Views/Screens' },
  { path: 'DarnaApp/Views/Screens/VisitEditSheet.swift', group_path: 'Views/Screens' },
  { path: 'DarnaApp/Views/Screens/VisitManagementView.swift', group_path: 'Views/Screens' },
  { path: 'DarnaApp/Views/Screens/VisitReservationView.swift', group_path: 'Views/Screens' },
  { path: 'DarnaApp/Views/Screens/VisitReviewSheet.swift', group_path: 'Views/Screens' }
]

puts "🚀 Ajout des fichiers de gestion des visites au projet Xcode..."

files_to_add.each do |file_info|
  file_path = file_info[:path]
  group_path = file_info[:group_path]
  
  # Vérifier si le fichier existe
  unless File.exist?(file_path)
    puts "⚠️  Fichier non trouvé: #{file_path}"
    next
  end
  
  # Trouver ou créer le groupe
  group = main_group.find_subpath(group_path, true)
  
  # Vérifier si le fichier est déjà dans le projet
  existing_file = group.files.find { |f| f.path == File.basename(file_path) }
  
  if existing_file
    puts "⏭️  Fichier déjà présent: #{file_path}"
    # Supprimer l'ancienne référence
    existing_file.remove_from_project
  end
  
  # Ajouter le fichier au groupe
  file_ref = group.new_reference(file_path)
  
  # Ajouter le fichier à la phase de compilation
  main_target.add_file_references([file_ref])
  
  puts "✅ Ajouté: #{file_path}"
end

# Sauvegarder le projet
project.save

puts "\n✨ Intégration terminée avec succès!"
puts "📝 Total: #{files_to_add.length} fichiers traités"
puts "\n⚠️  IMPORTANT: Veuillez maintenant:"
puts "   1. Ouvrir le projet dans Xcode"
puts "   2. Nettoyer le build (Cmd+Shift+K)"
puts "   3. Compiler le projet (Cmd+B)"
