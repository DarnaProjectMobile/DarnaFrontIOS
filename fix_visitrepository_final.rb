#!/usr/bin/env ruby
require 'xcodeproj'

puts "🔧 Correction FINALE du chemin VisitRepository.swift..."

project = Xcodeproj::Project.open('DarnaApp.xcodeproj')
main_target = project.targets.first

# Trouver toutes les références à VisitRepository
visit_repo_refs = []
project.files.each do |file_ref|
  if file_ref.path && file_ref.path.include?('VisitRepository')
    visit_repo_refs << file_ref
    puts "📍 Référence trouvée: #{file_ref.path}"
    puts "   Real path: #{file_ref.real_path rescue 'N/A'}"
  end
end

# Supprimer toutes les références
visit_repo_refs.each do |ref|
  puts "🗑️  Suppression: #{ref.path}"
  ref.remove_from_project
end

# Trouver le groupe Repository
main_group = project.main_group.find_subpath('DarnaApp', true)
repository_group = main_group.find_subpath('Repository', true)

puts "📁 Groupe Repository: #{repository_group.path rescue repository_group.name}"

# Créer une nouvelle référence avec JUSTE le nom du fichier
# Le groupe Repository gère déjà le chemin de base
new_file_ref = repository_group.new_reference('VisitRepository.swift')
new_file_ref.source_tree = '<group>'

puts "✅ Nouvelle référence créée"
puts "   Path: #{new_file_ref.path}"
puts "   Source tree: #{new_file_ref.source_tree}"

# Ajouter à la phase de compilation
main_target.add_file_references([new_file_ref])
puts "✅ Ajouté à la phase de compilation"

# Sauvegarder
project.save
puts "\n✨ Correction terminée!"

puts "\n🚨 IMPORTANT:"
puts "   1. Fermez Xcode COMPLÈTEMENT (Cmd+Q)"
puts "   2. Supprimez DerivedData:"
puts "      rm -rf ~/Library/Developer/Xcode/DerivedData/DarnaApp-*"
puts "   3. Rouvrez DarnaApp.xcodeproj"
puts "   4. Nettoyez: Cmd+Shift+K"
puts "   5. Compilez: Cmd+B"
