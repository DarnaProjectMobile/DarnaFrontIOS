require 'xcodeproj'

project_path = 'DarnaApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

main_group = project.main_group['DarnaApp']
views_group = main_group['Views']
components_group = views_group['Components']

file_name = 'ReviewsListView.swift'

# Trouver et supprimer la référence incorrecte
incorrect_file = components_group.files.find { |f| f.path.include?('DarnaApp/Views/Components') }
if incorrect_file
  incorrect_file.remove_from_project
  puts "Référence incorrecte supprimée."
end

# Ajouter la référence correcte
# Puisque le groupe 'Components' pointe probablement déjà vers 'DarnaApp/Views/Components'
# On ajoute juste le nom du fichier
file_ref = components_group.new_file('ReviewsListView.swift')

target = project.targets.first
target.add_file_references([file_ref])

project.save
puts "Chemin corrigé pour ReviewsListView.swift"
