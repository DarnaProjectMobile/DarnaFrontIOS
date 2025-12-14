#!/usr/bin/env ruby
require 'xcodeproj'

puts "🔧 Nettoyage et réajout des fichiers de visite..."

project = Xcodeproj::Project.open('DarnaApp.xcodeproj')
main_target = project.targets.first
main_group = project.main_group.find_subpath('DarnaApp', true)

# Liste des fichiers à supprimer et rajouter
files_to_readd = [
  { name: 'Visit.swift', path: 'DarnaApp/Models/Visit.swift', group: 'Models' },
  { name: 'VisitAPIService.swift', path: 'DarnaApp/Network/VisitAPIService.swift', group: 'Network' },
  { name: 'VisitRepository.swift', path: 'DarnaApp/Repository/VisitRepository.swift', group: 'Repository' },
  { name: 'VisitViewModel.swift', path: 'DarnaApp/ViewModels/VisitViewModel.swift', group: 'ViewModels' },
  { name: 'VisitCardView.swift', path: 'DarnaApp/Views/Components/VisitCardView.swift', group: 'Views/Components' },
  { name: 'CollocatorVisitsView.swift', path: 'DarnaApp/Views/Screens/CollocatorVisitsView.swift', group: 'Views/Screens' },
  { name: 'VisitEditSheet.swift', path: 'DarnaApp/Views/Screens/VisitEditSheet.swift', group: 'Views/Screens' },
  { name: 'VisitManagementView.swift', path: 'DarnaApp/Views/Screens/VisitManagementView.swift', group: 'Views/Screens' },
  { name: 'VisitReservationView.swift', path: 'DarnaApp/Views/Screens/VisitReservationView.swift', group: 'Views/Screens' },
  { name: 'VisitReviewSheet.swift', path: 'DarnaApp/Views/Screens/VisitReviewSheet.swift', group: 'Views/Screens' },
  { name: 'ServerConfig.swift', path: 'DarnaApp/Resources/ServerConfig.swift', group: 'Resources' }
]

puts "\n📝 Étape 1: Suppression des anciennes références..."

# Supprimer toutes les anciennes références
project.files.each do |file_ref|
  if file_ref.path && files_to_readd.any? { |f| file_ref.path.include?(f[:name]) }
    puts "   🗑️  Suppression: #{file_ref.path}"
    file_ref.remove_from_project
  end
end

puts "\n📝 Étape 2: Ajout des nouvelles références..."

files_to_readd.each do |file_info|
  # Vérifier que le fichier existe
  unless File.exist?(file_info[:path])
    puts "   ⚠️  Fichier non trouvé: #{file_info[:path]}"
    next
  end
  
  # Trouver ou créer le groupe
  group = main_group.find_subpath(file_info[:group], true)
  
  # Ajouter la référence
  file_ref = group.new_file(file_info[:path])
  
  # Ajouter à la phase de compilation
  main_target.add_file_references([file_ref])
  
  puts "   ✅ Ajouté: #{file_info[:path]}"
end

# Sauvegarder
project.save

puts "\n✨ Nettoyage et réajout terminés!"
puts "\n⚠️  IMPORTANT:"
puts "   1. Fermez Xcode COMPLÈTEMENT (Cmd+Q)"
puts "   2. Rouvrez DarnaApp.xcodeproj"
puts "   3. Nettoyez: Cmd+Shift+K"
puts "   4. Compilez: Cmd+B"
