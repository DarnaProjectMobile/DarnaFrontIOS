#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'DarnaApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Supprimer les références incorrectes
project.targets.first.source_build_phase.files.each do |build_file|
  if build_file.file_ref && build_file.file_ref.path && build_file.file_ref.path.include?('DarnaApp/Views/Components/DarnaApp')
    puts "🗑️ Suppression de: #{build_file.file_ref.path}"
    build_file.remove_from_project
  end
end

# Trouver le groupe Components
components_group = project.main_group['DarnaApp']['Views']['Components']

# Supprimer les fichiers avec mauvais chemin
components_group.files.each do |file|
  if file.path && file.path.include?('DarnaApp/Views/Components')
    puts "🗑️ Suppression du groupe: #{file.path}"
    file.remove_from_project
  end
end

# Ajouter correctement ReviewsListView.swift
if !components_group.files.any? { |f| f.path == 'ReviewsListView.swift' }
  file_ref = components_group.new_reference('ReviewsListView.swift')
  
  # Ajouter aux targets
  target = project.targets.first
  target.add_file_references([file_ref])
  
  puts "✅ ReviewsListView.swift ajouté correctement"
else
  puts "⚠️ ReviewsListView.swift déjà présent"
end

project.save
puts "✅ Projet sauvegardé"
