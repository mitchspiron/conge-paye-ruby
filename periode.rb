require 'date'

class Periode
  attr_reader :debut, :fin

  def initialize(debut, fin)
    @debut = debut
    @fin = fin
  end

  def self.generer_periodes(date_debut, date_fin)
    periodes = []

    # Définir la première période en fonction de la date de début
    periode_debut = date_debut
    periode_fin = Date.new(periode_debut.year, 5, -1)
    periode_fin = periode_fin.next_year if periode_debut.month >= 6

    periodes.push(Periode.new(periode_debut, date_fin <= periode_fin ? date_fin : periode_fin))

    # Ajouter les périodes suivantes jusqu'à couvrir la date de fin
    while periodes.last.fin < date_fin
      dernier_fin = periodes.last.fin
      nouvelle_debut = Date.new(dernier_fin.year, 6, 1)
      nouvelle_fin = Date.new(nouvelle_debut.year + 1, 5, -1)

      periodes.push(Periode.new(nouvelle_debut, date_fin <= nouvelle_fin ? date_fin : nouvelle_fin))
    end

    periodes
  end
end
