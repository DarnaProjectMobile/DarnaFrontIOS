#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'DarnaApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Trouver le groupe Views/Screens
views_group = project.main_group['DarnaApp']['Views']['Screens']

# Fichiers à ajouter
files_to_add = [
  'DarnaApp/Views/Screens/CollocatorDashboardView.swift',
  'DarnaApp/Views/Screens/CollocatorVisitsView.swift',
  'DarnaApp/Views/Screens/CollocatorReviewsView.swift'
]

# Trouver la target DarnaApp
target = project.targets.find { |t| t.name == 'DarnaApp' }

files_to_add.each do |file_path|
  file_name = File.basename(file_path)
  
  # Vérifier si le fichier existe déjà dans le groupe
  existing_file = views_group.files.find { |f| f.path == file_name }
  
  unless existing_file
    # Ajouter le fichier au groupe
    file_ref = views_group.new_reference(file_path)
    
    # Ajouter le fichier à la phase de compilation
    target.add_file_references([file_ref])
    
    puts "✅ Ajouté: #{file_name}"
  else
    puts "⚠️  Déjà présent: #{file_name}"
  end
end

# Sauvegarder le projet
project.save

puts "\n🎉 Fichiers ajoutés au projet Xcode avec succès!"
