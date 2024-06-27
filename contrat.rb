require 'date'

class Contrat
  attr_reader :date_debut, :date_fin, :salaire_brut_mensuel, :mode_paiement

  def initialize(date_debut, date_fin, salaire_brut_mensuel, mode_paiement)
    @date_debut = Date.parse(date_debut)
    @date_fin = Date.parse(date_fin)
    @salaire_brut_mensuel = salaire_brut_mensuel.to_f
    @mode_paiement = mode_paiement
    validation
  end

  # Validation
  def validation
    if date_debut > date_fin
      raise " >> La date de fin doit être postérieure à la date de début"
    end

    if salaire_brut_mensuel < 200 || salaire_brut_mensuel > 1200
      raise " >> Le salaire brut mensuel doit être compris entre 200 et 1200 euros"
    end
  end
end
