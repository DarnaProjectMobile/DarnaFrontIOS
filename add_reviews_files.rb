#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'DarnaApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Trouver le groupe Screens
screens_group = project.main_group['DarnaApp']['Views']['Screens']

# Fichiers à ajouter
files_to_add = [
  'MyReviewsView.swift',
  'CollocatorReviewsView.swift',
  'ReviewsPage.swift',
  'ListReviewView.swift'
]

files_to_add.each do |filename|
  if !screens_group.files.any? { |f| f.path == filename }
    file_ref = screens_group.new_reference(filename)
    
    # Ajouter aux targets
    target = project.targets.first
    target.add_file_references([file_ref])
    
    puts "✅ #{filename} ajouté"
  else
    puts "⚠️ #{filename} déjà présent"
  end
end

project.save
puts "✅ Projet sauvegardé"
