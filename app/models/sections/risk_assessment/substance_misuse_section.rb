module RiskAssessment
  class SubstanceMisuseSection
    def name
      'substance_misuse'
    end

    def questions
      %w[substance_supply substance_use]
    end
    alias mandatory_questions questions
  end
end
