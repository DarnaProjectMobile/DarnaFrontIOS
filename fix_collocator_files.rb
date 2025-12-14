#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'DarnaApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Trouver le groupe Views/Screens
views_group = project.main_group['DarnaApp']['Views']['Screens']

# Fichiers à ajouter (chemins relatifs au groupe)
files_to_add = [
  'CollocatorDashboardView.swift',
  'CollocatorVisitsView.swift',
  'CollocatorReviewsView.swift'
]

# Trouver la target DarnaApp
target = project.targets.find { |t| t.name == 'DarnaApp' }

files_to_add.each do |file_name|
  # Vérifier si le fichier existe déjà dans le groupe
  existing_file = views_group.files.find { |f| f.path == file_name }
  
  if existing_file
    # Supprimer l'ancienne référence
    existing_file.remove_from_project
    puts "🗑️  Supprimé ancienne référence: #{file_name}"
  end
  
  # Ajouter le fichier au groupe avec le bon chemin
  file_ref = views_group.new_reference(file_name)
  
  # Ajouter le fichier à la phase de compilation
  target.add_file_references([file_ref])
  
  puts "✅ Ajouté: #{file_name}"
end

# Sauvegarder le projet
project.save

puts "\n🎉 Fichiers ajoutés au projet Xcode avec succès!"
