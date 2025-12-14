#!/usr/bin/env ruby
require 'xcodeproj'

project = Xcodeproj::Project.open('DarnaApp.xcodeproj')
target = project.targets.first
main_group = project.main_group.find_subpath('DarnaApp', true)
models_group = main_group.find_subpath('Models', true)

# Ajouter Property+Demo.swift
file_ref = models_group.new_reference('Property+Demo.swift')
target.add_file_references([file_ref])

project.save
puts "✅ Property+Demo.swift ajouté au projet"
