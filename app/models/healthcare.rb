class Healthcare < ApplicationRecord
  belongs_to :detainee
  include Questionable

  QUESTION_FIELDS =
    %w[ physical_issues mental_illness phobias personal_hygiene
        personal_care allergies dependencies has_medications mpv ]

  has_many :medications, dependent: :destroy

  def question_fields
    QUESTION_FIELDS
  end
end
