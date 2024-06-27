'require_relative'
require_relative 'contrat'
require_relative 'periode'
require_relative 'calculateur_de_salaire'

# Saisie des dates et du salaire par l'utilisateur
puts "Veuillez entrer la date de début (YYYY-MM-DD) :"
date_debut = gets.chomp

puts "Veuillez entrer la date de fin (YYYY-MM-DD) :"
date_fin = gets.chomp

puts "Veuillez entrer le salaire brut mensuel :"
salaire_brut_mensuel = gets.chomp.to_f

puts "Veuillez entrer le mode de paiement ('integral_juin' ou 'dixieme') :"
mode_paiement = gets.chomp

begin
  # Crée une instance de Contrat avec les données saisies
  contrat = Contrat.new(date_debut, date_fin, salaire_brut_mensuel, mode_paiement)

  # Génère les périodes et calcule les salaires
  CalculateurDeSalaire.generer_periodes_et_salaires(contrat)
rescue StandardError => e
  puts "Erreur : #{e.message}"
end
