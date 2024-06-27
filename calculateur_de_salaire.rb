require 'date'
require_relative 'periode'

class CalculateurDeSalaire
  # Fonction auxiliaire pour obtenir le nombre de jours dans un mois donné
  def self.nombre_de_jours_mois(date)
    annee = date.year
    mois = date.month
    Date.new(annee, mois, -1).day
  end

  # Fonction pour obtenir la différence en mois
  def self.difference_en_mois(date_debut, date_fin)
    mois_debut = date_debut.month
    mois_fin = date_fin.month
    annee_debut = date_debut.year
    annee_fin = date_fin.year

    nombre_mois = (annee_fin - annee_debut) * 12 + (mois_fin - mois_debut)
    jours_debut = date_debut.day
    jours_fin = date_fin.day

    if jours_debut > jours_fin
      return nombre_mois - 1 + (jours_fin - jours_debut).to_f / nombre_de_jours_mois(date_debut)
    else
      return nombre_mois + (jours_fin - jours_debut).to_f / nombre_de_jours_mois(date_debut)
    end
  end

  def self.mois_labels
    ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
     "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
  end

  # Fonction pour calculer les salaires par mois
  def self.salaire_par_mois(date_debut, date_fin, salaire_brut_mensuel)
    labels = mois_labels()
    resultat = []

    annee_debut = date_debut.year
    annee_fin = date_fin.year
    mois_debut = date_debut.month - 1
    mois_fin = date_fin.month - 1

    (annee_debut..annee_fin).each do |annee|
      debut = annee == annee_debut ? mois_debut : 0
      fin = annee == annee_fin ? mois_fin : 11

      (debut..fin).each do |mois|
        premier_jour_du_mois = Date.new(annee, mois + 1, 1)
        dernier_jour_du_mois = Date.new(annee, mois + 1, -1)

        jours_dans_le_mois = dernier_jour_du_mois.day
        salaire_mensuel = 0.0

        if mois == mois_debut && annee == annee_debut
          # Si le nombre de jour est incomplet au début du contrat
          nb_jour = jours_dans_le_mois - date_debut.day + 1
          if nb_jour == jours_dans_le_mois
            jours_travailles = jours_dans_le_mois - date_debut.day + 1
            salaire_mensuel = (salaire_brut_mensuel * jours_travailles) / jours_dans_le_mois
          else
            # Si le nombre de jour est incomplet à la fin du contrat
            jours_travailles = jours_dans_le_mois - date_debut.day
            salaire_mensuel = (salaire_brut_mensuel * jours_travailles) / jours_dans_le_mois
          end
        elsif mois == mois_fin && annee == annee_fin
          jours_travailles = date_fin.day
          salaire_mensuel = (salaire_brut_mensuel * jours_travailles) / jours_dans_le_mois
        else
          # Si le nombre de jour est complet
          salaire_mensuel = salaire_brut_mensuel
        end

        resultat.push({
          mois: labels[mois],
          annee: annee,
          salaire: format('%.2f', salaire_mensuel)
        })
      end
    end

    resultat
  end

  # Fonction pour calculer la valeur monétaire des jours acquis
  def self.valeur_monetaire_et_jours_acquis(date_debut, date_fin, salaire)
    # Calcul du nombre de mois
    nombre_mois = difference_en_mois(date_debut, date_fin)

    # Récupérer le nombre de jour acquis
    jours_acquis = (nombre_mois.to_f * 2.5).round(1)

    # Calcul par la méthode "Maintient de salaire"
    maintient = (salaire * jours_acquis) / 22

    # Salaire par mois
    salaire_mensuel = salaire_par_mois(date_debut, date_fin, salaire)
    totale_salaire = salaire_mensuel.sum { |mois| mois[:salaire].to_f }

    # Calcul par la méthode de "10%"
    dixieme = totale_salaire / 10

    # Prendre le montant le plus favorable
    valeur = [maintient, dixieme].max
    resultat = ["Valeur monétaire", format('%.2f', valeur)]
    [resultat, jours_acquis]
  end

  # Fonction pour générer les périodes dynamiques et calculer les salaires
  def self.generer_periodes_et_salaires(contrat)
    periodes = Periode.generer_periodes(contrat.date_debut, contrat.date_fin)
    valeur_monetaire_par_periode = periodes.map do |periode|
      valeur_monetaire_et_jours_acquis(periode.debut, periode.fin, contrat.salaire_brut_mensuel)[0][1].to_f
    end

    periodes.each_with_index do |periode, index|
      salaire_mensuel = salaire_par_mois(periode.debut, periode.fin, contrat.salaire_brut_mensuel)
      puts "Période #{index + 1}:"
      puts " -> Valeur monétaire = #{valeur_monetaire_et_jours_acquis(periode.debut, periode.fin, contrat.salaire_brut_mensuel)[0][1]}"
      puts " -> Nombre de jours acquis = #{valeur_monetaire_et_jours_acquis(periode.debut, periode.fin, contrat.salaire_brut_mensuel)[1]}"
      puts " -> listeSalaire: de #{periode.debut.strftime('%B %Y')} à #{periode.fin.strftime('%B %Y')}"

      salaire_mensuel.each do |mois|
        paiement_conge = 0
        labels = mois_labels()

        # Paiement en juin de l'année courante pour la période précédente
        if contrat.mode_paiement == "integral_juin"
          if index > 0 && mois[:mois] == "Juin"
            paiement_conge = valeur_monetaire_par_periode[index - 1]
          end

          # Paiement pour le dernier mois du contrat
          if mois[:mois] == labels[contrat.date_fin.month - 1] && mois[:annee] == contrat.date_fin.year
            paiement_conge = valeur_monetaire_par_periode[index]
          end
        end

        # Paiement 10% chaque mois, dès le début du contrat
        if contrat.mode_paiement == "dixieme"
          paiement_conge = contrat.salaire_brut_mensuel * 0.1
        end

        puts "Mois: #{mois[:mois]}, Année: #{mois[:annee]}, Salaire: #{mois[:salaire]}, Paiement Congé: #{format('%.2f', paiement_conge)}"
      end
    end
  end
end
