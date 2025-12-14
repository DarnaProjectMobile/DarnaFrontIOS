#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'DarnaApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

puts "🔧 Nettoyage des fichiers dupliqués dans la phase de compilation..."

files_to_check = ['VisitRepository.swift', 'AdRepository.swift']

files_to_check.each do |filename|
  puts "\n📝 Vérification de #{filename}..."
  
  # Trouver toutes les références à ce fichier
  all_refs = project.files.select { |f| f.path && f.path.include?(filename) }
  
  puts "   Trouvé #{all_refs.count} référence(s) dans le projet"
  all_refs.each_with_index do |ref, i|
    puts "   #{i+1}. #{ref.path} (UUID: #{ref.uuid})"
  end
  
  # Trouver toutes les entrées dans la phase de compilation
  build_files = target.source_build_phase.files.select do |bf|
    bf.file_ref && bf.file_ref.path && bf.file_ref.path.include?(filename)
  end
  
  puts "   Trouvé #{build_files.count} entrée(s) dans la phase de compilation"
  
  if build_files.count > 1
    puts "   ⚠️  DOUBLON DÉTECTÉ! Suppression des doublons..."
    
    # Garder seulement la première entrée, supprimer les autres
    build_files[1..-1].each do |duplicate|
      target.source_build_phase.files.delete(duplicate)
      puts "   ✅ Doublon supprimé"
    end
  elsif build_files.count == 1
    puts "   ✅ Pas de doublon"
  else
    puts "   ⚠️  Fichier non trouvé dans la compilation"
  end
  
  # Si on a plusieurs références de fichier, on garde la meilleure
  if all_refs.count > 1
    puts "   🧹 Nettoyage des références multiples..."
    
    # Garder celle qui a le chemin le plus simple (juste le nom du fichier)
    best_ref = all_refs.min_by { |r| r.path.length }
    
    all_refs.each do |ref|
      if ref != best_ref
        puts "   🗑️  Suppression de la référence: #{ref.path}"
        ref.remove_from_project
      end
    end
    
    # S'assurer que la meilleure référence est dans la compilation
    unless target.source_build_phase.files.any? { |bf| bf.file_ref == best_ref }
      target.add_file_references([best_ref])
      puts "   ✅ Référence ajoutée à la compilation"
    end
  end
end

project.save
puts "\n💾 Projet sauvegardé!"
puts "\n🚨 IMPORTANT:"
puts "   1. Fermez Xcode (Cmd+Q)"
puts "   2. Rouvrez le projet"
puts "   3. Nettoyez: Cmd+Shift+K"
puts "   4. Compilez: Cmd+B"
