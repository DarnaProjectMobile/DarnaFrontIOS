#!/usr/bin/env ruby
require 'xcodeproj'

puts "🔧 Correction FINALE de VisitRepository.swift..."

project = Xcodeproj::Project.open('DarnaApp.xcodeproj')
target = project.targets.first

# Supprimer TOUTES les références à VisitRepository
puts "\n🗑️  Suppression de toutes les références existantes..."
project.files.select { |f| f.path && f.path.include?('VisitRepository') }.each do |ref|
  puts "   - Suppression: #{ref.path}"
  ref.remove_from_project
end

# Trouver le groupe Repository
main_group = project.main_group.find_subpath('DarnaApp', true)
repo_group = main_group.find_subpath('Repository', true)

puts "\n✅ Groupe Repository trouvé"
puts "   Chemin du groupe: #{repo_group.path || repo_group.name}"

# Créer UNE SEULE nouvelle référence
puts "\n➕ Création d'une nouvelle référence..."
new_ref = repo_group.new_reference('VisitRepository.swift')
new_ref.source_tree = '<group>'

puts "   Path: #{new_ref.path}"
puts "   Source tree: #{new_ref.source_tree}"
puts "   UUID: #{new_ref.uuid}"

# Ajouter à la compilation
target.add_file_references([new_ref])
puts "   ✅ Ajouté à la compilation"

# Vérifier qu'il n'y a qu'une seule entrée
build_files = target.source_build_phase.files.select do |bf|
  bf.file_ref && bf.file_ref.path && bf.file_ref.path.include?('VisitRepository')
end

puts "\n📊 Vérification finale:"
puts "   Références dans le projet: #{project.files.select { |f| f.path && f.path.include?('VisitRepository') }.count}"
puts "   Entrées de compilation: #{build_files.count}"

project.save
puts "\n💾 Projet sauvegardé!"
