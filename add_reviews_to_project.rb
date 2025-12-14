#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'DarnaApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Trouver le groupe Components
components_group = project.main_group['DarnaApp']['Views']['Components']

# Ajouter ReviewsListView.swift
reviews_file = 'DarnaApp/Views/Components/ReviewsListView.swift'
if !components_group.files.any? { |f| f.path == 'ReviewsListView.swift' }
  file_ref = components_group.new_file(reviews_file)
  
  # Ajouter aux targets
  target = project.targets.first
  target.add_file_references([file_ref])
  
  puts "✅ ReviewsListView.swift ajouté au projet"
else
  puts "⚠️ ReviewsListView.swift déjà dans le projet"
end

project.save
puts "✅ Projet sauvegardé"
