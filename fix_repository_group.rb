#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'DarnaApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

puts "🔧 Vérification des groupes et fichiers..."

# Trouver le groupe principal DarnaApp
main_group = project.main_group.find_subpath('DarnaApp', true)

# Trouver le groupe Repository
repo_group = main_group.find_subpath('Repository', false)

if repo_group
  puts "✅ Groupe 'Repository' trouvé."
  
  # Vérifier le chemin du groupe
  if repo_group.path == ' Repository'
    puts "⚠️  Le chemin du groupe est incorrect (' Repository'). Correction..."
    repo_group.path = 'Repository'
  elsif repo_group.path.nil? && repo_group.name == 'Repository'
     # Si le path est nil, il utilise le nom, donc c'est bon si le nom est bon, 
     # mais pour être sûr on peut forcer le path si on veut être explicite, 
     # ou vérifier si le dossier physique correspond.
     # Ici on va s'assurer qu'il pointe bien vers le dossier 'Repository'
     repo_group.path = 'Repository'
     puts "ℹ️  Chemin du groupe défini explicitement sur 'Repository'."
  else
    puts "ℹ️  Chemin actuel du groupe : '#{repo_group.path}'"
    # Si c'était déjà 'Repository', c'est parfait.
    if repo_group.path != 'Repository'
        repo_group.path = 'Repository'
        puts "✅ Chemin corrigé vers 'Repository'"
    end
  end
else
  puts "⚠️  Groupe 'Repository' non trouvé. Création..."
  repo_group = main_group.new_group('Repository', 'Repository')
end

# Vérifier les fichiers dans le groupe
puts "📂 Vérification des fichiers dans le groupe Repository..."
files_to_check = ['VisitRepository.swift', 'AdRepository.swift']
target = project.targets.first

files_to_check.each do |filename|
  # Chercher si le fichier est déjà dans le groupe
  existing_ref = repo_group.files.find { |f| f.path == filename }
  
  if existing_ref
    puts "✅ #{filename} est déjà référencé."
    # Vérifier s'il est dans la phase de compilation
    build_file = target.source_build_phase.files.find { |bf| bf.file_ref == existing_ref }
    unless build_file
      puts "⚠️  #{filename} n'était pas compilé. Ajout à la target..."
      target.add_file_references([existing_ref])
    end
  else
    puts "➕ Ajout de #{filename} au projet..."
    new_ref = repo_group.new_reference(filename)
    target.add_file_references([new_ref])
  end
end

project.save
puts "💾 Projet sauvegardé."
