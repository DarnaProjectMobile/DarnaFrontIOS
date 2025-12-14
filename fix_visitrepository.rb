#!/usr/bin/env ruby
require 'xcodeproj'

puts "🔧 Correction de la référence VisitRepository.swift..."

project = Xcodeproj::Project.open('DarnaApp.xcodeproj')
main_target = project.targets.first

# Trouver la référence actuelle
visit_repo_ref = nil
project.files.each do |file_ref|
  if file_ref.path == 'VisitRepository.swift'
    visit_repo_ref = file_ref
    puts "📍 Référence trouvée: #{file_ref.path}"
    puts "   Groupe parent: #{file_ref.parent.name rescue 'N/A'}"
    break
  end
end

if visit_repo_ref
  # Supprimer l'ancienne référence
  puts "🗑️  Suppression de l'ancienne référence..."
  visit_repo_ref.remove_from_project
  
  # Trouver le groupe Repository
  main_group = project.main_group.find_subpath('DarnaApp', true)
  repository_group = main_group.find_subpath('Repository', true)
  
  puts "📁 Groupe Repository trouvé"
  
  # Ajouter la nouvelle référence au bon endroit
  new_file_ref = repository_group.new_file('DarnaApp/Repository/VisitRepository.swift')
  puts "✅ Nouvelle référence créée: #{new_file_ref.path}"
  
  # Ajouter à la phase de compilation
  main_target.add_file_references([new_file_ref])
  puts "✅ Ajouté à la phase de compilation"
  
  # Sauvegarder
  project.save
  puts "\n✨ Correction terminée avec succès!"
else
  puts "❌ Référence VisitRepository.swift non trouvée"
end

puts "\n🚨 IMPORTANT:"
puts "   1. Fermez Xcode COMPLÈTEMENT (Cmd+Q)"
puts "   2. Rouvrez DarnaApp.xcodeproj"
puts "   3. Nettoyez: Cmd+Shift+K"
puts "   4. Compilez: Cmd+B"
