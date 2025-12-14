#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'DarnaApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Trouver le groupe Views/Screens
views_group = project.main_group['DarnaApp']['Views']['Screens']

# Fichiers à nettoyer
files_to_clean = [
  'CollocatorDashboardView.swift',
  'CollocatorVisitsView.swift',
  'CollocatorReviewsView.swift'
]

# Trouver la target DarnaApp
target = project.targets.find { |t| t.name == 'DarnaApp' }

files_to_clean.each do |file_name|
  # Trouver toutes les références au fichier
  all_refs = views_group.files.select { |f| f.path == file_name || f.display_name == file_name }
  
  puts "📁 #{file_name}: trouvé #{all_refs.count} références"
  
  # Supprimer toutes les références
  all_refs.each do |ref|
    ref.remove_from_project
    puts "   🗑️  Supprimé: #{ref.path}"
  end
end

# Sauvegarder
project.save
puts "\n✅ Nettoyage terminé!"

# Maintenant rajouter les fichiers proprement
puts "\n📥 Ajout des fichiers..."

files_to_clean.each do |file_name|
  # Ajouter le fichier au groupe
  file_ref = views_group.new_reference(file_name)
  
  # Ajouter le fichier à la phase de compilation
  target.add_file_references([file_ref])
  
  puts "✅ Ajouté: #{file_name}"
end

# Sauvegarder le projet
project.save

puts "\n🎉 Fichiers ajoutés au projet Xcode avec succès!"
