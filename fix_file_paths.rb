#!/usr/bin/env ruby
require 'xcodeproj'

puts "🔧 Correction des chemins de fichiers dans le projet Xcode..."

project = Xcodeproj::Project.open('DarnaApp.xcodeproj')
main_target = project.targets.first

# Fichiers à corriger avec leurs chemins corrects
files_to_fix = {
  'ServerConfig.swift' => 'DarnaApp/Resources/ServerConfig.swift',
  'VisitViewModel.swift' => 'DarnaApp/ViewModels/VisitViewModel.swift',
  'VisitReservationView.swift' => 'DarnaApp/Views/Screens/VisitReservationView.swift',
  'VisitCardView.swift' => 'DarnaApp/Views/Components/VisitCardView.swift',
  'VisitAPIService.swift' => 'DarnaApp/Network/VisitAPIService.swift',
  'CollocatorVisitsView.swift' => 'DarnaApp/Views/Screens/CollocatorVisitsView.swift',
  'VisitManagementView.swift' => 'DarnaApp/Views/Screens/VisitManagementView.swift',
  'VisitEditSheet.swift' => 'DarnaApp/Views/Screens/VisitEditSheet.swift',
  'Visit.swift' => 'DarnaApp/Models/Visit.swift',
  'VisitReviewSheet.swift' => 'DarnaApp/Views/Screens/VisitReviewSheet.swift',
  'VisitRepository.swift' => 'DarnaApp/Repository/VisitRepository.swift'
}

fixed_count = 0

# Parcourir tous les fichiers du projet
project.files.each do |file_ref|
  next unless file_ref.path
  
  # Vérifier si le chemin est doublé
  if file_ref.path.include?('DarnaApp/') && file_ref.path.count('DarnaApp/') > 1
    filename = File.basename(file_ref.path)
    
    if files_to_fix.key?(filename)
      correct_path = files_to_fix[filename]
      puts "❌ Chemin incorrect: #{file_ref.path}"
      puts "✅ Correction en: #{correct_path}"
      
      # Corriger le chemin
      file_ref.path = correct_path
      fixed_count += 1
    end
  end
end

# Sauvegarder le projet
project.save

puts "\n✨ Correction terminée!"
puts "📝 #{fixed_count} fichier(s) corrigé(s)"
puts "\n⚠️  IMPORTANT:"
puts "   1. Fermez Xcode complètement"
puts "   2. Rouvrez le projet"
puts "   3. Nettoyez: Cmd+Shift+K"
puts "   4. Compilez: Cmd+B"
