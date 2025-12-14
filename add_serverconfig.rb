#!/usr/bin/env ruby
require 'xcodeproj'

project = Xcodeproj::Project.open('DarnaApp.xcodeproj')
main_group = project.main_group.find_subpath('DarnaApp', true)
resources_group = main_group.find_subpath('Resources', true)

# Vérifier si le fichier existe déjà
existing = resources_group.files.find { |f| f.path == 'ServerConfig.swift' }

if existing
  puts "ServerConfig.swift déjà présent"
  existing.remove_from_project
end

file_ref = resources_group.new_reference('DarnaApp/Resources/ServerConfig.swift')
project.targets.first.add_file_references([file_ref])
project.save

puts "✅ ServerConfig.swift ajouté au projet"
