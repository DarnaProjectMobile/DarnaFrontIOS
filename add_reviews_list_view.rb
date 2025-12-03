require 'xcodeproj'

project_path = 'DarnaApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Trouver le groupe 'Components' dans 'Views'
main_group = project.main_group['DarnaApp']
views_group = main_group['Views']
components_group = views_group['Components']

# Créer le groupe s'il n'existe pas (juste au cas où)
unless components_group
  components_group = views_group.new_group('Components')
end

# Ajouter le fichier
file_name = 'ReviewsListView.swift'
file_path = 'DarnaApp/Views/Components/ReviewsListView.swift'

# Vérifier si le fichier est déjà dans le projet
existing_file = components_group.files.find { |f| f.path == file_name }

if existing_file
  puts "#{file_name} est déjà dans le projet."
else
  file_ref = components_group.new_file(file_path)
  
  # Ajouter à la cible principale
  target = project.targets.first
  target.add_file_references([file_ref])
  
  project.save
  puts "#{file_name} ajouté avec succès au projet."
end
