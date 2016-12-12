class Risk < ApplicationRecord
  belongs_to :detainee
  include Questionable

  QUESTION_FIELDS =
    %w[ acct_status rule_45 csra victim_of_abuse high_profile violent
        stalker_harasser_bully sex_offence non_association_markers
        current_e_risk category_a
        restricted_status substance_supply substance_use conceals_weapons arson
        damage_to_property interpreter_required hearing_speach_sight
        can_read_and_write ].freeze

  def question_fields
    QUESTION_FIELDS
  end
end
