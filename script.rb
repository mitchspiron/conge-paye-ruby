require 'date'

class SimulateurConge
  def initialize(date_debut, date_fin, salaire_brut_mensuel)
    @date_debut = Date.parse(date_debut)
    @date_fin = Date.parse(date_fin)
    @salaire_brut_mensuel = salaire_brut_mensuel
  end

  # Validation
  def validation
    if @date_debut > @date_fin
      puts ">> La date de fin doit être postérieure à la date de début"
      exit
    end

    if @salaire_brut_mensuel < 200 || @salaire_brut_mensuel > 1200
      puts ">> Le salaire brut mensuel doit être compris entre 200 et 1200 euros"
      exit
    end
  end

  # Fonction pour vérifier si un jour est un jour ouvré (du lundi au vendredi)
  def jour_ouvert?(date)
    jour = date.wday
    jour != 0 && jour != 6  # 0 correspond au dimanche, 6 correspond au samedi
  end

  # Fonction pour calculer le nombre de jours ouvrés entre deux dates
  def nombre_de_jours_ouvres
    jours_ouvres = 0
    current_date = @date_debut

    while current_date <= @date_fin
      jours_ouvres += 1 if jour_ouvert?(current_date)
      current_date += 1
    end

    jours_ouvres
  end

  # Fonction pour calculer le nombre de jours de congés payés acquis
  def nombre_de_jours_conges_acquis
    # Calcul du nombre de jours ouvrés
    jours_ouvres_entre_dates = nombre_de_jours_ouvres

    # Calcul du nombre de semaine en une année de jours ouvrés
    totale_semaine = jours_ouvres_entre_dates / 5.0

    # Calcul du nombre de mois en une année de jours ouvrés
    totale_mois = totale_semaine / 4.0 - 1.0

    # Calcul du nombre de jours de congés payés acquis
    jours_acquis = (totale_mois * 2.5).ceil

    resultat = [
      ["Nombre de jours ouvrés", jours_ouvres_entre_dates],
      ["Nombre de semaine", totale_semaine],
      ["Nombre de mois", totale_mois],
      ["Nombre de jours acquis", jours_acquis]
    ]
  end

  # Fonction pour calculer la valeur monétaire des jours acquis
  def valeur_jours_acquis
    # Récupérer les temps (Nombre de jours ouvrés, Nombre de semaine, Nombre de mois, Nombre de jours acquis)
    temps = nombre_de_jours_conges_acquis

    salaire_hebdomadaire = (12 * @salaire_brut_mensuel) / temps[1][1].to_f

    # Calcul par la méthode "Maintient de salaire"
    maintient = (temps[3][1] / 6.0) * salaire_hebdomadaire

    # Calcul par la méthode de "10%"
    dixieme = temps[2][1] * @salaire_brut_mensuel * 0.1

    # Prendre le montant le plus favorable
    valeur = [maintient, dixieme].max

    resultat = ["Valeur monétaire", valeur.round(2)]
  end

  # Fonction pour lister les salaires par mois entre deux dates
  def salaire_par_mois
    mois_labels = [
      "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ]

    resultat = []

    annee_debut = @date_debut.year
    annee_fin = @date_fin.year
    mois_debut = @date_debut.month
    mois_fin = @date_fin.month

    # Lister les années dans l'intervalle de temps
    (annee_debut..annee_fin).each do |annee|
      debut_mois = (annee == annee_debut) ? mois_debut : 1
      fin_mois = (annee == annee_fin) ? mois_fin : 12

      # Lister tous les mois dans une année
      (debut_mois..fin_mois).each do |mois|
        premier_jour_du_mois = Date.new(annee, mois, 1)
        dernier_jour_du_mois = Date.new(annee, mois, -1)

        jours_dans_le_mois = dernier_jour_du_mois.day
        salaire_mensuel = 0

        # Calcul salaire mensuel
        if mois == mois_debut && annee == annee_debut
          # Si le premier mois est incomplète
          jours_travailles = jours_dans_le_mois - @date_debut.day + 1
          salaire_mensuel = (@salaire_brut_mensuel * jours_travailles) / jours_dans_le_mois.to_f
        elsif mois == mois_fin && annee == annee_fin
          # Si le dernier mois est incomplète
          jours_travailles = @date_fin.day
          salaire_mensuel = (@salaire_brut_mensuel * jours_travailles) / jours_dans_le_mois.to_f
        else
          # Si les mois sont complètes
          salaire_mensuel = @salaire_brut_mensuel
        end

        resultat << {
          mois: mois_labels[mois - 1],
          annee: annee,
          salaire: format('%.2f euro', salaire_mensuel)
        }
      end
    end

    resultat
  end
end

# Saisie des dates d'exemple
print "Entrez la date de début (YYYY-MM-DD) : "
date_debut = gets.chomp

print "Entrez la date de fin (YYYY-MM-DD) : "
date_fin = gets.chomp

# Saisie du salaire
print "Entrez le salaire : "
salaire = gets.chomp.to_i

calculator = SimulateurConge.new(date_debut, date_fin, salaire)
calculator.validation

# Appels des méthodes
jours = calculator.nombre_de_jours_conges_acquis
valeurs = calculator.valeur_jours_acquis
liste_salaires = calculator.salaire_par_mois

# Affichage des résultats
puts "Nombre de jours acquis: " + jours[3][1].to_s
puts "Valeur monétaire: " + valeurs[1].to_s
puts liste_salaires
